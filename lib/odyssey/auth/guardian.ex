defmodule Odyssey.Auth.Guardian do
  use Guardian, otp_app: :odyssey,
    permissions: %{
      default: [:my_profile],
      admin: [:dashboard, :view_all_users, :edit_users]
    }

  use Guardian.Permissions.Bitwise

  alias Odyssey.Accounts


  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(claims) do
    user = claims["sub"]
    |> Accounts.get_user!
    {:ok, user}
  end

  def build_claims(claims, _resource, opts) do
    claims =
      claims
      |> encode_permissions_into_claims!(Keyword.get(opts, :permissions))
    {:ok, claims}
  end
end
