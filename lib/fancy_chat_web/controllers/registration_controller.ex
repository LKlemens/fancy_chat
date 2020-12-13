defmodule FancyChatWeb.RegistrationController do
  use FancyChatWeb, :controller
  alias FancyChat.User

  def new(conn, params) do
    IO.inspect("hello")
    render(conn, "register.html")
  end

  def create(conn, params) do
    IO.inspect(params)

    put_flash(conn, :info, "You successfully registered")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
