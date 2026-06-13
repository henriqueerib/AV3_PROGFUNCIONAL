defmodule RotinaecoWeb.PageControllerTest do
  use RotinaecoWeb.ConnCase

  test "GET / renders the EcoHabits home page", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "EcoHabits"
    assert html_response(conn, 200) =~ "sustentáveis"
  end
end
