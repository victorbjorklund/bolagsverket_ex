defmodule BolagsverketEx.Schemas.Organisation do
  @moduledoc """
  Organisation information structure.

  Complete organisation data including registration info, names, addresses,
  legal form, and business activity details.
  """

  alias BolagsverketEx.Schemas.{
    Identitetsbeteckning,
    Organisationsnamn,
    KodKlartext,
    Reklamsparr,
    Organisationsform,
    AvregistreradOrganisation,
    Avregistreringsorsak,
    PagaendeAvvecklingsEllerOmstruktureringsforfarande,
    JuridiskForm,
    VerksamOrganisation,
    Organisationsdatum,
    Verksamhetsbeskrivning,
    NaringsgrenOrganisation,
    PostadressOrganisation
  }

  @type t :: %__MODULE__{
          organisationsidentitet: Identitetsbeteckning.t() | nil,
          namnskyddslopnummer: integer() | nil,
          organisationsnamn: Organisationsnamn.t() | nil,
          registreringsland: KodKlartext.t() | nil,
          reklamsparr: Reklamsparr.t() | nil,
          organisationsform: Organisationsform.t() | nil,
          avregistrerad_organisation: AvregistreradOrganisation.t() | nil,
          avregistreringsorsak: Avregistreringsorsak.t() | nil,
          pagaende_avveckling_eller_omstrukturering:
            PagaendeAvvecklingsEllerOmstruktureringsforfarande.t() | nil,
          juridisk_form: JuridiskForm.t() | nil,
          verksam_organisation: VerksamOrganisation.t() | nil,
          organisationsdatum: Organisationsdatum.t() | nil,
          verksamhetsbeskrivning: Verksamhetsbeskrivning.t() | nil,
          naringsgren_organisation: NaringsgrenOrganisation.t() | nil,
          postadress_organisation: PostadressOrganisation.t() | nil
        }

  defstruct [
    :organisationsidentitet,
    :namnskyddslopnummer,
    :organisationsnamn,
    :registreringsland,
    :reklamsparr,
    :organisationsform,
    :avregistrerad_organisation,
    :avregistreringsorsak,
    :pagaende_avveckling_eller_omstrukturering,
    :juridisk_form,
    :verksam_organisation,
    :organisationsdatum,
    :verksamhetsbeskrivning,
    :naringsgren_organisation,
    :postadress_organisation
  ]

  @doc """
  Parse organisation from API response map.

  ## Examples

      iex> map = %{"organisationsidentitet" => %{"identitetsbeteckning" => "5299999994", ...}, ...}
      iex> org = BolagsverketEx.Schemas.Organisation.from_map(map)
      iex> org.organisationsidentitet.identitetsbeteckning
      "5299999994"
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      organisationsidentitet:
        Identitetsbeteckning.from_map(Map.get(map, "organisationsidentitet")),
      namnskyddslopnummer: Map.get(map, "namnskyddslopnummer"),
      organisationsnamn: Organisationsnamn.from_map(Map.get(map, "organisationsnamn")),
      registreringsland: KodKlartext.from_map(Map.get(map, "registreringsland")),
      reklamsparr: Reklamsparr.from_map(Map.get(map, "reklamsparr")),
      organisationsform: Organisationsform.from_map(Map.get(map, "organisationsform")),
      avregistrerad_organisation:
        AvregistreradOrganisation.from_map(Map.get(map, "avregistreradOrganisation")),
      avregistreringsorsak: Avregistreringsorsak.from_map(Map.get(map, "avregistreringsorsak")),
      pagaende_avveckling_eller_omstrukturering:
        PagaendeAvvecklingsEllerOmstruktureringsforfarande.from_map(
          Map.get(map, "pagaendeAvvecklingsEllerOmstruktureringsforfarande")
        ),
      juridisk_form: JuridiskForm.from_map(Map.get(map, "juridiskForm")),
      verksam_organisation: VerksamOrganisation.from_map(Map.get(map, "verksamOrganisation")),
      organisationsdatum: Organisationsdatum.from_map(Map.get(map, "organisationsdatum")),
      verksamhetsbeskrivning:
        Verksamhetsbeskrivning.from_map(Map.get(map, "verksamhetsbeskrivning")),
      naringsgren_organisation:
        NaringsgrenOrganisation.from_map(Map.get(map, "naringsgrenOrganisation")),
      postadress_organisation:
        PostadressOrganisation.from_map(Map.get(map, "postadressOrganisation"))
    }
  end
end
