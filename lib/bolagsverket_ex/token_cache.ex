defmodule BolagsverketEx.TokenCache do
  @moduledoc """
  Agent for caching OAuth2 access tokens.

  Stores tokens in memory with expiration timestamps to avoid
  unnecessary token refresh requests.
  """

  use Agent

  @type token_state :: %{
          token: String.t() | nil,
          expires_at: DateTime.t() | nil
        }

  @doc """
  Start the token cache Agent.
  """
  @spec start_link(any()) :: Agent.on_start()
  def start_link(_opts) do
    Agent.start_link(fn -> %{token: nil, expires_at: nil} end, name: __MODULE__)
  end

  @doc """
  Get the cached token if it's still valid.

  Returns `{:ok, token}` if a valid token exists, or `{:error, :expired}` if
  the token is missing or expired.

  ## Examples

      iex> BolagsverketEx.TokenCache.get_token()
      {:error, :expired}

      iex> BolagsverketEx.TokenCache.put_token("token123", 3600)
      :ok
      iex> BolagsverketEx.TokenCache.get_token()
      {:ok, "token123"}
  """
  @spec get_token() :: {:ok, String.t()} | {:error, :expired}
  def get_token do
    Agent.get(__MODULE__, fn %{token: token, expires_at: expires_at} ->
      if token && expires_at && DateTime.compare(DateTime.utc_now(), expires_at) == :lt do
        {:ok, token}
      else
        {:error, :expired}
      end
    end)
  end

  @doc """
  Store a token in the cache with its expiration time.

  ## Parameters

    - `token` - The access token string
    - `expires_in` - Seconds until the token expires

  ## Examples

      iex> BolagsverketEx.TokenCache.put_token("token123", 3600)
      :ok
  """
  @spec put_token(String.t(), integer()) :: :ok
  def put_token(token, expires_in) do
    # Subtract 60 seconds as a safety buffer to refresh before actual expiration
    expires_at = DateTime.add(DateTime.utc_now(), expires_in - 60, :second)

    Agent.update(__MODULE__, fn _ ->
      %{token: token, expires_at: expires_at}
    end)
  end

  @doc """
  Clear the cached token.

  Useful for testing or forcing a token refresh.

  ## Examples

      iex> BolagsverketEx.TokenCache.clear()
      :ok
  """
  @spec clear() :: :ok
  def clear do
    Agent.update(__MODULE__, fn _ ->
      %{token: nil, expires_at: nil}
    end)
  end
end
