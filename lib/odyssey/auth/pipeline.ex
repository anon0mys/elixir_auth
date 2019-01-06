defmodule Odyssey.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :odyssey,
    error_handler: Odyssey.Auth.ErrorHandler,
    module: Odyssey.Auth.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  plug Guardian.Plug.LoadResource, allow_blank: true
end
