import Config

# Production environment by default
# Override with BOLAGSVERKET_TOKEN_URL and BOLAGSVERKET_BASE_URL to use test environment
config :bolagsverket_ex,
  client_id: System.get_env("BOLAGSVERKET_CLIENT_ID"),
  client_secret: System.get_env("BOLAGSVERKET_CLIENT_SECRET"),
  token_url:
    System.get_env(
      "BOLAGSVERKET_TOKEN_URL",
      "https://portal.api.bolagsverket.se/oauth2/token"
    ),
  base_url:
    System.get_env(
      "BOLAGSVERKET_BASE_URL",
      "https://gw.api.bolagsverket.se/vardefulla-datamangder/v1"
    ),
  scope: "vardefulla-datamangder:read vardefulla-datamangder:ping"
