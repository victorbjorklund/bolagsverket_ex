# Getting Started

Welcome to BolagsverketEx! This guide will help you get started with using the Swedish Bolagsverket (Company Registration Office) API client library.

## What is BolagsverketEx?

BolagsverketEx is an Elixir client library for the Bolagsverket Värdefulla datamängder API. It provides a clean, idiomatic interface to:

- Retrieve comprehensive company information
- List available annual reports for companies
- Download annual report documents
- Check API health status

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

## Prerequisites

Before using BolagsverketEx, you'll need:

1. **Bolagsverket API credentials**: You must register for API access with Bolagsverket and obtain OAuth2 client credentials (client ID and client secret).

2. **API access permissions**: Ensure your account has the required scopes:
   - `vardefulla-datamangder:read` - For accessing company and document data
   - `vardefulla-datamangder:ping` - For health check endpoint

## Quick Start

### 1. Configure Your Credentials

Create or update your `config/config.exs`:

```elixir
import Config

config :bolagsverket_ex,
  client_id: System.get_env("BOLAGSVERKET_CLIENT_ID"),
  client_secret: System.get_env("BOLAGSVERKET_CLIENT_SECRET"),
  token_url: "https://gw.api.bolagsverket.se/oauth2/token",
  base_url: "https://gw.api.bolagsverket.se/vardefulla-datamangder/v1"
```

Set your environment variables:

```bash
export BOLAGSVERKET_CLIENT_ID="your_client_id"
export BOLAGSVERKET_CLIENT_SECRET="your_client_secret"
```

### 2. Test the Connection

Start an IEx session and test the health check:

```elixir
iex -S mix

# Check if the API is available
{:ok, status} = BolagsverketEx.health_check()
IO.puts("API Status: #{status}")
# => API Status: OK
```

### 3. Retrieve Company Information

Fetch data for a Swedish company using their organisation number:

```elixir
# Get organisation data
{:ok, response} = BolagsverketEx.get_organisation("5299999994")

# Access the first organisation
[org | _] = response.organisationer

# Display company name
IO.inspect(org.organisationsnamn)

# Display company address
IO.inspect(org.postadress_organisation)
```

### 4. List and Download Annual Reports

```elixir
# List available annual reports
{:ok, documents} = BolagsverketEx.list_documents("5299999994")

# Show available documents
Enum.each(documents.dokument, fn doc ->
  IO.puts("Document ID: #{doc.dokument_id}")
  IO.puts("Format: #{doc.filformat}")
  IO.puts("Reporting Period: #{doc.rapporteringsperiod_tom}")
  IO.puts("---")
end)

# Download a specific document
[first_doc | _] = documents.dokument
{:ok, zip_data} = BolagsverketEx.get_document(first_doc.dokument_id)

# Save to file
File.write!("annual_report.zip", zip_data)
```

## Error Handling

All API functions return `{:ok, result}` on success or `{:error, error}` on failure:

```elixir
case BolagsverketEx.get_organisation("5299999994") do
  {:ok, response} ->
    IO.puts("Successfully retrieved company data!")

  {:error, %BolagsverketEx.Error{type: :validation_error, message: msg}} ->
    IO.puts("Invalid input: #{msg}")

  {:error, %BolagsverketEx.Error{type: :auth_error, message: msg}} ->
    IO.puts("Authentication failed: #{msg}")

  {:error, %BolagsverketEx.Error{type: :api_error, message: msg}} ->
    IO.puts("API error: #{msg}")

  {:error, error} ->
    IO.puts("Unexpected error: #{inspect(error)}")
end
```

## Next Steps

- Read the [Authentication Guide](authentication.md) for detailed OAuth2 configuration
- Check out the [Usage Guide](usage.md) for comprehensive examples
- Explore the API documentation for all available functions

## API Endpoints

BolagsverketEx provides access to these Bolagsverket API endpoints:

| Function | Endpoint | Description |
|----------|----------|-------------|
| `health_check/1` | `GET /isalive` | Check API availability |
| `get_organisation/2` | `POST /organisationer` | Retrieve company data |
| `list_documents/2` | `POST /dokumentlista` | List annual reports |
| `get_document/2` | `GET /dokument/{id}` | Download annual report |

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/yourusername/bolagsverket_ex).
