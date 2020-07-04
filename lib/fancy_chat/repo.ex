defmodule FancyChat.Repo do
  use Ecto.Repo,
    otp_app: :fancy_chat,
    adapter: Ecto.Adapters.Postgres
end
