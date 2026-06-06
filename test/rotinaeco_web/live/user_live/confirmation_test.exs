defmodule RotinaecoWeb.UserLive.ConfirmationTest do
  use RotinaecoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Rotinaeco.AccountsFixtures

  alias Rotinaeco.Accounts

  setup do
    %{user: user_fixture()}
  end

  describe "Confirm user" do
    test "logs confirmed user in via magic link", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_login_instructions(user, url)
        end)

      {:ok, lv, html} = live(conn, ~p"/users/log-in/#{token}")
      assert html =~ "Permanecer conectado"

      form = form(lv, "#login_form", %{"user" => %{"token" => token}})
      render_submit(form)

      conn = follow_trigger_action(form, conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
      assert get_session(conn, :user_token)
      assert Accounts.get_user!(user.id).confirmed_at == user.confirmed_at
    end

    test "raises error for invalid token", %{conn: conn} do
      {:ok, _lv, html} =
        live(conn, ~p"/users/log-in/invalid-token")
        |> follow_redirect(conn, ~p"/users/log-in")

      assert html =~ "inválido"
    end
  end
end
