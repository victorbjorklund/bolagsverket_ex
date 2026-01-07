defmodule BolagsverketEx.Client do
  @moduledoc """
  HTTP client with OAuth2 authentication for Bolagsverket API.

  Handles:
  - OAuth2 token management (fetch, refresh, cache)
  - HTTP requests with Req
  - Request/response middleware
  - Error handling and retries
  """

  alias BolagsverketEx.{Config, Error, TokenCache}

  @doc """
  Make a GET request to the API.

  ## Parameters

    - `path` - API path (e.g., "/isalive")
    - `opts` - Request options (optional)
      - `:request_id` - Custom request ID
      - `:timeout` - Request timeout in milliseconds

  ## Returns

    - `{:ok, Req.Response.t()}` on success
    - `{:error, Error.t()}` on failure

  ## Examples

      iex> BolagsverketEx.Client.get("/isalive")
      {:ok, %Req.Response{status: 200, body: "OK"}}
  """
  @spec get(String.t(), keyword()) :: {:ok, Req.Response.t()} | {:error, Error.t()}
  def get(path, opts \\ []) do
    with {:ok, token} <- get_access_token(),
         request <- build_request(path, token, opts),
         {:ok, response} <- execute_request(request, :get, nil) do
      handle_response({:ok, response})
    end
  end

  @doc """
  Make a POST request to the API.

  ## Parameters

    - `path` - API path
    - `body` - Request body (will be JSON-encoded)
    - `opts` - Request options

  ## Returns

    - `{:ok, Req.Response.t()}` on success
    - `{:error, Error.t()}` on failure

  ## Examples

      iex> body = %{identitetsbeteckning: "5299999994"}
      iex> BolagsverketEx.Client.post("/organisationer", body)
      {:ok, %Req.Response{status: 200, body: %{...}}}
  """
  @spec post(String.t(), map() | struct(), keyword()) ::
          {:ok, Req.Response.t()} | {:error, Error.t()}
  def post(path, body, opts \\ []) do
    with {:ok, token} <- get_access_token(),
         request <- build_request(path, token, opts),
         {:ok, response} <- execute_request(request, :post, body) do
      handle_response({:ok, response})
    end
  end

  @doc """
  Get OAuth2 access token (cached).

  Retrieves token from cache if valid, otherwise fetches a new one.

  ## Returns

    - `{:ok, String.t()}` - Access token
    - `{:error, Error.t()}` - Authentication error
  """
  @spec get_access_token() :: {:ok, String.t()} | {:error, Error.t()}
  def get_access_token do
    case TokenCache.get_token() do
      {:ok, token} ->
        {:ok, token}

      {:error, :expired} ->
        fetch_new_token()
    end
  end

  # Private functions

  defp fetch_new_token do
    client_id = Config.get(:client_id)
    client_secret = Config.get(:client_secret)
    token_url = Config.get(:token_url)
    scope = Config.get(:scope, "vardefulla-datamangder:read vardefulla-datamangder:ping")

    if is_nil(client_id) || is_nil(client_secret) || is_nil(token_url) do
      {:error,
       Error.config_error(
         "Missing OAuth2 configuration. Please set client_id, client_secret, and token_url."
       )}
    else
      request_body = %{
        grant_type: "client_credentials",
        client_id: client_id,
        client_secret: client_secret,
        scope: scope
      }

      IO.puts("\n=== OAuth2 Token Request ===")
      IO.inspect(token_url, label: "Token URL")
      IO.inspect(URI.parse(token_url).host, label: "Domain")
      IO.inspect(client_id, label: "Client ID")
      IO.inspect(scope, label: "Scope")

      case Req.post(token_url, form: request_body) do
        {:ok, %Req.Response{status: 200, body: body}} ->
          handle_token_response(body)

        {:ok, %Req.Response{status: status, body: body}} ->
          {:error,
           Error.auth_error("OAuth2 token request failed with status #{status}", %{
             status: status,
             body: body
           })}

        {:error, exception} ->
          {:error,
           Error.auth_error(
             "OAuth2 token request failed: #{Exception.message(exception)}",
             exception
           )}
      end
    end
  end

  defp handle_token_response(body) when is_map(body) do
    case body do
      %{"access_token" => token, "expires_in" => expires_in} ->
        TokenCache.put_token(token, expires_in)
        {:ok, token}

      %{"access_token" => token} ->
        # Default to 3600 seconds if no expires_in
        TokenCache.put_token(token, 3600)
        {:ok, token}

      _ ->
        {:error, Error.auth_error("Invalid token response format", body)}
    end
  end

  defp handle_token_response(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> handle_token_response(decoded)
      {:error, _} -> {:error, Error.auth_error("Failed to parse token response", body)}
    end
  end

  defp handle_token_response(body) do
    {:error, Error.auth_error("Unexpected token response format", body)}
  end

  defp build_request(path, token, opts) do
    base_url = Config.get(:base_url)
    timeout = Keyword.get(opts, :timeout, Config.get(:request_timeout, 30_000))
    request_id = Keyword.get_lazy(opts, :request_id, &generate_request_id/0)

    Req.new(
      base_url: base_url,
      url: path,
      headers: [
        {"authorization", "Bearer #{token}"},
        {"x-request-id", request_id},
        {"content-type", "application/json"},
        {"accept", "application/json"}
      ],
      receive_timeout: timeout,
      retry: :transient,
      max_retries: Config.get(:max_retries, 3),
      # Disable automatic JSON decoding - we'll handle it manually
      decode_body: false
    )
  end

  defp execute_request(request, :get, _body) do
    full_url = build_full_url(request)

    IO.puts("\n=== GET Request ===")
    IO.inspect(full_url, label: "Full URL")
    IO.inspect(URI.parse(full_url).host, label: "Domain")
    IO.inspect(request.url, label: "Path")
    IO.inspect(request.headers, label: "Headers")

    case Req.get(request) do
      {:ok, response} ->
        IO.puts("\n=== GET Response ===")
        IO.inspect(response.status, label: "Status")
        IO.inspect(byte_size(response.body), label: "Body size (bytes)")
        {:ok, response}

      {:error, exception} ->
        IO.puts("\n=== GET Error ===")
        IO.inspect(exception, label: "Exception")
        {:error, Error.from_exception(exception)}
    end
  rescue
    exception ->
      IO.puts("\n=== GET Rescue ===")
      IO.inspect(exception, label: "Exception")
      {:error, Error.from_exception(exception)}
  end

  defp execute_request(request, :post, body) do
    json_body = encode_body(body)
    full_url = build_full_url(request)

    IO.puts("\n=== POST Request ===")
    IO.inspect(full_url, label: "Full URL")
    IO.inspect(URI.parse(full_url).host, label: "Domain")
    IO.inspect(request.url, label: "Path")
    IO.inspect(request.headers, label: "Headers")
    IO.inspect(json_body, label: "Body")
    IO.puts("Body JSON: #{Jason.encode!(json_body)}")

    case Req.post(request, json: json_body) do
      {:ok, response} ->
        IO.puts("\n=== POST Response ===")
        IO.inspect(response.status, label: "Status")
        IO.inspect(byte_size(response.body), label: "Body size (bytes)")
        {:ok, response}

      {:error, exception} ->
        IO.puts("\n=== POST Error ===")
        IO.inspect(exception, label: "Exception")
        {:error, Error.from_exception(exception)}
    end
  rescue
    exception ->
      IO.puts("\n=== POST Rescue ===")
      IO.inspect(exception, label: "Exception")
      {:error, Error.from_exception(exception)}
  end

  defp encode_body(%{__struct__: _} = struct) do
    # If it's a struct, check if it has a to_map function
    if function_exported?(struct.__struct__, :to_map, 1) do
      struct.__struct__.to_map(struct)
    else
      # Otherwise convert to map manually
      struct |> Map.from_struct() |> Map.drop([:__struct__])
    end
  end

  defp encode_body(map) when is_map(map), do: map
  defp encode_body(other), do: other

  defp handle_response({:ok, %Req.Response{status: status} = response})
       when status >= 200 and status < 300 do
    {:ok, response}
  end

  defp handle_response({:ok, %Req.Response{} = response}) do
    Error.from_response(response)
  end

  defp build_full_url(request) do
    base = request.options[:base_url] || ""
    path = request.url.path || ""
    "#{base}#{path}"
  end

  defp generate_request_id do
    # Generate a UUID v4 (random)
    # Format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    # where 4 indicates version 4, and y is one of [8, 9, a, b]
    <<a1::32, a2::16, _::4, a3::12, _::2, a4::62>> = :crypto.strong_rand_bytes(16)

    # Set version to 4 (random) and variant to 2 (RFC 4122)
    hex_string =
      <<a1::32, a2::16, 4::4, a3::12, 2::2, a4::62>>
      |> Base.encode16(case: :lower)

    # Split into UUID format: 8-4-4-4-12
    <<p1::binary-size(8), p2::binary-size(4), p3::binary-size(4), p4::binary-size(4),
      p5::binary-size(12)>> = hex_string

    "#{p1}-#{p2}-#{p3}-#{p4}-#{p5}"
  end
end
