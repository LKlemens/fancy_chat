defmodule FancyChatWeb.PageController do
  use FancyChatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
