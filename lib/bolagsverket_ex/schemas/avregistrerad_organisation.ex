defmodule BolagsverketEx.Schemas.AvregistreradOrganisation do
  @moduledoc """
  Deregistered organisation information.

  Contains the date when an organisation was removed from the register.
  """

  alias BolagsverketEx.Schemas.Fel

  @type t :: %__MODULE__{
          avregistreringsdatum: String.t() | nil,
          dataproducent: String.t() | nil,
          fel: Fel.t() | nil
        }

  defstruct [:avregistreringsdatum, :dataproducent, :fel]

  @doc """
  Parse AvregistreradOrganisation from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      avregistreringsdatum: Map.get(map, "avregistreringsdatum"),
      dataproducent: Map.get(map, "dataproducent"),
      fel: Fel.from_map(Map.get(map, "fel"))
    }
  end
end
