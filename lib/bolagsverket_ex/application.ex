defmodule BolagsverketEx.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BolagsverketEx.TokenCache
    ]

    opts = [strategy: :one_for_one, name: BolagsverketEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
