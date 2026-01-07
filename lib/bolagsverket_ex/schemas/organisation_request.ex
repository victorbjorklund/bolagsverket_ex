defmodule BolagsverketEx.Schemas.OrganisationRequest do
  @moduledoc """
  Request structure for retrieving organisation data.

  Corresponds to OrganisationerBegaran in the API spec.
  """

  @type t :: %__MODULE__{
          identitetsbeteckning: String.t()
        }

  @enforce_keys [:identitetsbeteckning]
  defstruct [:identitetsbeteckning]

  @doc """
  Create a new organisation request.

  ## Examples

      iex> BolagsverketEx.Schemas.OrganisationRequest.new("5299999994")
      %BolagsverketEx.Schemas.OrganisationRequest{identitetsbeteckning: "5299999994"}
  """
  @spec new(String.t()) :: t()
  def new(identitetsbeteckning) when is_binary(identitetsbeteckning) do
    %__MODULE__{identitetsbeteckning: identitetsbeteckning}
  end

  @doc """
  Convert to JSON-encodable map.

  ## Examples

      iex> request = BolagsverketEx.Schemas.OrganisationRequest.new("5299999994")
      iex> BolagsverketEx.Schemas.OrganisationRequest.to_map(request)
      %{"identitetsbeteckning" => "5299999994"}
  """
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = request) do
    %{"identitetsbeteckning" => request.identitetsbeteckning}
  end
end
