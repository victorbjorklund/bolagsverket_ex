# Environment Configuration

BolagsverketEx uses the **production environment** by default. You can override this by setting environment variables.

## Production Environment (Default)

The production environment accesses live company data.

**URLs:**
- Token URL: `https://portal.api.bolagsverket.se/oauth2/token`
- Base URL: `https://gw.api.bolagsverket.se/vardefulla-datamangder/v1`

This is the default for all Mix environments (`:dev`, `:test`, `:prod`).

## Test Environment (Accept2)

The test environment is for development and testing without affecting production data.

**URLs:**
- Token URL: `https://portal-accept2.api.bolagsverket.se/oauth2/token`
- Base URL: `https://gw-accept2.api.bolagsverket.se/vardefulla-datamangder/v1`

To use the test environment, override the URLs with environment variables (see below).

## Configuration

### Default (Production)

```elixir
# config/dev.exs (and runtime.exs)
config :bolagsverket_ex,
  client_id: System.get_env("BOLAGSVERKET_CLIENT_ID"),
  client_secret: System.get_env("BOLAGSVERKET_CLIENT_SECRET"),
  token_url: System.get_env("BOLAGSVERKET_TOKEN_URL", "https://portal.api.bolagsverket.se/oauth2/token"),
  base_url: System.get_env("BOLAGSVERKET_BASE_URL", "https://gw.api.bolagsverket.se/vardefulla-datamangder/v1"),
  scope: "vardefulla-datamangder:read vardefulla-datamangder:ping"
```

## Switching to Test Environment

Override the URLs with environment variables:

```bash
# Set test environment URLs
export BOLAGSVERKET_TOKEN_URL="https://portal-accept2.api.bolagsverket.se/oauth2/token"
export BOLAGSVERKET_BASE_URL="https://gw-accept2.api.bolagsverket.se/vardefulla-datamangder/v1"

# Set test credentials
export BOLAGSVERKET_CLIENT_ID="your_test_client_id"
export BOLAGSVERKET_CLIENT_SECRET="your_test_client_secret"
```

## Usage Examples

### Production Environment (Default)

```bash
# Set production credentials
export BOLAGSVERKET_CLIENT_ID="your_prod_client_id"
export BOLAGSVERKET_CLIENT_SECRET="your_prod_client_secret"

# Start IEx
iex -S mix

# Verify configuration
iex> BolagsverketEx.Config.get(:token_url)
"https://portal.api.bolagsverket.se/oauth2/token"

# Test API with real organization number
iex> BolagsverketEx.get_organisation("5592193030")
{:ok, %BolagsverketEx.Schemas.OrganisationResponse{...}}
```

### Test Environment

```bash
# Set test environment URLs
export BOLAGSVERKET_TOKEN_URL="https://portal-accept2.api.bolagsverket.se/oauth2/token"
export BOLAGSVERKET_BASE_URL="https://gw-accept2.api.bolagsverket.se/vardefulla-datamangder/v1"

# Set test credentials
export BOLAGSVERKET_CLIENT_ID="your_test_client_id"
export BOLAGSVERKET_CLIENT_SECRET="your_test_client_secret"

# Start IEx
iex -S mix

# Verify configuration
iex> BolagsverketEx.Config.get(:token_url)
"https://portal-accept2.api.bolagsverket.se/oauth2/token"

# Test API
iex> BolagsverketEx.health_check()
{:ok, "OK"}
```

## Credentials Management

You'll need **separate credentials** for each environment:

### Test Environment Credentials
- Obtain from Bolagsverket test/accept environment portal
- Use for development and testing
- Safe to experiment with

### Production Credentials
- Obtain from Bolagsverket production portal
- Use only for production deployments
- Handle with care - accesses live data

## Environment Variables Summary

| Variable | Description | Default |
|----------|-------------|---------|
| `BOLAGSVERKET_CLIENT_ID` | OAuth2 client ID (required) | - |
| `BOLAGSVERKET_CLIENT_SECRET` | OAuth2 client secret (required) | - |
| `BOLAGSVERKET_TOKEN_URL` | OAuth2 token endpoint | `https://portal.api.bolagsverket.se/oauth2/token` |
| `BOLAGSVERKET_BASE_URL` | API base URL | `https://gw.api.bolagsverket.se/vardefulla-datamangder/v1` |

## Deployment Examples

### Heroku (Production - Default)

```bash
heroku config:set BOLAGSVERKET_CLIENT_ID=your_prod_client_id
heroku config:set BOLAGSVERKET_CLIENT_SECRET=your_prod_client_secret
```

### Heroku (Test Environment)

```bash
heroku config:set BOLAGSVERKET_TOKEN_URL=https://portal-accept2.api.bolagsverket.se/oauth2/token
heroku config:set BOLAGSVERKET_BASE_URL=https://gw-accept2.api.bolagsverket.se/vardefulla-datamangder/v1
heroku config:set BOLAGSVERKET_CLIENT_ID=your_test_client_id
heroku config:set BOLAGSVERKET_CLIENT_SECRET=your_test_client_secret
```

### Docker

```dockerfile
# Production environment (default)
ENV BOLAGSVERKET_CLIENT_ID=your_prod_client_id
ENV BOLAGSVERKET_CLIENT_SECRET=your_prod_client_secret

# OR Test environment
ENV BOLAGSVERKET_TOKEN_URL=https://portal-accept2.api.bolagsverket.se/oauth2/token
ENV BOLAGSVERKET_BASE_URL=https://gw-accept2.api.bolagsverket.se/vardefulla-datamangder/v1
ENV BOLAGSVERKET_CLIENT_ID=your_test_client_id
ENV BOLAGSVERKET_CLIENT_SECRET=your_test_client_secret
```

### Kubernetes Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: bolagsverket-credentials
type: Opaque
stringData:
  # Production (default)
  client_id: "your_prod_client_id"
  client_secret: "your_prod_client_secret"

  # For test environment, add:
  # token_url: "https://portal-accept2.api.bolagsverket.se/oauth2/token"
  # base_url: "https://gw-accept2.api.bolagsverket.se/vardefulla-datamangder/v1"
```

## Best Practices

1. **Always use test environment for development**
   - Default configuration uses test environment
   - Prevents accidental production data access

2. **Keep credentials separate**
   - Different credentials for test and production
   - Never use production credentials in development

3. **Use environment variables**
   - Don't hardcode credentials
   - Use `.env` files for local development (add to `.gitignore`)

4. **Verify configuration before deployment**
   ```elixir
   # In IEx or during application startup
   BolagsverketEx.Config.validate!()
   BolagsverketEx.Config.get_all() |> IO.inspect()
   ```

5. **Test against test environment first**
   - Validate your integration with test API
   - Only switch to production after thorough testing
