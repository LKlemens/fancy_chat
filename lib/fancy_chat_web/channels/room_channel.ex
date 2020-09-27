defmodule FancyChatWeb.RoomChannel do
  use FancyChatWeb, :channel
  alias FancyChat.Users

  def join("room:" <> chat_id, payload, socket) do
    IO.inspect({:channelid, chat_id})
    IO.inspect({:jooooooooooooin1, socket})
    socket = assign(socket, :name, payload["name"])
    IO.inspect({:jooooooooooooin2, socket})
    IO.inspect({:plaaaaaaaaaaaaaaa, payload})
    {:ok, socket}
  end

  def handle_in("come_online", payload, socket) do
    IO.inspect({:come_online, payload})

    FancyChatWeb.Endpoint.broadcast!("room:general", "online_users", payload)
    push(socket, "online_users", payload)
    {:noreply, socket}
  end

  def handle_in("send_message", payload, socket) do
    IO.puts("hello gus")
    IO.inspect(payload)
    IO.inspect({:jooooooooooooin3, socket})
    id_receiver = GenServer.call(FancyChat.AllUsers, {:get_id, payload["message"]["receiver"]})
    id_sender = GenServer.call(FancyChat.AllUsers, {:get_id, payload["message"]["sender"]})
    # message = "#{payload["message"]["sender"]}: #{payload["message"]["msg"]}"
    message = %{sender: payload["message"]["sender"], msg: payload["message"]["msg"]}

    FancyChatWeb.Endpoint.broadcast!("room:#{id_receiver}", "send_message", message)

    FancyChatWeb.Endpoint.broadcast!("room:#{id_sender}", "send_message", message)

    {:noreply, socket}
  end
end
