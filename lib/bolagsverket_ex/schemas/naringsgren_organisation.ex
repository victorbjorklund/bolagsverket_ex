defmodule BolagsverketEx.Schemas.NaringsgrenOrganisation do
  @moduledoc """
  Industry classification (SNI codes).
  """

  alias BolagsverketEx.Schemas.{KodKlartext, Fel}

  @type t :: %__MODULE__{
          sni: [KodKlartext.t()],
          dataproducent: String.t() | nil,
          fel: Fel.t() | nil
        }

  defstruct sni: [], dataproducent: nil, fel: nil

  @doc """
  Parse NaringsgrenOrganisation from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      sni: parse_sni(Map.get(map, "sni")),
      dataproducent: Map.get(map, "dataproducent"),
      fel: Fel.from_map(Map.get(map, "fel"))
    }
  end

  defp parse_sni(nil), do: []

  defp parse_sni(list) when is_list(list) do
    Enum.map(list, &KodKlartext.from_map/1)
  end

  defp parse_sni(_), do: []
end
