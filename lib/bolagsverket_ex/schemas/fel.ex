defmodule BolagsverketEx.Schemas.Fel do
  @moduledoc """
  Error information within data responses.

  Different from ApiError - this represents errors for individual
  data fields when a data source is unavailable or returns an error.
  """

  @type fel_typ ::
          :organisation_finns_ej
          | :ogiltig_begaran
          | :otillganglig_uppgiftskalla
          | :timeout

  @type t :: %__MODULE__{
          typ: fel_typ() | String.t(),
          fel_beskrivning: String.t() | nil
        }

  defstruct [:typ, :fel_beskrivning]

  @doc """
  Parse Fel from a map.

  ## Examples

      iex> BolagsverketEx.Schemas.Fel.from_map(%{"typ" => "OGILTIG_BEGARAN", "felBeskrivning" => "Invalid request"})
      %BolagsverketEx.Schemas.Fel{typ: "OGILTIG_BEGARAN", fel_beskrivning: "Invalid request"}

      iex> BolagsverketEx.Schemas.Fel.from_map(nil)
      nil
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      typ: parse_typ(Map.get(map, "typ")),
      fel_beskrivning: Map.get(map, "felBeskrivning")
    }
  end

  defp parse_typ("ORGANISATION_FINNS_EJ"), do: :organisation_finns_ej
  defp parse_typ("OGILTIG_BEGARAN"), do: :ogiltig_begaran
  defp parse_typ("OTILLGANGLIG_UPPGIFTSKALLA"), do: :otillganglig_uppgiftskalla
  defp parse_typ("TIMEOUT"), do: :timeout
  defp parse_typ(other), do: other
end
