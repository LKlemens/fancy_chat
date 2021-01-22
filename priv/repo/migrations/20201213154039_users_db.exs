defmodule FancyChat.Repo.Migrations.UsersDb do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:username, :string, primary_key: true)
      add(:email, :string, null: false, unique: true)
      add(:hashed_password, :string, null: false)
      timestamps()
    end
  end
end
