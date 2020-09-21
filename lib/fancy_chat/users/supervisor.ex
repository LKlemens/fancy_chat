defmodule FancyChat.Users.Supervisor do
  use DynamicSupervisor

  def start_link(_) do
    IO.inspect("jestsm w start link w supervisor")
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl DynamicSupervisor
  def init(_) do
    IO.inspect("inicjuje supervisor and users")
    # spec = [{FancyChat.Users, nil}]
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
