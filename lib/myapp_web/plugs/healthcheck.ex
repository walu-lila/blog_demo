defmodule MyappWeb.Healthcheck do
  @moduledoc """
  A plug for healthcheck, bypasses TLS rewrites.
  """

  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(%{request_path: "/health"} = conn, _) do
    conn
    |> send_resp(200, "")
    |> halt()
  end

  def call(conn, _), do: conn
end
