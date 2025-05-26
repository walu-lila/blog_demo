# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :myapp, :scopes,
  user: [
    default: true,
    module: Myapp.Accounts.Scope,
    assign_key: :current_scope,
    access_path: [:user, :id],
    schema_key: :user_id,
    schema_type: :id,
    schema_table: :users,
    test_data_fixture: Myapp.AccountsFixtures,
    test_login_helper: :register_and_log_in_user
  ]

config :myapp,
  ecto_repos: [Myapp.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :myapp, MyappWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: MyappWeb.ErrorHTML, json: MyappWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Myapp.PubSub,
  live_view: [signing_salt: "GkZs+o4a"],
  code_reloader: config_env() == :dev,
  debug_errors: config_env() == :dev,
  check_origin: config_env() == :prod

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  myapp: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  myapp: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

if config_env() == :test do
    config :bcrypt_elixir, :log_rounds, 1

    config :myapp, Myapp.Repo,
        pool: Ecto.Adapters.SQL.Sandbox,
        pool_size: System.schedulers_online() * 2

    config :logger, level: :warning

    config :phoenix, :plug_init_mode, :runtime

    config :phoenix_live_view, enable_expensive_runtime_checks: true
end

if config_env() == :dev do
config :myapp, MyappWeb.Endpoint,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:myapp, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:myapp, ~w(--watch)]}
  ],
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/myapp_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :myapp, dev_routes: true

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true

end

if config_env() == :prod do
    config :logger, level: :info
end
