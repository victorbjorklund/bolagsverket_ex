defmodule BolagsverketEx.Schemas.Reklamsparr do
  @moduledoc """
  Advertisement blocking status.

  Indicates if the organisation is blocked from receiving advertisements.
  """

  alias BolagsverketEx.Schemas.Fel

  @type t :: %__MODULE__{
          kod: :ja | :nej | String.t(),
          dataproducent: String.t() | nil,
          fel: Fel.t() | nil
        }

  @enforce_keys [:kod]
  defstruct [:kod, :dataproducent, :fel]

  @doc """
  Parse Reklamsparr from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      kod: parse_ja_nej(Map.get(map, "kod")),
      dataproducent: Map.get(map, "dataproducent"),
      fel: Fel.from_map(Map.get(map, "fel"))
    }
  end

  defp parse_ja_nej("JA"), do: :ja
  defp parse_ja_nej("NEJ"), do: :nej
  defp parse_ja_nej(other), do: other
end
