defmodule BolagsverketEx.Schemas.Organisationsform do
  @moduledoc """
  Organisational form (e.g., AB for Aktiebolag).
  """

  alias BolagsverketEx.Schemas.Fel

  @type t :: %__MODULE__{
          kod: String.t(),
          klartext: String.t(),
          dataproducent: String.t() | nil,
          fel: Fel.t() | nil
        }

  @enforce_keys [:kod, :klartext]
  defstruct [:kod, :klartext, :dataproducent, :fel]

  @doc """
  Parse Organisationsform from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      kod: Map.get(map, "kod"),
      klartext: Map.get(map, "klartext"),
      dataproducent: Map.get(map, "dataproducent"),
      fel: Fel.from_map(Map.get(map, "fel"))
    }
  end
end
