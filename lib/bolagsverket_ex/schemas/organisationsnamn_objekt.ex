defmodule BolagsverketEx.Schemas.OrganisationsnamnObjekt do
  @moduledoc """
  Business name object.
  """

  alias BolagsverketEx.Schemas.KodKlartext

  @type t :: %__MODULE__{
          namn: String.t() | nil,
          organisationsnamntyp: KodKlartext.t() | nil,
          registreringsdatum: String.t() | nil,
          verksamhetsbeskrivning_sarskilt_foretagsnamn: String.t() | nil
        }

  defstruct [
    :namn,
    :organisationsnamntyp,
    :registreringsdatum,
    :verksamhetsbeskrivning_sarskilt_foretagsnamn
  ]

  @doc """
  Parse OrganisationsnamnObjekt from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      namn: Map.get(map, "namn"),
      organisationsnamntyp: KodKlartext.from_map(Map.get(map, "organisationsnamntyp")),
      registreringsdatum: Map.get(map, "registreringsdatum"),
      verksamhetsbeskrivning_sarskilt_foretagsnamn:
        Map.get(map, "verksamhetsbeskrivningSarskiltForetagsnamn")
    }
  end
end
