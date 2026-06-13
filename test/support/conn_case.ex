defmodule RotinaecoWeb.ConnCase do

  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint RotinaecoWeb.Endpoint

      use RotinaecoWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import RotinaecoWeb.ConnCase
    end
  end

  setup tags do
    Rotinaeco.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def register_and_log_in_user(%{conn: conn} = context) do
    user = Rotinaeco.AccountsFixtures.user_fixture()
    scope = Rotinaeco.Accounts.Scope.for_user(user)

    opts =
      context
      |> Map.take([:token_authenticated_at])
      |> Enum.into([])

    %{conn: log_in_user(conn, user, opts), user: user, scope: scope}
  end

  def log_in_user(conn, user, opts \\ []) do
    token = Rotinaeco.Accounts.generate_user_session_token(user)

    maybe_set_token_authenticated_at(token, opts[:token_authenticated_at])

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  defp maybe_set_token_authenticated_at(_token, nil), do: nil

  defp maybe_set_token_authenticated_at(token, authenticated_at) do
    Rotinaeco.AccountsFixtures.override_token_authenticated_at(token, authenticated_at)
  end
end
