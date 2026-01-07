# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Elixir library for interacting with the Swedish Company Registration Office (Bolagsverket) API. The API allows retrieval of company information, annual reports, and related documentation.

## Development Commands

```bash
# Install dependencies
mix deps.get

# Run tests
mix test

# Run a specific test file
mix test test/bolagsverket_ex_test.exs

# Run a specific test
mix test test/bolagsverket_ex_test.exs:5

# Format code
mix format

# Check formatting without changing files
mix format --check-formatted

# Compile the project
mix compile

# Start an interactive shell with the project loaded
iex -S mix
```

## Architecture

### API Specification
The complete API specification is provided in `API Spec.yaml` (OpenAPI 3.0.3 format). Reference this file when implementing API endpoints.

### Main API Endpoints
The Bolagsverket API (`https://gw.api.bolagsverket.se/vardefulla-datamangder/v1`) provides:

- **`POST /organisationer`**: Retrieve company data by organization number
- **`POST /dokumentlista`**: Get list of available annual reports for a company
- **`GET /dokument/{dokumentId}`**: Download a specific annual report (returns ZIP)
- **`GET /isalive`**: Health check endpoint

All endpoints except `/isalive` require OAuth2 authentication with appropriate scopes.

### Project Structure
The library is in early stages with a single main module at `lib/bolagsverket_ex.ex`. When implementing the API client:

- Main API client logic should live in `lib/bolagsverket_ex.ex`
- Consider creating modules under `lib/bolagsverket_ex/` for different API concerns (e.g., organizations, documents, auth)
- Request/response schemas from the OpenAPI spec should guide struct definitions
- HTTP client dependency will need to be added to `mix.exs` when implementing API calls

### Testing
- Tests are in `test/bolagsverket_ex_test.exs`
- Use ExUnit for testing
- Doctests are enabled via `doctest BolagsverketEx`
- Consider mocking HTTP requests in tests

### Configuration
- Elixir version: ~> 1.18
- Code formatting rules: `.formatter.exs` (formats files in `lib/`, `test/`, and config)
- Currently no external dependencies defined in `mix.exs`
