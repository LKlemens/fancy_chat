defmodule FancyChatWeb.RegistrationController do
  use FancyChatWeb, :controller
  alias FancyChat.User
  alias FancyChat.Accounts

  def new(conn, params) do
    render(conn, "register.html")
  end

  def create(conn, params) do
    IO.inspect({:nico, params})

    Accounts.create_user({})

    put_flash(conn, :info, "You successfully registered")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
