defmodule BolagsverketEx.Schemas.Organisationsnamn do
  @moduledoc """
  Business names associated with the organisation.
  """

  alias BolagsverketEx.Schemas.{OrganisationsnamnObjekt, Fel}

  @type t :: %__MODULE__{
          organisationsnamn_lista: [OrganisationsnamnObjekt.t()],
          dataproducent: String.t() | nil,
          fel: Fel.t() | nil
        }

  defstruct organisationsnamn_lista: [], dataproducent: nil, fel: nil

  @doc """
  Parse Organisationsnamn from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      organisationsnamn_lista: parse_namn_lista(Map.get(map, "organisationsnamnLista")),
      dataproducent: Map.get(map, "dataproducent"),
      fel: Fel.from_map(Map.get(map, "fel"))
    }
  end

  defp parse_namn_lista(nil), do: []

  defp parse_namn_lista(list) when is_list(list) do
    Enum.map(list, &OrganisationsnamnObjekt.from_map/1)
  end

  defp parse_namn_lista(_), do: []
end
