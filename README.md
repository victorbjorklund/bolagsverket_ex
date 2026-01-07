# BolagsverketEx

[![Hex.pm](https://img.shields.io/hexpm/v/bolagsverket_ex.svg)](https://hex.pm/packages/bolagsverket_ex)
[![Documentation](https://img.shields.io/badge/docs-hexdocs-blue.svg)](https://hexdocs.pm/bolagsverket_ex)

Elixir client library for the Swedish Bolagsverket (Company Registration Office) API. Access comprehensive company information, annual reports, and related documentation through a clean, idiomatic Elixir interface.

## Disclaimer

This is a very early version of the library, and it's very likely that the API and other things will change in future versions. So use at your own risk. 

## Features

- 🏢 **Retrieve company information** - Full company data including names, addresses, legal forms, and business activities
- 📄 **List annual reports** - Get all available annual reports for any Swedish company
- 📥 **Download documents** - Download annual reports as ZIP files
- 🔐 **Automatic OAuth2 authentication** - Token management handled transparently
- 🔄 **Automatic retries** - Built-in retry logic for transient failures
- ✅ **Comprehensive error handling** - Detailed error types with actionable messages
- 📚 **Full type specifications** - Complete @spec annotations for all public functions
- 🧪 **Well tested** - Comprehensive test coverage with doctests

## Installation

Add `bolagsverket_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bolagsverket_ex, "~> 0.1.0"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Quick Start

### 1. Configure Your Credentials

The library uses the **production environment** by default. Set up your OAuth2 credentials:

```bash
# For production environment (default)
export BOLAGSVERKET_CLIENT_ID="your_client_id"
export BOLAGSVERKET_CLIENT_SECRET="your_client_secret"
```

The `config/dev.exs` is already configured for the production environment:

```elixir
# config/dev.exs (already configured for production)
config :bolagsverket_ex,
  client_id: System.get_env("BOLAGSVERKET_CLIENT_ID"),
  client_secret: System.get_env("BOLAGSVERKET_CLIENT_SECRET"),
  token_url: "https://portal.api.bolagsverket.se/oauth2/token",
  base_url: "https://gw.api.bolagsverket.se/vardefulla-datamangder/v1",
  scope: "vardefulla-datamangder:read vardefulla-datamangder:ping"
```

To use the **test environment** instead, override the URLs with environment variables:

```bash
export BOLAGSVERKET_TOKEN_URL="https://portal-accept2.api.bolagsverket.se/oauth2/token"
export BOLAGSVERKET_BASE_URL="https://gw-accept2.api.bolagsverket.se/vardefulla-datamangder/v1"
```

### 2. Use the API

```elixir
# Check API health
{:ok, "OK"} = BolagsverketEx.health_check()

# Get company information
{:ok, response} = BolagsverketEx.get_organisation("5592193030")
[org | _] = response.organisationer

IO.inspect(org.organisationsnamn)
IO.inspect(org.organisationsform)

# List available annual reports
{:ok, documents} = BolagsverketEx.list_documents("5299999994")

Enum.each(documents.dokument, fn doc ->
  IO.puts("Document: #{doc.dokument_id}")
end)

# Download a document
[first_doc | _] = documents.dokument
{:ok, zip_data} = BolagsverketEx.get_document(first_doc.dokument_id)
File.write!("annual_report.zip", zip_data)
```

## API Overview

### Available Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `health_check/1` | Check API availability | `{:ok, String.t()}` |
| `get_organisation/2` | Retrieve company data by org number | `{:ok, OrganisationResponse.t()}` |
| `list_documents/2` | List available annual reports | `{:ok, DocumentListResponse.t()}` |
| `get_document/2` | Download annual report (ZIP file) | `{:ok, binary()}` |

All functions return `{:ok, result}` on success or `{:error, Error.t()}` on failure.

### Error Handling

```elixir
case BolagsverketEx.get_organisation("5299999994") do
  {:ok, response} ->
    # Process response
    IO.puts("Success!")

  {:error, %BolagsverketEx.Error{type: :validation_error, message: msg}} ->
    IO.puts("Invalid input: #{msg}")

  {:error, %BolagsverketEx.Error{type: :auth_error, message: msg}} ->
    IO.puts("Authentication failed: #{msg}")

  {:error, %BolagsverketEx.Error{type: :api_error, api_error: api_error}} ->
    IO.puts("API error: #{api_error.title}")

  {:error, error} ->
    IO.puts("Error: #{error.message}")
end
```

## Documentation

Comprehensive documentation is available:

- **[Getting Started Guide](guides/getting_started.md)** - Installation and basic usage
- **[Authentication Guide](guides/authentication.md)** - OAuth2 configuration and security
- **[Usage Guide](guides/usage.md)** - Detailed examples and patterns
- **[API Documentation](https://hexdocs.pm/bolagsverket_ex)** - Complete module and function reference

Generate local documentation:

```bash
mix docs
open doc/index.html
```

## Environments

BolagsverketEx uses the **production environment** by default: `https://gw.api.bolagsverket.se`

To use the **test/acceptance environment**, override the URLs:

```bash
export BOLAGSVERKET_TOKEN_URL="https://portal-accept2.api.bolagsverket.se/oauth2/token"
export BOLAGSVERKET_BASE_URL="https://gw-accept2.api.bolagsverket.se/vardefulla-datamangder/v1"
```

See [ENVIRONMENTS.md](ENVIRONMENTS.md) for detailed configuration.

## Configuration Options

All configuration options:

```elixir
config :bolagsverket_ex,
  # Required
  client_id: System.get_env("BOLAGSVERKET_CLIENT_ID"),
  client_secret: System.get_env("BOLAGSVERKET_CLIENT_SECRET"),
  token_url: "https://portal.api.bolagsverket.se/oauth2/token",  # Production
  base_url: "https://gw.api.bolagsverket.se/vardefulla-datamangder/v1",

  # Optional
  scope: "vardefulla-datamangder:read vardefulla-datamangder:ping",  # OAuth2 scopes
  request_timeout: 30_000,                # Request timeout (ms)
  retry_enabled: true,                    # Enable automatic retries
  max_retries: 3                          # Maximum retry attempts
```

## Examples

### Retrieve Company Information

```elixir
{:ok, response} = BolagsverketEx.get_organisation("5592193030")
[org | _] = response.organisationer

# Access company data
org.organisationsidentitet.identitetsbeteckning  # "5592193030"
org.organisationsform.klartext                   # "Aktiebolag"
org.organisationsdatum.registreringsdatum        # "2000-01-23"
```

### Download All Annual Reports

```elixir
{:ok, list_response} = BolagsverketEx.list_documents("5592193030")

Enum.each(list_response.dokument, fn doc ->
  {:ok, zip_data} = BolagsverketEx.get_document(doc.dokument_id)
  File.write!("reports/#{doc.dokument_id}.zip", zip_data)
  IO.puts("Downloaded: #{doc.dokument_id}")
end)
```

### Process Multiple Companies

```elixir
org_numbers = ["5299999994", "5565946642", "5566271764"]

results = Task.async_stream(
  org_numbers,
  fn org_number ->
    BolagsverketEx.get_organisation(org_number)
  end,
  max_concurrency: 5
)
|> Enum.to_list()
```

## Development

```bash
# Install dependencies
mix deps.get

# Run tests
mix test

# Format code
mix format

# Run static analysis
mix credo

# Type checking
mix dialyzer

# Generate documentation
mix docs
```

## API Specification

The complete OpenAPI 3.0.3 specification is available in [`API Spec.yaml`](API%20Spec.yaml).

## Requirements

- Elixir ~> 1.18
- Bolagsverket API credentials (OAuth2 client ID and secret)

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues, questions, or feature requests:

- Open an issue on [GitHub](https://github.com/yourusername/bolagsverket_ex/issues)
- Check the [documentation](https://hexdocs.pm/bolagsverket_ex)
- Review the guides:
  - [Getting Started](guides/getting_started.md)
  - [Authentication](guides/authentication.md)
  - [Usage Examples](guides/usage.md)

## Acknowledgments

This library interfaces with the Swedish Bolagsverket (Companies Registration Office) API. For more information about the API itself, visit [Bolagsverket's developer portal](https://www.bolagsverket.se).

---

Made with ❤️ for the Elixir community