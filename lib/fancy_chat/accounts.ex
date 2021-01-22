defmodule(FancyChat.Accounts) do
  import Ecto.Query
  alias FancyChat.Repo

  alias FancyChat.Accounts.User

  def list_all() do
    IO.inspect("pika repo")
    Repo.all(User)
  end

  def create_user(attr) do
    %User{}
    |> User.changeset(attr)
    |> Repo.insert()
  end
end
