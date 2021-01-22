defmodule(FancyChat.Accounts.User) do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:username, :string, []}
  schema "users" do
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:hashed_password, :string)
  end

  def changeset(user, attr) do
    user
    |> cast(attr, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> unique_constraint([:username, :email])
    |> validate_length(:username, min: 2, max: 20)
    |> validate_length(:password, min: 6)
  end

  defp put_pass_digest(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :hashed_password, Comeonin.Bcrypt.hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
