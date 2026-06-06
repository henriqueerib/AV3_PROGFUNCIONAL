defmodule Rotinaeco.Accounts.UserNotifier do
  import Swoosh.Email

  alias Rotinaeco.Mailer
  alias Rotinaeco.Accounts.User

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Rotinaeco", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Envia instruções para alterar o e-mail do usuário.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Instruções para alterar e-mail", """

    ==============================

    Olá #{user.email},

    Você pode alterar seu e-mail acessando o link abaixo:

    #{url}

    Se você não solicitou essa alteração, ignore este e-mail.

    ==============================
    """)
  end

  @doc """
  Envia instruções de acesso via link mágico.
  """
  def deliver_login_instructions(user, url) do
    case user do
      %User{confirmed_at: nil} -> deliver_confirmation_instructions(user, url)
      _ -> deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    deliver(user.email, "Link de acesso ao EcoHabits", """

    ==============================

    Olá #{user.email},

    Acesse sua conta clicando no link abaixo:

    #{url}

    Se você não solicitou este e-mail, ignore-o.

    ==============================
    """)
  end

  defp deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirme sua conta no EcoHabits", """

    ==============================

    Olá #{user.email},

    Confirme sua conta acessando o link abaixo:

    #{url}

    Se você não criou uma conta, ignore este e-mail.

    ==============================
    """)
  end
end
