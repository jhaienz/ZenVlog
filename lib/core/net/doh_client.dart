import 'dart:convert';
import 'dart:io';

/// Fallback HTTP POST for networks whose DNS blocks specific domains
/// (carrier DNS filtering — browser works via its own DoH, app doesn't).
///
/// Resolves the host via Cloudflare DNS-over-HTTPS at the IP literal
/// 1.1.1.1 (no DNS lookup needed), then connects to the resolved IP and
/// upgrades to TLS with SNI + certificate validation against the real
/// hostname via [SecureSocket.secure].
class DohClient {
  static Future<String> resolve(String host) async {
    final client = HttpClient();
    try {
      final req = await client
          .getUrl(Uri.parse('https://1.1.1.1/dns-query?name=$host&type=A'))
          .timeout(const Duration(seconds: 10));
      req.headers.set('accept', 'application/dns-json');
      final res = await req.close().timeout(const Duration(seconds: 10));
      final body = await res.transform(utf8.decoder).join();
      final answers = (jsonDecode(body)['Answer'] as List?) ?? [];
      final a = answers.cast<Map<String, dynamic>>().firstWhere(
            (r) => r['type'] == 1, // A record
            orElse: () => throw Exception('No A record for $host via DoH'),
          );
      return a['data'] as String;
    } finally {
      client.close(force: true);
    }
  }

  /// POSTs [formBody] (form-urlencoded) to https://[host][path] using
  /// [ip] for the TCP connection. HTTP/1.1 with Connection: close;
  /// handles chunked transfer-encoding. Returns response body.
  /// Throws on non-200.
  static Future<String> postViaIp({
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
      if (raw[i] == 13 && raw[i + 1] == 10 && raw[i + 2] == 13 && raw[i + 3] == 10) {
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
      final sizeStr = latin1.decode(data.sublist(pos, lineEnd)).split(';').first;
      final size = int.tryParse(sizeStr.trim(), radix: 16) ?? 0;
      if (size == 0) break;
      final start = lineEnd + 2;
      out.addAll(data.sublist(start, start + size));
      pos = start + size + 2; // skip trailing CRLF
    }
    return out;
  }
}
