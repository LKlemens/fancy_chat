defmodule FancyChatWeb.RoomChannel do
  use FancyChatWeb, :channel
  alias FancyChat.Users

  def join("room:" <> chat_id, payload, socket) do
    IO.inspect({:channelid, chat_id})
    IO.inspect({:jooooooooooooin1, socket})
    socket = assign(socket, :name, payload["name"])
    IO.inspect({:jooooooooooooin2, socket})
    IO.inspect({:plaaaaaaaaaaaaaaa, payload})
    # {:ok, Map.put(socket.assigns, :name, payload["name"])}
    {:ok, socket}
  end

  def handle_in("come_online", payload, socket) do
    IO.inspect({:come_online, payload})
    # broadcast(socket, "online_users", payload)

    FancyChatWeb.Endpoint.broadcast!("room:general", "online_users", payload)
    push(socket, "online_users", payload)
    {:noreply, socket}
  end

  def handle_in("broadcast_custom", payload, socket) do
    IO.puts("hello gus")
    IO.inspect(payload)
    IO.inspect({:jooooooooooooin3, socket})
    # [{p, _}] = Registry.lookup(Registry.Users, )
    broadcast(socket, "broadcast_custom", Map.put(payload, :name, socket.assigns.name))

    # broadcast(socket, "online_users", payload)
    # FancyChat.Users.push(payload.name)
    # FancyChatWeb.Endpoint.broadcast!("room:#{id}", "msg", %{})

    {:noreply, socket}
  end
end
