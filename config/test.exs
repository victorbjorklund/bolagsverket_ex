import Config

config :bolagsverket_ex,
  # Use test/accept environment or mock credentials for tests
  # Set BOLAGSVERKET_USE_REAL_API=true to test against real test API
  client_id: System.get_env("BOLAGSVERKET_CLIENT_ID", "test_client_id"),
  client_secret: System.get_env("BOLAGSVERKET_CLIENT_SECRET", "test_client_secret"),
  token_url:
    System.get_env(
      "BOLAGSVERKET_TOKEN_URL",
      "https://portal-accept2.api.bolagsverket.se/oauth2/token"
    ),
  base_url:
    System.get_env(
      "BOLAGSVERKET_BASE_URL",
      "https://gw-accept2.api.bolagsverket.se/vardefulla-datamangder/v1"
    ),
  scope: "vardefulla-datamangder:read vardefulla-datamangder:ping"
