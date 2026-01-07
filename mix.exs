defmodule BolagsverketEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :bolagsverket_ex,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "BolagsverketEx",
      source_url: "https://github.com/victorbjorklund/bolagsverket_ex"
    ]
  end

  defp description do
    """
    Elixir client for the Swedish Bolagsverket (Company Registration Office) API.
    Retrieve company information, annual reports, and related documentation.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/victorbjorklund/bolagsverket_ex"
      },
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE ENVIRONMENTS.md guides) ++ ["API Spec.yaml"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "ENVIRONMENTS.md",
        "guides/getting_started.md",
        "guides/authentication.md",
        "guides/usage.md"
      ],
      groups_for_modules: [
        Core: [
          BolagsverketEx,
          BolagsverketEx.Config,
          BolagsverketEx.Error
        ],
        "API Modules": [
          BolagsverketEx.Health,
          BolagsverketEx.Organisations,
          BolagsverketEx.Documents
        ],
        "Request Schemas": [
          BolagsverketEx.Schemas.OrganisationRequest,
          BolagsverketEx.Schemas.DocumentListRequest
        ],
        "Response Schemas": [
          BolagsverketEx.Schemas.OrganisationResponse,
          BolagsverketEx.Schemas.Organisation,
          BolagsverketEx.Schemas.DocumentListResponse,
          BolagsverketEx.Schemas.Document,
          BolagsverketEx.Schemas.ApiError
        ],
        "Supporting Schemas": [
          BolagsverketEx.Schemas.Identitetsbeteckning,
          BolagsverketEx.Schemas.KodKlartext,
          BolagsverketEx.Schemas.Fel,
          BolagsverketEx.Schemas.Organisationsnamn,
          BolagsverketEx.Schemas.OrganisationsnamnObjekt,
          BolagsverketEx.Schemas.Postadress,
          BolagsverketEx.Schemas.PostadressOrganisation,
          BolagsverketEx.Schemas.Organisationsform,
          BolagsverketEx.Schemas.Reklamsparr,
          BolagsverketEx.Schemas.AvregistreradOrganisation,
          BolagsverketEx.Schemas.Avregistreringsorsak,
          BolagsverketEx.Schemas.PagaendeAvvecklingsEllerOmstruktureringsforfarande,
          BolagsverketEx.Schemas.PagaendeAvvecklingsEllerOmstruktureringsforfarandeObjekt,
          BolagsverketEx.Schemas.JuridiskForm,
          BolagsverketEx.Schemas.VerksamOrganisation,
          BolagsverketEx.Schemas.Organisationsdatum,
          BolagsverketEx.Schemas.Verksamhetsbeskrivning,
          BolagsverketEx.Schemas.NaringsgrenOrganisation
        ],
        Internal: [
          BolagsverketEx.Application,
          BolagsverketEx.Client,
          BolagsverketEx.TokenCache
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BolagsverketEx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # HTTP client
      {:req, "~> 0.5"},
      # JSON parsing
      {:jason, "~> 1.4"},
      # OAuth2 client
      {:oauth2, "~> 2.1"},
      # Development and testing
      {:bypass, "~> 2.1", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
