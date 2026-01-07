import Config

config :bolagsverket_ex,
  base_url: "https://gw.api.bolagsverket.se/vardefulla-datamangder/v1",
  request_timeout: 30_000,
  retry_enabled: true,
  max_retries: 3

# Import environment-specific config
import_config "#{config_env()}.exs"
