defmodule BolagsverketEx.Health do
  @moduledoc """
  Health check operations for the Bolagsverket API.

  Provides functions to check if the API is available and responding.
  """

  alias BolagsverketEx.{Client, Error}

  @doc """
  Check if the API is available.

  Calls the `/isalive` endpoint to verify the API is up and running.

  ## Parameters

    - `opts` - Optional keyword list
      - `:request_id` - Custom request ID for tracking
      - `:timeout` - Request timeout in milliseconds

  ## Returns

    - `{:ok, String.t()}` - Usually "OK" when the API is available
    - `{:error, Error.t()}` - When the API is unavailable or returns an error

  ## Examples

      iex> BolagsverketEx.Health.check()
      {:ok, "OK"}

      iex> BolagsverketEx.Health.check(timeout: 5000)
      {:ok, "OK"}
  """
  @spec check(keyword()) :: {:ok, String.t()} | {:error, Error.t()}
  def check(opts \\ []) do
    case Client.get("/isalive", opts) do
      {:ok, %Req.Response{status: 200, body: body}} when is_binary(body) ->
        {:ok, body}

      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, to_string(body)}

      {:ok, response} ->
        Error.from_response(response)

      {:error, error} ->
        {:error, error}
    end
  end
end
