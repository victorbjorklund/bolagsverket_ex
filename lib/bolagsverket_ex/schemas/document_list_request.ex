defmodule BolagsverketEx.Schemas.DocumentListRequest do
  @moduledoc """
  Request for document list.

  Corresponds to DokumentlistaBegaran in the API spec.
  """

  @type t :: %__MODULE__{
          identitetsbeteckning: String.t()
        }

  @enforce_keys [:identitetsbeteckning]
  defstruct [:identitetsbeteckning]

  @doc """
  Create a new document list request.

  ## Examples

      iex> BolagsverketEx.Schemas.DocumentListRequest.new("5299999994")
      %BolagsverketEx.Schemas.DocumentListRequest{identitetsbeteckning: "5299999994"}
  """
  @spec new(String.t()) :: t()
  def new(identitetsbeteckning) when is_binary(identitetsbeteckning) do
    %__MODULE__{identitetsbeteckning: identitetsbeteckning}
  end

  @doc """
  Convert to JSON-encodable map.

  ## Examples

      iex> request = BolagsverketEx.Schemas.DocumentListRequest.new("5299999994")
      iex> BolagsverketEx.Schemas.DocumentListRequest.to_map(request)
      %{"identitetsbeteckning" => "5299999994"}
  """
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = request) do
    %{"identitetsbeteckning" => request.identitetsbeteckning}
  end
end
