defmodule BolagsverketEx.Config do
  @moduledoc """
  Configuration management for BolagsverketEx.

  Provides functions to access and validate configuration values.
  """

  @type t :: %{
          client_id: String.t(),
          client_secret: String.t(),
          token_url: String.t(),
          base_url: String.t(),
          scope: String.t(),
          request_timeout: pos_integer(),
          retry_enabled: boolean(),
          max_retries: non_neg_integer()
        }

  @doc """
  Get a configuration value.

  ## Examples

      iex> BolagsverketEx.Config.get(:base_url)
      "https://gw.api.bolagsverket.se/vardefulla-datamangder/v1"

      iex> BolagsverketEx.Config.get(:unknown_key, "default")
      "default"
  """
  @spec get(atom(), term()) :: term()
  def get(key, default \\ nil) do
    Application.get_env(:bolagsverket_ex, key, default)
  end

  @doc """
  Get all configuration as a map.

  ## Examples

      iex> config = BolagsverketEx.Config.get_all()
      iex> is_map(config)
      true
  """
  @spec get_all() :: t()
  def get_all do
    %{
      client_id: get(:client_id),
      client_secret: get(:client_secret),
      token_url: get(:token_url),
      base_url: get(:base_url),
      scope: get(:scope, "vardefulla-datamangder:read"),
      request_timeout: get(:request_timeout, 30_000),
      retry_enabled: get(:retry_enabled, true),
      max_retries: get(:max_retries, 3)
    }
  end

  @doc """
  Validate that all required configuration is present.

  Returns `:ok` if configuration is valid, raises an error otherwise.

  ## Examples

      BolagsverketEx.Config.validate!()
      #=> :ok

  """
  @spec validate!() :: :ok | no_return()
  def validate! do
    required_keys = [:client_id, :client_secret, :token_url, :base_url]

    missing_keys =
      Enum.filter(required_keys, fn key ->
        case get(key) do
          nil -> true
          "" -> true
          _ -> false
        end
      end)

    case missing_keys do
      [] ->
        :ok

      keys ->
        raise """
        Missing required configuration for BolagsverketEx.

        Missing keys: #{inspect(keys)}

        Please configure in config/config.exs:

            config :bolagsverket_ex,
              client_id: "your_client_id",
              client_secret: "your_client_secret",
              token_url: "https://gw.api.bolagsverket.se/oauth2/token",
              base_url: "https://gw.api.bolagsverket.se/vardefulla-datamangder/v1"

        Or set environment variables:
              BOLAGSVERKET_CLIENT_ID
              BOLAGSVERKET_CLIENT_SECRET
        """
    end
  end
end
