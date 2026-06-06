defmodule RotinaecoWeb.UserSessionController do
  use RotinaecoWeb, :controller

  alias Rotinaeco.Accounts
  alias RotinaecoWeb.UserAuth

  def create(conn, %{"_action" => "confirmed"} = params) do
    create(conn, params, "Conta confirmada com sucesso.")
  end

  def create(conn, params) do
    create(conn, params, "Bem-vindo de volta!")
  end

  # magic link login
  defp create(conn, %{"user" => %{"token" => token} = user_params}, info) do
    case Accounts.login_user_by_magic_link(token) do
      {:ok, {user, tokens_to_disconnect}} ->
        UserAuth.disconnect_sessions(tokens_to_disconnect)

        conn
        |> put_flash(:info, info)
        |> UserAuth.log_in_user(user, user_params)

      _ ->
        conn
        |> put_flash(:error, "O link é inválido ou expirou.")
        |> redirect(to: ~p"/login")
    end
  end

  # email + password login
  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # Evitar enumeração de usuários: não revelar se o e-mail está cadastrado
      conn
      |> put_flash(:error, "Credenciais inválidas")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/login")
    end
  end

  def update_password(conn, %{"user" => user_params} = params) do
    user = conn.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)
    {:ok, {_user, expired_tokens}} = Accounts.update_user_password(user, user_params)

    # desconectar todas as sessões LiveView ativas com a senha antiga
    UserAuth.disconnect_sessions(expired_tokens)

    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Senha atualizada com sucesso!")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Sessão encerrada com sucesso.")
    |> UserAuth.log_out_user()
  end
end
