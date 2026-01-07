defmodule BolagsverketEx.Schemas.Identitetsbeteckning do
  @moduledoc """
  Identity designation (organisation number, personal identity number, etc).

  Can be 'organisationsnummer' (company registration number), 'personnummer'
  (personal identity number), 'samordningsnummer' or 'GD-nummer'.
  """

  alias BolagsverketEx.Schemas.KodKlartext

  @type t :: %__MODULE__{
          identitetsbeteckning: String.t(),
          typ: KodKlartext.t()
        }

  @enforce_keys [:identitetsbeteckning, :typ]
  defstruct [:identitetsbeteckning, :typ]

  @doc """
  Parse Identitetsbeteckning from a map.
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      identitetsbeteckning: Map.get(map, "identitetsbeteckning"),
      typ: KodKlartext.from_map(Map.get(map, "typ"))
    }
  end

  @doc """
  Validate identitetsbeteckning format.

  The API spec defines the pattern as:
  - 10 or 12 digits for organisationsnummer/personnummer
  - 10 digits starting with 302 for GD-nummer
  """
  @spec validate(String.t()) :: :ok | {:error, String.t()}
  def validate(identitetsbeteckning) when is_binary(identitetsbeteckning) do
    # Basic validation - check if it looks like a valid Swedish org/person number
    cond do
      String.match?(identitetsbeteckning, ~r/^\d{10}$/) -> :ok
      String.match?(identitetsbeteckning, ~r/^\d{12}$/) -> :ok
      String.match?(identitetsbeteckning, ~r/^302\d{8}$/) -> :ok
      true -> {:error, "Invalid identitetsbeteckning format. Expected 10 or 12 digits."}
    end
  end

  def validate(_), do: {:error, "identitetsbeteckning must be a string"}
end
