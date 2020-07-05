defmodule FancyChatWeb.RoomChannel do
  use FancyChatWeb, :channel

  def join("room:chat", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("broadcast_custom", payload, socket) do
    broadcast(socket, "broadcast_custom", payload)

    {:noreply, socket}
  end
end
