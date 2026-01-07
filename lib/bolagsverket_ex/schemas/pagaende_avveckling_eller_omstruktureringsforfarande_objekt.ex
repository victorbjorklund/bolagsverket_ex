defmodule BolagsverketEx.Schemas.PagaendeAvvecklingsEllerOmstruktureringsforfarandeObjekt do
  @moduledoc """
  Ongoing liquidation or restructuring procedure object.
  """

  @type t :: %__MODULE__{
          kod: String.t(),
          klartext: String.t() | nil,
          from_datum: String.t() | nil
        }

  @enforce_keys [:kod]
  defstruct [:kod, :klartext, :from_datum]

  @doc """
  Parse PagaendeAvvecklingsEllerOmstruktureringsforfarandeObjekt from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      kod: Map.get(map, "kod"),
      klartext: Map.get(map, "klartext"),
      from_datum: Map.get(map, "fromDatum")
    }
  end
end
