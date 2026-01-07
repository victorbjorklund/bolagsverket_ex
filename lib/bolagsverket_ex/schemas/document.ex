defmodule BolagsverketEx.Schemas.Document do
  @moduledoc """
  Document metadata structure.

  Represents information about an annual report document.
  """

  @type t :: %__MODULE__{
          dokument_id: String.t() | nil,
          filformat: String.t() | nil,
          rapporteringsperiod_tom: Date.t() | nil,
          registreringstidpunkt: Date.t() | nil
        }

  defstruct [:dokument_id, :filformat, :rapporteringsperiod_tom, :registreringstidpunkt]

  @doc """
  Parse Document from a map.

  ## Examples

      iex> doc_map = %{"dokumentId" => "abc123", "filformat" => "pdf", ...}
      iex> doc = BolagsverketEx.Schemas.Document.from_map(doc_map)
      iex> doc.dokument_id
      "abc123"
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      dokument_id: Map.get(map, "dokumentId"),
      filformat: Map.get(map, "filformat"),
      rapporteringsperiod_tom: parse_date(Map.get(map, "rapporteringsperiodTom")),
      registreringstidpunkt: parse_date(Map.get(map, "registreringstidpunkt"))
    }
  end

  defp parse_date(nil), do: nil

  defp parse_date(date_string) when is_binary(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> date
      {:error, _} -> nil
    end
  end

  defp parse_date(_), do: nil
end
