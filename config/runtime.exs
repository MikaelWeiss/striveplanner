import Config

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
#     PHX_SERVER=true bin/strive_planner start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :strive_planner, StrivePlannerWeb.Endpoint, server: true
end

if config_env() == :prod do
  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :strive_planner, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :strive_planner, StrivePlannerWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # Configure Resend
  resend_api_key =
    System.get_env("RESEND_API_KEY") ||
      raise """
      environment variable RESEND_API_KEY is missing.
      Get it from your Resend dashboard at https://resend.com
      """

  config :resend, Resend.Client, api_key: resend_api_key

  # Configure reCAPTCHA
  recaptcha_site_key =
    System.get_env("RECAPTCHA_SITE_KEY") ||
      raise """
      environment variable RECAPTCHA_SITE_KEY is missing.
      Get it from your reCAPTCHA dashboard at https://www.google.com/recaptcha
      """

  recaptcha_secret_key =
    System.get_env("RECAPTCHA_SECRET_KEY") ||
      raise """
      environment variable RECAPTCHA_SECRET_KEY is missing.
      Get it from your reCAPTCHA dashboard at https://www.google.com/recaptcha
      """

  config :recaptcha,
    site_key: recaptcha_site_key,
    secret: recaptcha_secret_key,
    json_library: Jason
end
