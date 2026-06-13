defmodule RotinaecoWeb.PageController do
  use RotinaecoWeb, :controller

  def home(conn, _params) do
    if conn.assigns[:current_scope] && conn.assigns[:current_scope].user do
      redirect(conn, to: ~p"/dashboard")
    else
      render(conn, :home, current_scope: conn.assigns[:current_scope])
    end
  end
end
