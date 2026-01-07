defmodule BolagsverketEx.Schemas.OrganisationResponse do
  @moduledoc """
  Response structure containing organisation data.

  Corresponds to OrganisationerSvar in the API spec.
  """

  alias BolagsverketEx.Schemas.Organisation

  @type t :: %__MODULE__{
          organisationer: [Organisation.t()]
        }

  defstruct organisationer: []

  @doc """
  Parse from API response.

  ## Examples

      iex> response_map = %{"organisationer" => [%{"organisationsidentitet" => ...}]}
      iex> response = BolagsverketEx.Schemas.OrganisationResponse.from_map(response_map)
      iex> length(response.organisationer)
      1
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      organisationer: parse_organisationer(Map.get(map, "organisationer"))
    }
  end

  defp parse_organisationer(nil), do: []

  defp parse_organisationer(list) when is_list(list) do
    Enum.map(list, &Organisation.from_map/1)
  end

  defp parse_organisationer(_), do: []
end
