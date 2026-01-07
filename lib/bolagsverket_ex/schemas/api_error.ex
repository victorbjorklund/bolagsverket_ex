defmodule BolagsverketEx.Schemas.ApiError do
  @moduledoc """
  API error response structure based on RFC 7807.

  Represents error responses from the Bolagsverket API.
  """

  @type t :: %__MODULE__{
          type: String.t(),
          instance: String.t(),
          status: integer(),
          timestamp: DateTime.t() | nil,
          request_id: String.t() | nil,
          title: String.t(),
          detail: String.t() | nil
        }

  @enforce_keys [:type, :instance, :status, :title]
  defstruct [:type, :instance, :status, :timestamp, :request_id, :title, :detail]

  @doc """
  Parse API error from response map.

  ## Examples

      iex> error_map = %{
      ...>   "type" => "about:blank",
      ...>   "instance" => "client.error",
      ...>   "status" => 400,
      ...>   "title" => "Bad Request",
      ...>   "detail" => "Invalid identitetsbeteckning"
      ...> }
      iex> api_error = BolagsverketEx.Schemas.ApiError.from_map(error_map)
      iex> api_error.status
      400
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      type: Map.get(map, "type"),
      instance: Map.get(map, "instance"),
      status: Map.get(map, "status"),
      timestamp: parse_timestamp(Map.get(map, "timestamp")),
      request_id: Map.get(map, "requestId"),
      title: Map.get(map, "title"),
      detail: Map.get(map, "detail")
    }
  end

  defp parse_timestamp(nil), do: nil

  defp parse_timestamp(timestamp) when is_binary(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, datetime, _offset} -> datetime
      {:error, _} -> nil
    end
  end

  defp parse_timestamp(_), do: nil
end
