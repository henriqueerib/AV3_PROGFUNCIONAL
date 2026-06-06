defmodule RotinaecoWeb.UserLive.LoginTest do
  use RotinaecoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Rotinaeco.AccountsFixtures

  describe "login page" do
    test "renders login page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/login")

      assert html =~ "Entrar"
      assert html =~ "Cadastre-se"
    end
  end

  describe "user login - password" do
    test "redirects if user logs in with valid credentials", %{conn: conn} do
      user = user_fixture()

      {:ok, lv, _html} = live(conn, ~p"/login")

      form = form(lv, "#login-form", user: %{email: user.email, password: valid_user_password()})
      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/dashboard"
    end

    test "redirects to login page with a flash error if credentials are invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/login")

      form = form(lv, "#login-form", user: %{email: "test@email.com", password: "wrongpass"})
      conn = submit_form(form, conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Credenciais inválidas"
      assert redirected_to(conn) == ~p"/login"
    end
  end

  describe "login navigation" do
    test "redirects to registration page when the Cadastre-se link is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/login")

      {:ok, _live, html} =
        lv
        |> element("main a", "Cadastre-se gratuitamente")
        |> render_click()
        |> follow_redirect(conn, ~p"/sign-up")

      assert html =~ "Criar conta"
    end
  end
end
