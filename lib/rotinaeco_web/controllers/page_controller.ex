defmodule RotinaecoWeb.PageController do
  use RotinaecoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
