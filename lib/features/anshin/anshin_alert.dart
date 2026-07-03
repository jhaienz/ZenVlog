enum AlertSeverity { warning, danger }

enum AlertType { weather, hazard, barometer, staleData }

class AnshinAlert {
  final AlertType type;
  final String message;
  final AlertSeverity severity;
  final DateTime createdAt;

  const AnshinAlert({
    required this.type,
    required this.message,
    required this.severity,
    required this.createdAt,
  });
}
