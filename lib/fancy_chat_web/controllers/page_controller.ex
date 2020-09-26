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
    id = Base.encode16(:crypto.strong_rand_bytes(8))
    GenServer.cast(p, %{name: name, id: id})
    GenServer.cast(FancyChat.AllUsers, {:new, {name, id}})
    IO.inspect({:ile_dzieic, DynamicSupervisor.which_children(FancyChat.Users.Supervisor)})
    IO.inspect({:alle_usersssss, GenServer.call(FancyChat.AllUsers, :all)})
    conn = assign(conn, :name, name)
    IO.inspect({:check_create, conn})

    # render(conn, "login.html")
    redirect(conn, to: "/#{name}")
  end

  def show(conn, params) do
    [{p, _}] = Registry.lookup(Registry.Users, params["id"])
    IO.inspect({:ile_dzieic, DynamicSupervisor.which_children(FancyChat.Users.Supervisor)})

    names =
      GenServer.call(FancyChat.AllUsers, :all)
      |> Enum.map(fn {name, _} -> name end)

    IO.inspect({:namerrrrr, names})
    id = GenServer.call(p, :get_id)
    conn = assign(conn, :id, id)
    conn = assign(conn, :names, names)
    IO.inspect({:show_chec, conn})
    IO.inspect({:show_checpara, params})
    render(conn, "login.html")
  end
end
