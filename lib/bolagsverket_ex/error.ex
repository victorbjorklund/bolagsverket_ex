defmodule BolagsverketEx.Error do
  @moduledoc """
  Error types and handling for BolagsverketEx.

  All public API functions return `{:ok, result} | {:error, Error.t()}`.

  ## Error Types

  - `:auth_error` - OAuth2 authentication failed
  - `:network_error` - Network/connection issues
  - `:timeout_error` - Request timeout
  - `:validation_error` - Invalid input parameters
  - `:api_error` - API returned error response
  - `:parse_error` - Failed to parse response
  - `:config_error` - Configuration missing/invalid
  - `:unknown_error` - Unexpected error
  """

  alias BolagsverketEx.Schemas.ApiError

  @type error_type ::
          :auth_error
          | :network_error
          | :timeout_error
          | :validation_error
          | :api_error
          | :parse_error
          | :config_error
          | :unknown_error

  @type t :: %__MODULE__{
          type: error_type(),
          message: String.t(),
          details: term(),
          api_error: ApiError.t() | nil,
          request_id: String.t() | nil
        }

  @enforce_keys [:type, :message]
  defstruct [:type, :message, :details, :api_error, :request_id]

  @doc """
  Create a new error.

  ## Examples

      iex> BolagsverketEx.Error.new(:auth_error, "Authentication failed")
      %BolagsverketEx.Error{type: :auth_error, message: "Authentication failed", details: nil}
  """
  @spec new(error_type(), String.t(), keyword()) :: t()
  def new(type, message, opts \\ []) do
    %__MODULE__{
      type: type,
      message: message,
      details: Keyword.get(opts, :details),
      api_error: Keyword.get(opts, :api_error),
      request_id: Keyword.get(opts, :request_id)
    }
  end

  @doc """
  Create error from HTTP response.

  Attempts to parse JSON error response into ApiError struct.
  """
  @spec from_response(Req.Response.t()) :: {:error, t()}
  def from_response(%Req.Response{status: status, body: body}) do
    case parse_api_error(body) do
      {:ok, api_error} ->
        {:error,
         new(:api_error, "API returned #{status} error",
           api_error: api_error,
           request_id: api_error.request_id
         )}

      :error ->
        message = "HTTP #{status}: #{inspect(body)}"
        {:error, new(:api_error, message, details: %{status: status, body: body})}
    end
  end

  @doc """
  Create error from exception.
  """
  @spec from_exception(Exception.t()) :: {:error, t()}
  def from_exception(exception) do
    message = Exception.message(exception)

    # Check if it's a network-related error by examining the exception module name
    case exception.__struct__ do
      mod when mod in [Mint.TransportError, Mint.HTTPError] ->
        {:error, network_error(message, exception)}

      _ ->
        {:error, new(:unknown_error, message, details: exception)}
    end
  end

  @doc """
  Create validation error.

  ## Examples

      iex> BolagsverketEx.Error.validation_error("Invalid org number")
      %BolagsverketEx.Error{type: :validation_error, message: "Invalid org number"}
  """
  @spec validation_error(String.t(), term()) :: t()
  def validation_error(message, details \\ nil) do
    new(:validation_error, message, details: details)
  end

  @doc """
  Create authentication error.

  ## Examples

      iex> BolagsverketEx.Error.auth_error("Token fetch failed")
      %BolagsverketEx.Error{type: :auth_error, message: "Token fetch failed"}
  """
  @spec auth_error(String.t(), term()) :: t()
  def auth_error(message, details \\ nil) do
    new(:auth_error, message, details: details)
  end

  @doc """
  Create network error.

  ## Examples

      iex> BolagsverketEx.Error.network_error("Connection refused")
      %BolagsverketEx.Error{type: :network_error, message: "Connection refused"}
  """
  @spec network_error(String.t(), term()) :: t()
  def network_error(message, details \\ nil) do
    new(:network_error, message, details: details)
  end

  @doc """
  Create timeout error.
  """
  @spec timeout_error(String.t(), term()) :: t()
  def timeout_error(message, details \\ nil) do
    new(:timeout_error, message, details: details)
  end

  @doc """
  Create parse error.
  """
  @spec parse_error(String.t(), term()) :: t()
  def parse_error(message, details \\ nil) do
    new(:parse_error, message, details: details)
  end

  @doc """
  Create config error.
  """
  @spec config_error(String.t(), term()) :: t()
  def config_error(message, details \\ nil) do
    new(:config_error, message, details: details)
  end

  @doc """
  Create API error from ApiError schema.
  """
  @spec api_error(ApiError.t(), String.t() | nil) :: t()
  def api_error(api_error_struct, request_id \\ nil) do
    new(:api_error, api_error_struct.title,
      api_error: api_error_struct,
      request_id: request_id || api_error_struct.request_id
    )
  end

  # Private helpers

  defp parse_api_error(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, map} when is_map(map) ->
        parse_api_error(map)

      _ ->
        :error
    end
  end

  defp parse_api_error(body) when is_map(body) do
    # Ensure ApiError module is loaded before using it
    Code.ensure_loaded(BolagsverketEx.Schemas.ApiError)

    if function_exported?(BolagsverketEx.Schemas.ApiError, :from_map, 1) do
      {:ok, BolagsverketEx.Schemas.ApiError.from_map(body)}
    else
      :error
    end
  rescue
    _ -> :error
  end

  defp parse_api_error(_), do: :error
end
