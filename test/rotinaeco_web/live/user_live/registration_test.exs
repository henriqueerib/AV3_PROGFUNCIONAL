defmodule RotinaecoWeb.UserLive.RegistrationTest do
  use RotinaecoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Rotinaeco.AccountsFixtures

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/sign-up")

      assert html =~ "Criar conta"
      assert html =~ "Entrar"
    end

    test "redirects if already logged in", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      assert {:error, {:live_redirect, %{to: "/dashboard"}}} = live(conn, ~p"/sign-up")
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/sign-up")

      result =
        lv
        |> element("#sign-up-form")
        |> render_change(user: %{"email" => "with spaces"})

      assert result =~ "must have the @ sign and no spaces"
    end
  end

  describe "register user" do
    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/sign-up")

      user = user_fixture()

      result =
        lv
        |> form("#sign-up-form",
          user: %{"email" => user.email, "password" => "senha123", "name" => "Test User"}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Entrar link is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/sign-up")

      {:ok, _live, html} =
        lv
        |> element("main a", "Entrar")
        |> render_click()
        |> follow_redirect(conn, ~p"/login")

      assert html =~ "Entrar"
    end
  end
end
