defmodule Odyssey.Auth.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
  otp_app: :odyssey,
  module: Odyssey.Auth.Guardian,
  error_handler: Odyssey.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
