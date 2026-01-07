defmodule BolagsverketEx.Schemas.Verksamhetsbeskrivning do
  @moduledoc """
  Business activity description.
  """

  alias BolagsverketEx.Schemas.Fel

  @type t :: %__MODULE__{
          beskrivning: String.t(),
          dataproducent: String.t() | nil,
          fel: Fel.t() | nil
        }

  @enforce_keys [:beskrivning]
  defstruct [:beskrivning, :dataproducent, :fel]

  @doc """
  Parse Verksamhetsbeskrivning from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      beskrivning: Map.get(map, "beskrivning"),
      dataproducent: Map.get(map, "dataproducent"),
      fel: Fel.from_map(Map.get(map, "fel"))
    }
  end
end
