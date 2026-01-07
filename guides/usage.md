# Usage Guide

This guide provides comprehensive examples for using the BolagsverketEx library to interact with the Swedish Bolagsverket API.

## Table of Contents

- [Health Check](#health-check)
- [Retrieving Company Information](#retrieving-company-information)
- [Listing Annual Reports](#listing-annual-reports)
- [Downloading Documents](#downloading-documents)
- [Error Handling](#error-handling)
- [Advanced Usage](#advanced-usage)
- [Common Patterns](#common-patterns)

## Health Check

Verify the API is available before making requests:

```elixir
# Simple health check
{:ok, status} = BolagsverketEx.health_check()
IO.puts("API Status: #{status}")
# => API Status: OK
```

With custom options:

```elixir
# Health check with timeout
{:ok, status} = BolagsverketEx.health_check(timeout: 5000)

# Health check with custom request ID
{:ok, status} = BolagsverketEx.health_check(request_id: "my-custom-id-123")
```

## Retrieving Company Information

### Basic Company Lookup

Retrieve information about a company using their organisation number:

```elixir
# Lookup by 10-digit organisation number
{:ok, response} = BolagsverketEx.get_organisation("5299999994")

# Access the organisations list
organisationer = response.organisationer

# Get the first organisation
[org | _] = organisationer
```

### Accessing Company Data

The `Organisation` struct contains comprehensive company information:

```elixir
{:ok, response} = BolagsverketEx.get_organisation("5299999994")
[org | _] = response.organisationer

# Company identity
identitet = org.organisationsidentitet
IO.puts("Org Number: #{identitet.identitetsbeteckning}")

# Company names
if org.organisationsnamn do
  Enum.each(org.organisationsnamn.organisationsnamn_lista, fn namn ->
    IO.puts("Name: #{namn.namn}")
    IO.puts("Type: #{namn.organisationsnamntyp.klartext}")
    IO.puts("Registered: #{namn.registreringsdatum}")
  end)
end

# Company form
if org.organisationsform do
  IO.puts("Form: #{org.organisationsform.klartext} (#{org.organisationsform.kod})")
end

# Legal form
if org.juridisk_form do
  IO.puts("Legal Form: #{org.juridisk_form.klartext}")
end

# Registration dates
if org.organisationsdatum do
  IO.puts("Registered: #{org.organisationsdatum.registreringsdatum}")
end

# Business activity
if org.verksamhetsbeskrivning do
  IO.puts("Activity: #{org.verksamhetsbeskrivning.beskrivning}")
end

# Industry classification (SNI codes)
if org.naringsgren_organisation do
  Enum.each(org.naringsgren_organisation.sni, fn sni ->
    IO.puts("SNI: #{sni.kod} - #{sni.klartext}")
  end)
end

# Postal address
if org.postadress_organisation && org.postadress_organisation.postadress do
  addr = org.postadress_organisation.postadress
  IO.puts("Address: #{addr.utdelningsadress}")
  IO.puts("Postal Code: #{addr.postnummer}")
  IO.puts("City: #{addr.postort}")
  IO.puts("Country: #{addr.land}")
end

# Active status
if org.verksam_organisation do
  active = org.verksam_organisation.kod == :ja
  IO.puts("Active: #{active}")
end

# Deregistration info
if org.avregistrerad_organisation do
  IO.puts("Deregistered: #{org.avregistrerad_organisation.avregistreringsdatum}")
  if org.avregistreringsorsak do
    IO.puts("Reason: #{org.avregistreringsorsak.klartext}")
  end
end

# Ongoing liquidation/restructuring
if org.pagaende_avveckling_eller_omstrukturering do
  lista = org.pagaende_avveckling_eller_omstrukturering.pagaende_avveckling_eller_omstruktureringsforfarande_lista
  Enum.each(lista, fn proc ->
    IO.puts("Procedure: #{proc.klartext} (from #{proc.from_datum})")
  end)
end
```

### Multiple Companies (Sole Traders)

Some organisation numbers can have multiple companies (e.g., sole traders with multiple business names):

```elixir
{:ok, response} = BolagsverketEx.get_organisation("194009272719")

IO.puts("Found #{length(response.organisationer)} companies")

Enum.each(response.organisationer, fn org ->
  # Each company has a unique namnskyddslopnummer
  IO.puts("Name Protection Number: #{org.namnskyddslopnummer}")

  if org.organisationsnamn do
    [namn | _] = org.organisationsnamn.organisationsnamn_lista
    IO.puts("Name: #{namn.namn}")
  end

  IO.puts("---")
end)
```

### Handling Missing Data

Not all fields are always present. Check for `nil` values:

```elixir
{:ok, response} = BolagsverketEx.get_organisation("5299999994")
[org | _] = response.organisationer

# Safe access with pattern matching
case org.verksamhetsbeskrivning do
  %{beskrivning: description} ->
    IO.puts("Business activity: #{description}")

  nil ->
    IO.puts("No business activity description available")
end

# Safe access with if/else
if org.postadress_organisation do
  IO.puts("Address available")
else
  IO.puts("No address information")
end
```

## Listing Annual Reports

### List All Documents

Get a list of all available annual reports for a company:

```elixir
{:ok, response} = BolagsverketEx.list_documents("5299999994")

IO.puts("Found #{length(response.dokument)} documents")

Enum.each(response.dokument, fn doc ->
  IO.puts("Document ID: #{doc.dokument_id}")
  IO.puts("Format: #{doc.filformat}")

  if doc.rapporteringsperiod_tom do
    IO.puts("Reporting Period End: #{doc.rapporteringsperiod_tom}")
  end

  if doc.registreringstidpunkt do
    IO.puts("Registered: #{doc.registreringstidpunkt}")
  end

  IO.puts("---")
end)
```

### Filtering Documents

Filter documents by criteria:

```elixir
{:ok, response} = BolagsverketEx.list_documents("5299999994")

# Get only PDF documents
pdf_docs = Enum.filter(response.dokument, fn doc ->
  doc.filformat == "pdf"
end)

# Get documents from a specific year
year_2023_docs = Enum.filter(response.dokument, fn doc ->
  case doc.rapporteringsperiod_tom do
    %Date{year: 2023} -> true
    _ -> false
  end
end)

# Get most recent document
most_recent = Enum.max_by(response.dokument, fn doc ->
  doc.registreringstidpunkt || ~D[2000-01-01]
end, Date)
```

### Sorting Documents

Sort documents by different criteria:

```elixir
{:ok, response} = BolagsverketEx.list_documents("5299999994")

# Sort by reporting period (newest first)
sorted_by_period = Enum.sort_by(
  response.dokument,
  fn doc -> doc.rapporteringsperiod_tom end,
  {:desc, Date}
)

# Sort by registration date
sorted_by_registration = Enum.sort_by(
  response.dokument,
  fn doc -> doc.registreringstidpunkt end,
  {:desc, Date}
)
```

## Downloading Documents

### Download and Save

Download a document and save it to disk:

```elixir
# First, list documents to get IDs
{:ok, list_response} = BolagsverketEx.list_documents("5299999994")
[first_doc | _] = list_response.dokument

# Download the document
{:ok, zip_data} = BolagsverketEx.get_document(first_doc.dokument_id)

# Save to file
filename = "annual_report_#{first_doc.dokument_id}.zip"
File.write!(filename, zip_data)

IO.puts("Downloaded #{byte_size(zip_data)} bytes to #{filename}")
```

### Download with Timeout

For large files, increase the timeout:

```elixir
# Download with 2-minute timeout
{:ok, zip_data} = BolagsverketEx.get_document(
  document_id,
  timeout: 120_000
)
```

### Extract ZIP Contents

After downloading, you can extract the ZIP contents:

```elixir
{:ok, zip_data} = BolagsverketEx.get_document(document_id)

# Extract to memory
{:ok, files} = :zip.extract(zip_data, [:memory])

Enum.each(files, fn {filename, content} ->
  IO.puts("File: #{filename}, Size: #{byte_size(content)} bytes")

  # Save individual files
  File.write!("extracted/#{filename}", content)
end)
```

### Batch Download

Download multiple documents:

```elixir
{:ok, list_response} = BolagsverketEx.list_documents("5299999994")

# Download all documents
results = Enum.map(list_response.dokument, fn doc ->
  case BolagsverketEx.get_document(doc.dokument_id) do
    {:ok, zip_data} ->
      filename = "reports/#{doc.dokument_id}.zip"
      File.write!(filename, zip_data)
      {:ok, filename}

    {:error, error} ->
      {:error, doc.dokument_id, error}
  end
end)

# Check results
successful = Enum.count(results, fn
  {:ok, _} -> true
  _ -> false
end)

IO.puts("Downloaded #{successful}/#{length(results)} documents")
```

## Error Handling

### Pattern Matching

Handle different error types with pattern matching:

```elixir
case BolagsverketEx.get_organisation("5299999994") do
  {:ok, response} ->
    IO.puts("Success!")

  {:error, %BolagsverketEx.Error{type: :validation_error, message: msg}} ->
    IO.puts("Invalid organisation number: #{msg}")

  {:error, %BolagsverketEx.Error{type: :auth_error, message: msg}} ->
    IO.puts("Authentication failed: #{msg}")
    IO.puts("Check your client_id and client_secret")

  {:error, %BolagsverketEx.Error{type: :network_error, message: msg}} ->
    IO.puts("Network error: #{msg}")
    IO.puts("Check your internet connection")

  {:error, %BolagsverketEx.Error{type: :api_error, api_error: api_error}} ->
    IO.puts("API error: #{api_error.title}")
    IO.puts("Detail: #{api_error.detail}")
    IO.puts("Status: #{api_error.status}")

  {:error, %BolagsverketEx.Error{type: :timeout_error}} ->
    IO.puts("Request timed out - try again with longer timeout")

  {:error, error} ->
    IO.puts("Unexpected error: #{inspect(error)}")
end
```

### With Pipeline

Use `with` for sequential operations:

```elixir
result = with {:ok, org_response} <- BolagsverketEx.get_organisation("5299999994"),
              [org | _] <- org_response.organisationer,
              {:ok, docs_response} <- BolagsverketEx.list_documents("5299999994"),
              [first_doc | _] <- docs_response.dokument,
              {:ok, zip_data} <- BolagsverketEx.get_document(first_doc.dokument_id) do
  {:ok, {org, zip_data}}
else
  {:error, error} -> {:error, error}
  [] -> {:error, "No data found"}
end

case result do
  {:ok, {org, zip_data}} ->
    IO.puts("Successfully retrieved company and document!")

  {:error, reason} ->
    IO.puts("Failed: #{inspect(reason)}")
end
```

### Retry Logic

The library has built-in retries for transient errors, but you can add your own retry logic:

```elixir
defmodule MyApp.Bolagsverket do
  def get_organisation_with_retry(org_number, max_attempts \\ 3) do
    get_organisation_with_retry(org_number, max_attempts, 1)
  end

  defp get_organisation_with_retry(org_number, max_attempts, attempt) do
    case BolagsverketEx.get_organisation(org_number) do
      {:ok, response} ->
        {:ok, response}

      {:error, %{type: type}} when type in [:network_error, :timeout_error] and attempt < max_attempts ->
        # Wait before retry (exponential backoff)
        Process.sleep(:math.pow(2, attempt) * 1000 |> round())
        get_organisation_with_retry(org_number, max_attempts, attempt + 1)

      {:error, error} ->
        {:error, error}
    end
  end
end

# Usage
{:ok, response} = MyApp.Bolagsverket.get_organisation_with_retry("5299999994")
```

## Advanced Usage

### Custom Request Options

All API functions accept an options keyword list:

```elixir
# Custom request ID for tracking
{:ok, response} = BolagsverketEx.get_organisation(
  "5299999994",
  request_id: "tracking-id-#{System.system_time(:second)}"
)

# Custom timeout
{:ok, response} = BolagsverketEx.get_organisation(
  "5299999994",
  timeout: 60_000  # 60 seconds
)

# Multiple options
{:ok, response} = BolagsverketEx.get_organisation(
  "5299999994",
  request_id: "my-request-123",
  timeout: 45_000
)
```

### Concurrent Requests

Process multiple companies in parallel:

```elixir
org_numbers = ["5299999994", "5565946642", "5566271764"]

# Using Task.async_stream
results = org_numbers
|> Task.async_stream(
  fn org_number ->
    {org_number, BolagsverketEx.get_organisation(org_number)}
  end,
  max_concurrency: 5,
  timeout: 30_000
)
|> Enum.map(fn {:ok, result} -> result end)

# Process results
Enum.each(results, fn {org_number, result} ->
  case result do
    {:ok, response} ->
      [org | _] = response.organisationer
      IO.puts("#{org_number}: Success")

    {:error, error} ->
      IO.puts("#{org_number}: Failed - #{error.message}")
  end
end)
```

### Building a Company Search Function

Create a reusable function to search and display company info:

```elixir
defmodule MyApp.CompanySearch do
  alias BolagsverketEx.Schemas.Organisation

  def search_and_display(org_number) do
    case BolagsverketEx.get_organisation(org_number) do
      {:ok, response} ->
        display_companies(response.organisationer)
        {:ok, response}

      {:error, error} ->
        IO.puts("Error: #{error.message}")
        {:error, error}
    end
  end

  defp display_companies([]), do: IO.puts("No companies found")

  defp display_companies(companies) do
    Enum.each(companies, &display_company/1)
  end

  defp display_company(org) do
    IO.puts("\n=== Company Information ===")
    IO.puts("Org Number: #{org.organisationsidentitet.identitetsbeteckning}")

    if org.organisationsnamn do
      [namn | _] = org.organisationsnamn.organisationsnamn_lista
      IO.puts("Name: #{namn.namn}")
    end

    if org.organisationsform do
      IO.puts("Form: #{org.organisationsform.klartext}")
    end

    if org.verksamhetsbeskrivning do
      IO.puts("Activity: #{org.verksamhetsbeskrivning.beskrivning}")
    end

    case org.verksam_organisation do
      %{kod: :ja} -> IO.puts("Status: Active")
      %{kod: :nej} -> IO.puts("Status: Inactive")
      _ -> nil
    end

    if org.postadress_organisation && org.postadress_organisation.postadress do
      addr = org.postadress_organisation.postadress
      IO.puts("Address: #{addr.utdelningsadress}, #{addr.postnummer} #{addr.postort}")
    end

    IO.puts("========================")
  end
end

# Usage
MyApp.CompanySearch.search_and_display("5299999994")
```

## Common Patterns

### Validating Organisation Numbers

Check if an organisation number is valid before making requests:

```elixir
alias BolagsverketEx.Schemas.Identitetsbeteckning

case Identitetsbeteckning.validate("5299999994") do
  :ok ->
    {:ok, response} = BolagsverketEx.get_organisation("5299999994")

  {:error, message} ->
    IO.puts("Invalid: #{message}")
end
```

### Caching Results

Cache API responses to reduce requests:

```elixir
defmodule MyApp.CompanyCache do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_organisation(org_number) do
    case Agent.get(__MODULE__, &Map.get(&1, org_number)) do
      nil ->
        # Not in cache, fetch from API
        case BolagsverketEx.get_organisation(org_number) do
          {:ok, response} = result ->
            # Store in cache
            Agent.update(__MODULE__, &Map.put(&1, org_number, response))
            result

          error ->
            error
        end

      cached_response ->
        {:ok, cached_response}
    end
  end
end
```

### Rate Limiting

Add rate limiting to avoid overwhelming the API:

```elixir
defmodule MyApp.RateLimiter do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, nil}
  end

  def get_organisation(org_number) do
    GenServer.call(__MODULE__, {:get_organisation, org_number})
  end

  def handle_call({:get_organisation, org_number}, _from, state) do
    result = BolagsverketEx.get_organisation(org_number)

    # Wait 1 second between requests
    Process.sleep(1000)

    {:reply, result, state}
  end
end
```

### Logging Requests

Add logging for debugging:

```elixir
require Logger

org_number = "5299999994"
Logger.info("Fetching organisation: #{org_number}")

case BolagsverketEx.get_organisation(org_number) do
  {:ok, response} ->
    Logger.info("Successfully retrieved organisation #{org_number}")
    {:ok, response}

  {:error, error} ->
    Logger.error("Failed to retrieve organisation #{org_number}: #{error.message}")
    {:error, error}
end
```

## Next Steps

- Explore the [module documentation](BolagsverketEx.html) for detailed function references
- Check the [Authentication Guide](authentication.md) for OAuth2 configuration
- Review the [Getting Started](getting_started.md) guide for initial setup
