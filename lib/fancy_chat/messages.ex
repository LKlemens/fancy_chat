defmodule FancyChat.Messages do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(nil) do
    {:ok, :ets.new(:messages, [:duplicate_bug, :private, :named_table])}
  end

  def handle_cast({:new, {user1, user2}}, state) do
    {:noreply, :ets.insert(:messages, {user1, user2, []})}
  end

  def handle_cast({:update, {user1, user2, msg}}, state) do
    {:noreply, :ets.update_element(:messages, {user1, user2, []})}
  end

  def handle_call({:get_id, name}, _from, state) do
    [{_, id}] = :ets.lookup(:messages, name)
    {:reply, id, state}
  end

  def handle_call(:all, _from, state) do
    {:reply, :ets.tab2list(:messages), state}
  end
end
