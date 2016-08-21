defmodule Ytctapi.User do
  use Ytctapi.Web, :model

  import Comeonin.Bcrypt

  schema "users" do
    field :username, :string
    field :email, :string
    field :encrypted_password, :string

    has_many :transscripts, Ytctapi.Transscript
    has_many :likes, Ytctapi.Like
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email])
  end

  def hashpassword(password) do
    hashpwsalt(password)
  end
end
