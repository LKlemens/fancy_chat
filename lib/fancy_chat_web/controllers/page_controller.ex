defmodule FancyChatWeb.PageController do
  use FancyChatWeb, :controller
  alias FancyChat.User

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, %{"credentials" => %{"name" => name}}) do
    IO.inspect({:kurde, name})
    DynamicSupervisor.start_child(FancyChat.Users.Supervisor, {FancyChat.User, name})
    [{p, _}] = Registry.lookup(Registry.Users, name)
    IO.inspect({:pid, p})
    IO.inspect({:name, name})
    GenServer.cast(p, %{name: name})
    IO.inspect({:ile_dzieic, DynamicSupervisor.which_children(FancyChat.Users.Supervisor)})

    # render(conn, "login.html")
    redirect(conn, to: "/#{name}")
  end

  def show(conn, _params) do
    render(conn, "login.html")
  end
end
