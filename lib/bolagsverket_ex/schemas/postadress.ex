defmodule BolagsverketEx.Schemas.Postadress do
  @moduledoc """
  Postal address structure.
  """

  @type t :: %__MODULE__{
          postnummer: String.t(),
          utdelningsadress: String.t() | nil,
          land: String.t() | nil,
          co_adress: String.t() | nil,
          postort: String.t() | nil
        }

  @enforce_keys [:postnummer]
  defstruct [:postnummer, :utdelningsadress, :land, :co_adress, :postort]

  @doc """
  Parse Postadress from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      postnummer: Map.get(map, "postnummer"),
      utdelningsadress: Map.get(map, "utdelningsadress"),
      land: Map.get(map, "land"),
      co_adress: Map.get(map, "coAdress"),
      postort: Map.get(map, "postort")
    }
  end
end
