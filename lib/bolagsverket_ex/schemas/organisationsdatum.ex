defmodule BolagsverketEx.Schemas.Organisationsdatum do
  @moduledoc """
  Organisation registration dates.
  """

  alias BolagsverketEx.Schemas.Fel

  @type t :: %__MODULE__{
          registreringsdatum: String.t(),
          infort_hos_scb: String.t() | nil,
          dataproducent: String.t() | nil,
          fel: Fel.t() | nil
        }

  @enforce_keys [:registreringsdatum]
  defstruct [:registreringsdatum, :infort_hos_scb, :dataproducent, :fel]

  @doc """
  Parse Organisationsdatum from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      registreringsdatum: Map.get(map, "registreringsdatum"),
      infort_hos_scb: Map.get(map, "infortHosScb"),
      dataproducent: Map.get(map, "dataproducent"),
      fel: Fel.from_map(Map.get(map, "fel"))
    }
  end
end
