defmodule FancyChatWeb.RoomChannel do
  use FancyChatWeb, :channel
  alias FancyChat.Users

  def join("room:chat", payload, socket) do
    IO.inspect({:jooooooooooooin1, socket})
    socket = assign(socket, :name, payload["name"])
    IO.inspect({:jooooooooooooin2, socket})
    IO.inspect({:plaaaaaaaaaaaaaaa, payload})
    # {:ok, Map.put(socket.assigns, :name, payload["name"])}
    {:ok, socket}
  end

  def handle_in("broadcast_custom", payload, socket) do
    IO.puts("hello gus")
    IO.inspect(payload)
    IO.inspect({:jooooooooooooin3, socket})
    # [{p, _}] = Registry.lookup(Registry.Users, )
    broadcast(socket, "broadcast_custom", Map.put(payload, :name, socket.assigns.name))
    # FancyChat.Users.push(payload.name)

    {:noreply, socket}
  end
end
