defmodule BolagsverketEx.Schemas.PostadressOrganisation do
  @moduledoc """
  Organisation postal address with metadata.
  """

  alias BolagsverketEx.Schemas.{Postadress, Fel}

  @type t :: %__MODULE__{
          postadress: Postadress.t() | nil,
          dataproducent: String.t() | nil,
          fel: Fel.t() | nil
        }

  defstruct [:postadress, :dataproducent, :fel]

  @doc """
  Parse PostadressOrganisation from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      postadress: Postadress.from_map(Map.get(map, "postadress")),
      dataproducent: Map.get(map, "dataproducent"),
      fel: Fel.from_map(Map.get(map, "fel"))
    }
  end
end
