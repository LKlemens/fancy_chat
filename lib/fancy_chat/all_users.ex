defmodule FancyChat.AllUsers do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(nil) do
    {:ok, :ets.new(:users, [:set, :private, :named_table])}
  end

  def handle_cast({:new, {name, id}}, state) do
    {:noreply, :ets.insert(:users, {name, id})}
  end

  def handle_call({:get_id, name}, _from, state) do
    [{_, id}] = :ets.lookup(:users, name)
    {:reply, id, state}
  end

  def handle_call(:all, _from, state) do
    {:reply, :ets.tab2list(:users), state}
  end
end
