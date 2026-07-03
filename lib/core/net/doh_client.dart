import 'dart:convert';
import 'dart:io';

/// Fallback HTTP POST for networks whose DNS blocks specific domains
/// (carrier DNS filtering) or that are IPv6-only (IPv4 literals
/// unreachable, errno 101).
///
/// Resolves the host via DNS-over-HTTPS at IP-literal endpoints (both
/// address families), then connects to each resolved address in turn and
/// upgrades to TLS with SNI + certificate validation against the real
/// hostname via [SecureSocket.secure].
class DohClient {
  // IP-literal DoH endpoints — no DNS needed to reach them. Both address
  // families so IPv6-only and IPv4-only networks each have a working one.
  static const _dohEndpoints = [
    'https://[2606:4700:4700::1111]/dns-query', // Cloudflare v6
    'https://1.1.1.1/dns-query', // Cloudflare v4
    'https://[2001:4860:4860::8888]/resolve', // Google v6
    'https://8.8.8.8/resolve', // Google v4
  ];

  /// Resolves [host] to all its addresses, IPv6 first (IPv6-only networks
  /// can't reach IPv4 targets).
  static Future<List<String>> resolveAll(String host) async {
    Object? lastError;
    for (final endpoint in _dohEndpoints) {
      try {
        final v6 = await _query(endpoint, host, 28); // AAAA
        final v4 = await _query(endpoint, host, 1); // A
        final all = [...v6, ...v4];
        if (all.isNotEmpty) return all;
        lastError = 'no records for $host from $endpoint';
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception('DoH resolve failed for $host: $lastError');
  }

  static Future<List<String>> _query(
      String endpoint, String host, int type) async {
    final client = HttpClient();
    try {
      final req = await client
          .getUrl(Uri.parse('$endpoint?name=$host&type=$type'))
          .timeout(const Duration(seconds: 8));
      req.headers.set('accept', 'application/dns-json');
      final res = await req.close().timeout(const Duration(seconds: 8));
      final body = await res.transform(utf8.decoder).join();
      final answers = (jsonDecode(body)['Answer'] as List?) ?? [];
      return answers
          .cast<Map<String, dynamic>>()
          .where((r) => r['type'] == type)
          .map((r) => r['data'] as String)
          .toList();
    } finally {
      client.close(force: true);
    }
  }

  /// POSTs [formBody] (form-urlencoded) to https://[host][path], trying
  /// each address in [ips] until one connects. HTTP/1.1, Connection:
  /// close, chunked decode. Returns response body. Throws on non-200.
  static Future<String> post({
    required String host,
    required String path,
    required List<String> ips,
    required Map<String, String> formBody,
  }) async {
    Object? lastError;
    for (final ip in ips) {
      try {
        return await _postViaIp(
            host: host, path: path, ip: ip, formBody: formBody);
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception('all addresses failed for $host: $lastError');
  }

  static Future<String> _postViaIp({
    required String host,
    required String path,
    required String ip,
    required Map<String, String> formBody,
  }) async {
    final socket = await Socket.connect(ip, 443,
        timeout: const Duration(seconds: 15));
    try {
      final secure = await SecureSocket.secure(socket, host: host)
          .timeout(const Duration(seconds: 15));
      final body = formBody.entries
          .map((e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      final bodyBytes = utf8.encode(body);
      secure.write('POST $path HTTP/1.1\r\n'
          'Host: $host\r\n'
          'User-Agent: com.zenvlog.app\r\n'
          'Accept: */*\r\n'
          'Content-Type: application/x-www-form-urlencoded\r\n'
          'Content-Length: ${bodyBytes.length}\r\n'
          'Connection: close\r\n'
          '\r\n');
      secure.add(bodyBytes);
      await secure.flush();

      final raw = <int>[];
      await for (final chunk in secure.timeout(const Duration(seconds: 60))) {
        raw.addAll(chunk);
      }
      return _parseResponse(raw, host);
    } finally {
      socket.destroy();
    }
  }

  static String _parseResponse(List<int> raw, String host) {
    final headerEnd = _indexOfHeaderEnd(raw);
    if (headerEnd < 0) throw Exception('Malformed HTTP response from $host');
    final headerText = latin1.decode(raw.sublist(0, headerEnd));
    final statusLine = headerText.split('\r\n').first;
    final status = int.tryParse(statusLine.split(' ')[1]) ?? 0;
    if (status != 200) {
      throw Exception('HTTP $status from $host (via DoH/IP)');
    }
    var bodyBytes = raw.sublist(headerEnd + 4);
    if (headerText.toLowerCase().contains('transfer-encoding: chunked')) {
      bodyBytes = _dechunk(bodyBytes);
    }
    return utf8.decode(bodyBytes, allowMalformed: true);
  }

  static int _indexOfHeaderEnd(List<int> raw) {
    for (var i = 0; i + 3 < raw.length; i++) {
      if (raw[i] == 13 &&
          raw[i + 1] == 10 &&
          raw[i + 2] == 13 &&
          raw[i + 3] == 10) {
        return i;
      }
    }
    return -1;
  }

  static List<int> _dechunk(List<int> data) {
    final out = <int>[];
    var pos = 0;
    while (pos < data.length) {
      var lineEnd = pos;
      while (lineEnd + 1 < data.length &&
          !(data[lineEnd] == 13 && data[lineEnd + 1] == 10)) {
        lineEnd++;
      }
      final sizeStr =
          latin1.decode(data.sublist(pos, lineEnd)).split(';').first;
      final size = int.tryParse(sizeStr.trim(), radix: 16) ?? 0;
      if (size == 0) break;
      final start = lineEnd + 2;
      out.addAll(data.sublist(start, start + size));
      pos = start + size + 2; // skip trailing CRLF
    }
    return out;
  }
}
