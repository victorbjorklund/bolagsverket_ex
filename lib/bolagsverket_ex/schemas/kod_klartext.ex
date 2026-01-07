defmodule BolagsverketEx.Schemas.KodKlartext do
  @moduledoc """
  Generic code and clear text pair structure.

  Used throughout the API to represent coded values with human-readable text.
  """

  @type t :: %__MODULE__{
          kod: String.t(),
          klartext: String.t()
        }

  @enforce_keys [:kod, :klartext]
  defstruct [:kod, :klartext]

  @doc """
  Parse KodKlartext from a map.

  ## Examples

      iex> BolagsverketEx.Schemas.KodKlartext.from_map(%{"kod" => "AB", "klartext" => "Aktiebolag"})
      %BolagsverketEx.Schemas.KodKlartext{kod: "AB", klartext: "Aktiebolag"}

      iex> BolagsverketEx.Schemas.KodKlartext.from_map(nil)
      nil
  """
  @spec from_map(map() | nil) :: t() | nil
  def from_map(nil), do: nil

  def from_map(map) when is_map(map) do
    %__MODULE__{
      kod: Map.get(map, "kod"),
      klartext: Map.get(map, "klartext")
    }
  end

  @doc """
  Convert KodKlartext to a map.

  ## Examples

      iex> kod_klartext = %BolagsverketEx.Schemas.KodKlartext{kod: "AB", klartext: "Aktiebolag"}
      iex> BolagsverketEx.Schemas.KodKlartext.to_map(kod_klartext)
      %{"kod" => "AB", "klartext" => "Aktiebolag"}
  """
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = struct) do
    %{
      "kod" => struct.kod,
      "klartext" => struct.klartext
    }
  end
end
