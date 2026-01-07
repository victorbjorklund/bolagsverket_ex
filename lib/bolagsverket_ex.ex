defmodule BolagsverketEx do
  @moduledoc """
  Elixir client for the Swedish Bolagsverket (Company Registration Office) API.

  This library provides a clean, idiomatic Elixir interface to the Bolagsverket
  Värdefulla datamängder API, allowing you to retrieve company information,
  annual reports, and related documentation.

  ## Configuration

  Configure your OAuth2 credentials in `config/config.exs`:

      config :bolagsverket_ex,
        client_id: System.get_env("BOLAGSVERKET_CLIENT_ID"),
        client_secret: System.get_env("BOLAGSVERKET_CLIENT_SECRET"),
        token_url: "https://gw.api.bolagsverket.se/oauth2/token",
        base_url: "https://gw.api.bolagsverket.se/vardefulla-datamangder/v1"

  ## Examples

      # Get organisation information
      {:ok, response} = BolagsverketEx.get_organisation("5299999994")
      [org | _] = response.organisationer
      IO.inspect(org.organisationsnamn)

      # List available annual reports
      {:ok, documents} = BolagsverketEx.list_documents("5299999994")
      Enum.each(documents.dokument, fn doc ->
        IO.puts("Document ID: \#{doc.dokument_id}")
      end)

      # Download a specific document
      {:ok, zip_data} = BolagsverketEx.get_document("document_id_here")
      File.write!("annual_report.zip", zip_data)

      # Check API health
      {:ok, "OK"} = BolagsverketEx.health_check()

  """

  alias BolagsverketEx.{Organisations, Documents, Health}
  alias BolagsverketEx.Schemas.{OrganisationResponse, DocumentListResponse}

  @doc """
  Retrieve organisation information by company registration number.

  Fetches comprehensive company data including names, addresses, legal form,
  business activities, and registration status.

  ## Parameters

    - `identitetsbeteckning` - Company registration number (10 or 12 digits)
    - `opts` - Optional keyword list
      - `:request_id` - Custom request ID for tracking
      - `:timeout` - Request timeout in milliseconds (default: 30000)

  ## Returns

    - `{:ok, OrganisationResponse.t()}` on success
    - `{:error, Error.t()}` on failure

  ## Examples

      # Successful request (documentation only - requires valid credentials)
      {:ok, response} = BolagsverketEx.get_organisation("5299999994")
      [org | _] = response.organisationer
      org.organisationsidentitet.identitetsbeteckning
      # => "5299999994"

      # Validation error example
      BolagsverketEx.get_organisation("invalid")
      # => {:error, %BolagsverketEx.Error{type: :validation_error, message: "..."}}
  """
  @spec get_organisation(String.t(), keyword()) ::
          {:ok, OrganisationResponse.t()} | {:error, BolagsverketEx.Error.t()}
  def get_organisation(identitetsbeteckning, opts \\ []) do
    Organisations.fetch(identitetsbeteckning, opts)
  end

  @doc """
  List available annual reports for an organisation.

  Retrieves a list of all annual report documents available for the specified
  company, including document IDs, file formats, and reporting periods.

  ## Parameters

    - `identitetsbeteckning` - Company registration number
    - `opts` - Optional keyword list (same as get_organisation/2)

  ## Returns

    - `{:ok, DocumentListResponse.t()}` on success
    - `{:error, Error.t()}` on failure

  ## Examples

      # List documents (documentation only - requires valid credentials)
      {:ok, response} = BolagsverketEx.list_documents("5299999994")
      length(response.dokument)
      # => 5
  """
  @spec list_documents(String.t(), keyword()) ::
          {:ok, DocumentListResponse.t()} | {:error, BolagsverketEx.Error.t()}
  def list_documents(identitetsbeteckning, opts \\ []) do
    Documents.list(identitetsbeteckning, opts)
  end

  @doc """
  Download an annual report document.

  Downloads a specific annual report as a ZIP file containing the report
  data in various formats (typically XBRL/iXBRL).

  ## Parameters

    - `dokument_id` - Document identifier obtained from list_documents/2
    - `opts` - Optional keyword list
      - `:request_id` - Custom request ID
      - `:timeout` - Request timeout (default: 60000 for large files)

  ## Returns

    - `{:ok, binary()}` on success - ZIP file contents as binary data
    - `{:error, Error.t()}` on failure

  ## Examples

      # Download document (documentation only - requires valid credentials)
      {:ok, zip_data} = BolagsverketEx.get_document("abc123")
      is_binary(zip_data)
      # => true
      File.write!("report.zip", zip_data)
      # => :ok
  """
  @spec get_document(String.t(), keyword()) ::
          {:ok, binary()} | {:error, BolagsverketEx.Error.t()}
  def get_document(dokument_id, opts \\ []) do
    Documents.download(dokument_id, opts)
  end

  @doc """
  Check if the Bolagsverket API is available.

  Performs a health check against the API's /isalive endpoint to verify
  that the service is operational.

  ## Parameters

    - `opts` - Optional keyword list
      - `:request_id` - Custom request ID
      - `:timeout` - Request timeout

  ## Returns

    - `{:ok, String.t()}` - Usually "OK" when the API is available
    - `{:error, Error.t()}` - When the API is unavailable

  ## Examples

      # Health check (documentation only - requires valid credentials)
      BolagsverketEx.health_check()
      # => {:ok, "OK"}
  """
  @spec health_check(keyword()) :: {:ok, String.t()} | {:error, BolagsverketEx.Error.t()}
  def health_check(opts \\ []) do
    Health.check(opts)
  end
end
