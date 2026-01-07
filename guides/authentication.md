# Authentication Guide

BolagsverketEx uses OAuth2 client credentials flow for authentication with the Bolagsverket API. This guide explains how to configure and manage authentication.

## OAuth2 Client Credentials Flow

The library automatically handles OAuth2 authentication for you:

1. **Token Request**: On first API call, the library requests an access token using your credentials
2. **Token Caching**: The token is cached in memory with its expiration time
3. **Automatic Refresh**: When the token expires, a new one is automatically requested
4. **Token Injection**: Every API request includes the token in the Authorization header

You only need to configure your credentials - the library handles everything else.

## Configuration

### Development Environment

For local development, configure credentials in `config/dev.exs`:

```elixir
import Config

config :bolagsverket_ex,
  client_id: System.get_env("BOLAGSVERKET_CLIENT_ID"),
  client_secret: System.get_env("BOLAGSVERKET_CLIENT_SECRET"),
  token_url: "https://gw.api.bolagsverket.se/oauth2/token",
  base_url: "https://gw.api.bolagsverket.se/vardefulla-datamangder/v1",
  scope: "vardefulla-datamangder:read"
```

Set environment variables in your shell:

```bash
export BOLAGSVERKET_CLIENT_ID="your_client_id_here"
export BOLAGSVERKET_CLIENT_SECRET="your_client_secret_here"
```

