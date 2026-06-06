defmodule Rotinaeco.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :utc_datetime
    field :authenticated_at, :utc_datetime, virtual: true
    field :name, :string
    field :bio, :string

    has_many :habits, Rotinaeco.Habits.Habit
    has_many :check_ins, Rotinaeco.CheckIns.CheckIn

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset de cadastro. Valida nome, e-mail e senha.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:name, :email, :password, :bio])
    |> validate_required([:name, :password])
    |> validate_length(:name, min: 3, max: 100)
    |> validate_email(opts)
    |> validate_password(opts)
  end

  @doc """
  Changeset para edição do perfil (nome e bio).
  """
  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :bio])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 100)
    |> validate_length(:bio, max: 500)
  end

  @doc """
  Changeset para alteração de e-mail.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
  end

  defp validate_email(changeset, opts) do
    changeset =
      changeset
      |> validate_required([:email])
      |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/,
        message: "deve conter @ e não pode ter espaços"
      )
      |> validate_length(:email, max: 160)

    if Keyword.get(opts, :validate_unique, true) do
      changeset
      |> unsafe_validate_unique(:email, Rotinaeco.Repo)
      |> unique_constraint(:email)
      |> validate_email_changed()
    else
      changeset
    end
  end

  defp validate_email_changed(changeset) do
    if get_field(changeset, :email) && get_change(changeset, :email) == nil do
      add_error(changeset, :email, "não foi alterado")
    else
      changeset
    end
  end

  @doc """
  Changeset para alteração de senha.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "as senhas não coincidem")
    |> validate_password(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 6, message: "deve ter no mínimo 6 caracteres")
    |> validate_length(:password, max: 72)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Pbkdf2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  Marca a conta como confirmada definindo o campo `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifica se a senha informada corresponde ao hash armazenado.
  """
  def valid_password?(%Rotinaeco.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Pbkdf2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Pbkdf2.no_user_verify()
    false
  end
end
