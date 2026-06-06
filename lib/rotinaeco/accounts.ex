defmodule Rotinaeco.Accounts do
  import Ecto.Query, warn: false

  alias Rotinaeco.Repo
  alias Rotinaeco.Accounts.{User, UserToken, UserNotifier}

  @doc """
  Busca um usuário pelo e-mail.
  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Busca um usuário pelo e-mail e senha. Retorna nil se as credenciais forem inválidas.
  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Busca um usuário pelo ID. Lança erro se não existir.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Registra um novo usuário.
  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Retorna um changeset para o formulário de cadastro.
  """
  def change_user_registration(user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_unique: false)
  end

  @doc """
  Retorna um changeset para edição do perfil (nome e bio).
  """
  def change_user_profile(user, attrs \\ %{}) do
    User.profile_changeset(user, attrs)
  end

  @doc """
  Atualiza o perfil do usuário (nome e bio).
  """
  def update_profile(user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Calcula a pontuação total de um usuário somando os pontos de todos os seus check-ins.
  Retorna 0 se o usuário não tiver check-ins.
  """
  def total_score(user_id) do
    query =
      from c in Rotinaeco.CheckIns.CheckIn,
        join: h in Rotinaeco.Habits.Habit,
        on: c.habit_id == h.id,
        where: c.user_id == ^user_id,
        select: sum(h.points)

    Repo.one(query) || 0
  end

  @doc """
  Verifica se o usuário está em modo sudo (autenticado nos últimos 20 minutos).
  Usado para proteger a página de configurações.
  """
  def sudo_mode?(user, minutes \\ -20)

  def sudo_mode?(%User{authenticated_at: ts}, minutes) when is_struct(ts, DateTime) do
    DateTime.after?(ts, DateTime.utc_now() |> DateTime.add(minutes, :minute))
  end

  def sudo_mode?(_user, _minutes), do: false

  @doc """
  Retorna um changeset para alteração de e-mail.
  """
  def change_user_email(user, attrs \\ %{}, opts \\ []) do
    User.email_changeset(user, attrs, opts)
  end

  @doc """
  Atualiza o e-mail do usuário usando o token de confirmação enviado por e-mail.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    Repo.transact(fn ->
      with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
           %UserToken{sent_to: email} <- Repo.one(query),
           {:ok, user} <- Repo.update(User.email_changeset(user, %{email: email})),
           {_count, _result} <-
             Repo.delete_all(
               from(t in UserToken, where: t.user_id == ^user.id and t.context == ^context)
             ) do
        {:ok, user}
      else
        _ -> {:error, :transaction_aborted}
      end
    end)
  end

  @doc """
  Retorna um changeset para alteração de senha.
  """
  def change_user_password(user, attrs \\ %{}, opts \\ []) do
    User.password_changeset(user, attrs, opts)
  end

  @doc """
  Atualiza a senha do usuário e invalida todas as sessões anteriores.
  """
  def update_user_password(user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> update_user_and_delete_all_tokens()
  end

  @doc """
  Gera um token de sessão para o usuário.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Busca o usuário pelo token de sessão.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Busca o usuário pelo token de link mágico.
  """
  def get_user_by_magic_link_token(token) do
    with {:ok, query} <- UserToken.verify_magic_link_token_query(token),
         {user, _token} <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Realiza o login via link mágico, confirmando a conta se necessário.
  """
  def login_user_by_magic_link(token) do
    {:ok, query} = UserToken.verify_magic_link_token_query(token)

    case Repo.one(query) do
      {%User{confirmed_at: nil, hashed_password: hash}, _token} when not is_nil(hash) ->
        raise "login via link mágico não permitido para usuários não confirmados com senha definida"

      {%User{confirmed_at: nil} = user, _token} ->
        user
        |> User.confirm_changeset()
        |> update_user_and_delete_all_tokens()

      {user, token} ->
        Repo.delete!(token)
        {:ok, {user, []}}

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Envia o e-mail com o link para confirmar a alteração de e-mail.
  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")
    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Envia o e-mail com o link de acesso (magic link).
  """
  def deliver_login_instructions(%User{} = user, magic_link_url_fun)
      when is_function(magic_link_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "login")
    Repo.insert!(user_token)
    UserNotifier.deliver_login_instructions(user, magic_link_url_fun.(encoded_token))
  end

  @doc """
  Remove o token de sessão do banco (logout).
  """
  def delete_user_session_token(token) do
    Repo.delete_all(from(t in UserToken, where: t.token == ^token and t.context == "session"))
    :ok
  end

  defp update_user_and_delete_all_tokens(changeset) do
    Repo.transact(fn ->
      with {:ok, user} <- Repo.update(changeset) do
        tokens_to_expire = Repo.all(from(t in UserToken, where: t.user_id == ^user.id))
        token_ids = Enum.map(tokens_to_expire, & &1.id)
        Repo.delete_all(from(t in UserToken, where: t.id in ^token_ids))
        {:ok, {user, tokens_to_expire}}
      end
    end)
  end
end