Or use a `.env` file (don't commit this to git!):

```bash
# .env
BOLAGSVERKET_CLIENT_ID=your_client_id_here
BOLAGSVERKET_CLIENT_SECRET=your_client_secret_here
```

Load it with a tool like [dotenvy](https://github.com/avvo/dotenvy):

```bash
source .env
iex -S mix
```

### Production Environment

For production deployments, use `config/runtime.exs` which is evaluated at runtime:

```elixir
import Config

if config_env() == :prod do
  config :bolagsverket_ex,
    client_id: System.fetch_env!("BOLAGSVERKET_CLIENT_ID"),
    client_secret: System.fetch_env!("BOLAGSVERKET_CLIENT_SECRET"),
    token_url: System.get_env(
      "BOLAGSVERKET_TOKEN_URL",
      "https://gw.api.bolagsverket.se/oauth2/token"
    ),
    base_url: System.get_env(
      "BOLAGSVERKET_BASE_URL",
      "https://gw.api.bolagsverket.se/vardefulla-datamangder/v1"
    )
end
```

Using `System.fetch_env!/1` ensures the application fails fast if required environment variables are missing.

### Test Environment

For testing, configure in `config/test.exs`:

```elixir
import Config

config :bolagsverket_ex,
  # Use test credentials or mock values
  client_id: "test_client_id",
  client_secret: "test_client_secret",
  # Point to your test environment or use Bypass for mocking
  token_url: "http://localhost:8080/oauth2/token",
  base_url: "http://localhost:8080"
```

## Configuration Options

### Required Options

- **`client_id`** - OAuth2 client ID provided by Bolagsverket
- **`client_secret`** - OAuth2 client secret provided by Bolagsverket
- **`token_url`** - OAuth2 token endpoint URL
- **`base_url`** - Bolagsverket API base URL

### Optional Options

- **`scope`** - OAuth2 scope (default: `"vardefulla-datamangder:read"`)
- **`request_timeout`** - Request timeout in milliseconds (default: `30_000`)
- **`retry_enabled`** - Enable automatic retries (default: `true`)
- **`max_retries`** - Maximum number of retries (default: `3`)

Example with all options:

```elixir
config :bolagsverket_ex,
  # Required
  client_id: System.get_env("BOLAGSVERKET_CLIENT_ID"),
  client_secret: System.get_env("BOLAGSVERKET_CLIENT_SECRET"),
  token_url: "https://gw.api.bolagsverket.se/oauth2/token",
  base_url: "https://gw.api.bolagsverket.se/vardefulla-datamangder/v1",

  # Optional
  scope: "vardefulla-datamangder:read vardefulla-datamangder:ping",
  request_timeout: 60_000,
  retry_enabled: true,
  max_retries: 5
```

## Token Management

### Token Caching

Tokens are cached in memory using an Agent process:

- **Cache Duration**: Tokens are cached until expiration (minus 60-second safety buffer)
- **Automatic Refresh**: Expired tokens are automatically refreshed on next API call
- **Process Lifecycle**: The cache is part of the application supervision tree
- **No Persistence**: Tokens are not persisted to disk for security

### Manual Token Refresh

In most cases, you don't need to manually manage tokens. However, if needed:

```elixir
# Clear the cached token (forces refresh on next request)
BolagsverketEx.TokenCache.clear()

# Next API call will fetch a new token
{:ok, response} = BolagsverketEx.get_organisation("5299999994")
```

### Inspecting Token State

For debugging, you can check the current token state:

```elixir
# Get the cached token if valid
case BolagsverketEx.TokenCache.get_token() do
  {:ok, token} ->
    IO.puts("Valid token cached")

  {:error, :expired} ->
    IO.puts("No valid token in cache")
end
```

## OAuth2 Scopes

The Bolagsverket API requires specific scopes for different operations:

| Scope | Description | Required For |
|-------|-------------|--------------|
| `vardefulla-datamangder:read` | Read company and document data | `get_organisation/2`, `list_documents/2`, `get_document/2` |
| `vardefulla-datamangder:ping` | Health check access | `health_check/1` |

Request all needed scopes in your configuration:

```elixir
config :bolagsverket_ex,
  scope: "vardefulla-datamangder:read vardefulla-datamangder:ping"
```

## Security Best Practices

### 1. Never Hardcode Credentials

❌ **Don't do this:**
```elixir
config :bolagsverket_ex,
  client_id: "abc123",  # Never hardcode!
  client_secret: "secret123"  # Never hardcode!
```

✅ **Do this instead:**
```elixir
config :bolagsverket_ex,
  client_id: System.get_env("BOLAGSVERKET_CLIENT_ID"),
  client_secret: System.get_env("BOLAGSVERKET_CLIENT_SECRET")
```

### 2. Use Environment Variables

Store credentials as environment variables, not in configuration files:

```bash
# In production (e.g., Heroku, Fly.io)
heroku config:set BOLAGSVERKET_CLIENT_ID=your_id
heroku config:set BOLAGSVERKET_CLIENT_SECRET=your_secret

# In Docker
docker run -e BOLAGSVERKET_CLIENT_ID=your_id -e BOLAGSVERKET_CLIENT_SECRET=your_secret ...
```

### 3. Use Secrets Management

For production, consider using secrets management tools:

- **AWS Secrets Manager**
- **Google Secret Manager**
- **HashiCorp Vault**
- **Kubernetes Secrets**

Example with AWS Secrets Manager:

```elixir
# config/runtime.exs
if config_env() == :prod do
  {:ok, secrets} = ExAws.SecretsManager.get_secret_value("bolagsverket-api")
  |> ExAws.request()

  credentials = Jason.decode!(secrets["SecretString"])

  config :bolagsverket_ex,
    client_id: credentials["client_id"],
    client_secret: credentials["client_secret"]
end
```

### 4. Protect Configuration Files

Add sensitive files to `.gitignore`:

```gitignore
# .gitignore
.env
.env.*
config/*.secret.exs
```

### 5. Rotate Credentials Regularly

Periodically rotate your OAuth2 credentials and update your environment:

1. Generate new credentials in Bolagsverket portal
2. Update environment variables
3. Restart your application
4. Revoke old credentials

## Troubleshooting

### Authentication Failed Errors

If you see authentication errors:

```elixir
{:error, %BolagsverketEx.Error{type: :auth_error, message: "OAuth2 token request failed..."}}
```

**Check:**

1. **Credentials are correct**: Verify `client_id` and `client_secret`
2. **Credentials are loaded**: `BolagsverketEx.Config.get(:client_id)`
3. **Token URL is correct**: Should be `https://gw.api.bolagsverket.se/oauth2/token`
4. **Network connectivity**: Can you reach the token endpoint?
5. **Credentials are active**: They haven't been revoked in Bolagsverket portal

### Validate Configuration

Check your configuration is loaded correctly:

```elixir
# In IEx
iex> BolagsverketEx.Config.get_all()
%{
  client_id: "your_client_id",
  client_secret: "your_client_secret",
  token_url: "https://...",
  base_url: "https://...",
  scope: "vardefulla-datamangder:read",
  # ...
}

# Validate required config is present
iex> BolagsverketEx.Config.validate!()
:ok
```

### Missing Configuration Error

If configuration is missing:

```elixir
{:error, %BolagsverketEx.Error{type: :config_error, message: "Missing OAuth2 configuration..."}}
```

Ensure all required configuration is set:

```elixir
# Check each required value
IO.inspect(BolagsverketEx.Config.get(:client_id), label: "Client ID")
IO.inspect(BolagsverketEx.Config.get(:client_secret), label: "Client Secret")
IO.inspect(BolagsverketEx.Config.get(:token_url), label: "Token URL")
IO.inspect(BolagsverketEx.Config.get(:base_url), label: "Base URL")
```

## Next Steps

- Read the [Usage Guide](usage.md) for API examples
- Explore the `BolagsverketEx.Config` module documentation
- Check the `BolagsverketEx.Error` module for error types
