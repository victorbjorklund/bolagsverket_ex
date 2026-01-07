defmodule BolagsverketEx.Organisations do
  @moduledoc """
  Organisation-related API operations.

  Provides functions to fetch company data from the Bolagsverket API.
  """

  alias BolagsverketEx.{Client, Error}
  alias BolagsverketEx.Schemas.{Identitetsbeteckning, OrganisationRequest, OrganisationResponse}

  @doc """
  Fetch organisation data by company registration number.

  ## Parameters

    - `identitetsbeteckning` - Company registration number (10 or 12 digits)
    - `opts` - Optional keyword list
      - `:request_id` - Custom request ID for tracking
      - `:timeout` - Request timeout in milliseconds

  ## Returns

    - `{:ok, OrganisationResponse.t()}` on success
    - `{:error, Error.t()}` on failure

  ## Examples

      iex> BolagsverketEx.Organisations.fetch("5299999994")
      {:ok, %BolagsverketEx.Schemas.OrganisationResponse{organisationer: [...]}}

      iex> BolagsverketEx.Organisations.fetch("invalid")
      {:error, %BolagsverketEx.Error{type: :validation_error, ...}}
  """
  @spec fetch(String.t(), keyword()) :: {:ok, OrganisationResponse.t()} | {:error, Error.t()}
  def fetch(identitetsbeteckning, opts \\ []) do
    with :ok <- validate_identitetsbeteckning(identitetsbeteckning),
         request <- OrganisationRequest.new(identitetsbeteckning),
         {:ok, response} <- Client.post("/organisationer", request, opts),
         {:ok, parsed_response} <- parse_response(response) do
      {:ok, parsed_response}
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

  defp parse_response(%Req.Response{status: 200, body: body}) when is_map(body) do
    {:ok, OrganisationResponse.from_map(body)}
  rescue
    error ->
      {:error, Error.parse_error("Failed to parse organisation response", error)}
  end

  defp parse_response(%Req.Response{status: 200, body: body}) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        {:ok, OrganisationResponse.from_map(decoded)}

      {:error, error} ->
        {:error, Error.parse_error("Failed to decode JSON response", error)}
    end
  end

  defp parse_response(response) do
    Error.from_response(response)
  end
end
