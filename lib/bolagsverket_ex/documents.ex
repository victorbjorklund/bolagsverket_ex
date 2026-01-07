defmodule BolagsverketEx.Documents do
  @moduledoc """
  Document-related API operations.

  Provides functions to list and download annual reports from the Bolagsverket API.
  """

  alias BolagsverketEx.{Client, Error}
  alias BolagsverketEx.Schemas.{Identitetsbeteckning, DocumentListRequest, DocumentListResponse}

  @doc """
  List available documents for an organisation.

  ## Parameters

    - `identitetsbeteckning` - Company registration number
    - `opts` - Optional keyword list
      - `:request_id` - Custom request ID for tracking
      - `:timeout` - Request timeout in milliseconds

  ## Returns

    - `{:ok, DocumentListResponse.t()}` on success
    - `{:error, Error.t()}` on failure

  ## Examples

      iex> BolagsverketEx.Documents.list("5299999994")
      {:ok, %BolagsverketEx.Schemas.DocumentListResponse{dokument: [...]}}

      iex> BolagsverketEx.Documents.list("invalid")
      {:error, %BolagsverketEx.Error{type: :validation_error, ...}}
  """
  @spec list(String.t(), keyword()) :: {:ok, DocumentListResponse.t()} | {:error, Error.t()}
  def list(identitetsbeteckning, opts \\ []) do
    with :ok <- validate_identitetsbeteckning(identitetsbeteckning),
         request <- DocumentListRequest.new(identitetsbeteckning),
         {:ok, response} <- Client.post("/dokumentlista", request, opts),
         {:ok, parsed_response} <- parse_list_response(response) do
      {:ok, parsed_response}
    end
  end

  @doc """
  Download a specific document.

  Returns the ZIP file contents as binary data.

  ## Parameters

    - `dokument_id` - Document identifier from list/2
    - `opts` - Optional keyword list
      - `:request_id` - Custom request ID
      - `:timeout` - Request timeout (default: 60000 for large files)

  ## Returns

    - `{:ok, binary()}` on success - ZIP file contents
    - `{:error, Error.t()}` on failure

  ## Examples

      iex> BolagsverketEx.Documents.download("document_id_123")
      {:ok, <<80, 75, 3, 4, ...>>}

      iex> BolagsverketEx.Documents.download("nonexistent")
      {:error, %BolagsverketEx.Error{type: :api_error, ...}}
  """
  @spec download(String.t(), keyword()) :: {:ok, binary()} | {:error, Error.t()}
  def download(dokument_id, opts \\ []) do
    # Default to longer timeout for potentially large file downloads
    opts = Keyword.put_new(opts, :timeout, 60_000)
    path = "/dokument/#{dokument_id}"

    case Client.get(path, opts) do
      {:ok, %Req.Response{status: 200, body: binary}} when is_binary(binary) ->
        {:ok, binary}

      {:ok, response} ->
        Error.from_response(response)

      {:error, error} ->
        {:error, error}
    end
  end

  # Private functions

  defp validate_identitetsbeteckning(identitetsbeteckning) do
    case Identitetsbeteckning.validate(identitetsbeteckning) do
      :ok ->
        :ok

      {:error, message} ->
        {:error, Error.validation_error(message, %{identitetsbeteckning: identitetsbeteckning})}
    end
  end

  defp parse_list_response(%Req.Response{status: 200, body: body}) when is_map(body) do
    {:ok, DocumentListResponse.from_map(body)}
  rescue
    error ->
      {:error, Error.parse_error("Failed to parse document list response", error)}
  end

  defp parse_list_response(%Req.Response{status: 200, body: body}) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        {:ok, DocumentListResponse.from_map(decoded)}

      {:error, error} ->
        {:error, Error.parse_error("Failed to decode JSON response", error)}
    end
  end

  defp parse_list_response(response) do
    Error.from_response(response)
  end
end
