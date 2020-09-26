defmodule FancyChat.User do
  use GenServer

  def start_link(name) do
    IO.inspect("jestem w genserver users #{name}")

    GenServer.start_link(__MODULE__, nil, name: {:via, Registry, {Registry.Users, name, nil}})
  end

  @impl GenServer
  def init(_) do
    IO.inspect({self(), "jestem w genserver users init "})
    {:ok, %{name: "", id: ""}}
  end

  @impl GenServer
  def handle_cast(%{name: name, id: id}, state) do
    IO.inspect({:jaaaaaaaaaaaaaaa})
    {:noreply, %{state | name: name, id: id}}
  end

  @impl GenServer
  def handle_call(:get_id, _from, state) do
    {:reply, state.id, state}
  end

  @impl GenServer
  def handle_call(:get_name, _from, state) do
    {:reply, state.name, state}
  end

  def push(name) do
    GenServer.cast(__MODULE__, name)
  end
end
