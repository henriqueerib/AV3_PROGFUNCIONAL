defmodule Rotinaeco.Accounts do
  alias Rotinaeco.Repo
  alias Rotinaeco.Accounts.User

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: String.downcase(email))
  end

  def update_profile(user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  def verify_password(user, password) do
    case user do
      nil -> false
      _ -> Pbkdf2.verify_pass(password, user.password_hash)
    end
  end

  def authenticate(email, password) do
    user = get_user_by_email(email)
    case verify_password(user, password) do
      true -> {:ok, user}
      _ -> {:error, "Invalid credentials"}
    end
  end
end
