class Config {
  static const String apiBaseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "http://10.0.2.2:8010",
  );

  static const String apiKey = String.fromEnvironment(
    "API_KEY",
    defaultValue: "",
  );
}
