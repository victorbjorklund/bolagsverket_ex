defmodule BolagsverketEx.Schemas.DocumentListResponse do
  @moduledoc """
  Response containing list of documents.

  Corresponds to DokumentlistaSvar in the API spec.
  """

  alias BolagsverketEx.Schemas.Document

  @type t :: %__MODULE__{
          dokument: [Document.t()]
        }

  defstruct dokument: []

  @doc """
  Parse from API response.

  ## Examples

      iex> response_map = %{"dokument" => [%{"dokumentId" => "123", ...}]}
      iex> response = BolagsverketEx.Schemas.DocumentListResponse.from_map(response_map)
      iex> length(response.dokument)
      1
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      dokument: parse_dokument(Map.get(map, "dokument"))
    }
  end

  defp parse_dokument(nil), do: []

  defp parse_dokument(list) when is_list(list) do
    Enum.map(list, &Document.from_map/1)
  end

  defp parse_dokument(_), do: []
end
