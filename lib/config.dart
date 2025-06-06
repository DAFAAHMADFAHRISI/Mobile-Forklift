class Config {
  // Base URL configuration
  static const String baseUrl =
      'http://192.168.1.10:3000'; // Change this IP address as needed

  // API endpoints
  static String get apiUrl => '$baseUrl/api';

  // WebSocket URL
  static String get wsUrl => 'ws://${baseUrl.split('://')[1]}';
}
