defmodule FancyChat.User do
  use GenServer

  def start_link(name) do
    IO.inspect("jestem w genserver users #{name}")

    GenServer.start_link(__MODULE__, nil, name: {:via, Registry, {Registry.Users, name, nil}})
  end

  @impl GenServer
  def init(_) do
    IO.inspect({self(), "jestem w genserver users init "})
    {:ok, %{name: ""}}
  end

  @impl GenServer
  def handle_cast(%{name: name}, state) do
    IO.inspect({:jaaaaaaaaaaaaaaa})
    {:noreply, %{state | name: name}}
  end

  def push(name) do
    GenServer.cast(__MODULE__, name)
  end
end
