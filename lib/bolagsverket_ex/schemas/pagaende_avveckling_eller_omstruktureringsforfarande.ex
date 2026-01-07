defmodule BolagsverketEx.Schemas.PagaendeAvvecklingsEllerOmstruktureringsforfarande do
  @moduledoc """
  Ongoing liquidation or restructuring procedures.
  """

  alias BolagsverketEx.Schemas.{PagaendeAvvecklingsEllerOmstruktureringsforfarandeObjekt, Fel}

  @type t :: %__MODULE__{
          pagaende_avveckling_eller_omstruktureringsforfarande_lista: [
            PagaendeAvvecklingsEllerOmstruktureringsforfarandeObjekt.t()
          ],
          dataproducent: String.t() | nil,
          fel: Fel.t() | nil
        }

  defstruct pagaende_avveckling_eller_omstruktureringsforfarande_lista: [],
            dataproducent: nil,
            fel: nil

  @doc """
  Parse PagaendeAvvecklingsEllerOmstruktureringsforfarande from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      pagaende_avveckling_eller_omstruktureringsforfarande_lista:
        parse_lista(Map.get(map, "pagaendeAvvecklingsEllerOmstruktureringsforfarandeLista")),
      dataproducent: Map.get(map, "dataproducent"),
      fel: Fel.from_map(Map.get(map, "fel"))
    }
  end

  defp parse_lista(nil), do: []

  defp parse_lista(list) when is_list(list) do
    Enum.map(list, &PagaendeAvvecklingsEllerOmstruktureringsforfarandeObjekt.from_map/1)
  end

  defp parse_lista(_), do: []
end
