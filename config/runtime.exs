import Config
import Dotenvy

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/myapp start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.

env_dir_prefix = System.get_env("RELEASE_ROOT") || Path.expand("./envs")

source!([
  Path.absname(".env", env_dir_prefix),
  Path.absname(".#{config_env()}.env", env_dir_prefix),
  Path.absname(".#{config_env()}.overrides.env", env_dir_prefix),
  System.get_env()
])

config :myapp, Myapp.Repo,
  username: env!("DATABASE_USERNAME"),
  password: env!("DATABASE_PASSWORD"),
  hostname: env!("DATABASE_HOSTNAME"),
  database: env!("DATABASE_DATABASE"),
  stacktrace: config_env() == :dev,
  show_sensitive_data_on_connection_error: config_env() == :dev,
  pool_size: env!("POOL_SIZE", :integer, 10),
  socket_options: if(env!("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: [])

if config_env() == :test do
  config :myapp, Myapp.Repo,
    database: "#{env!("DATABASE_DATABASE")}#{env!("MIX_TEST_PARTITION", :integer, 1)}",
    pool: Ecto.Adapters.SQL.Sandbox,
    pool_size: System.schedulers_online() * 2
end

config :myapp, MyappWeb.Endpoint,
  url: [
    host: env!("ENDPOINT_URL_HOST"),
    port: env!("ENDPOINT_URL_PORT", :integer),
    scheme: if(config_env() == :prod, do: "https", else: "http")
  ],
  http: [
    port: env!("PORT", :integer),
    ip: if(config_env() == :prod, do: {0, 0, 0, 0, 0, 0, 0, 0}, else: {127, 0, 0, 1})
  ],
  secret_key_base: env!("SECRET_KEY_BASE"),
  server: env!("PHX_SERVER", :boolean, false)


config :myapp, Myapp.Mailer,
  adapter: Swoosh.Adapters.Test,
  api_client: false,
  local: true

if config_env() == :dev do
  config :myapp, Myapp.Mailer, adapter: Swoosh.Adapters.Local
end

if config_env() == :prod do
  config :myapp, Myapp.Mailer,
    adapter: Swoosh.Adapters.MailGun,
    api_key: env!("MAILGUN_API_KEY"),
    domain: env!("MAILGUN_DOMAIN"),
    local: false,
    api_client: Swoosh.ApiClient.Req

  config :myapp, :dns_cluster_query, env!("DNS_CLUSTER_QUERY")
end
