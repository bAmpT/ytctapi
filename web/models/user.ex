defmodule Ytctapi.User do
  use Ytctapi.Web, :model
  use Arc.Ecto.Schema

  #import Comeonin.Bcrypt

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string

    field :avatar, Ytctapi.Avatar.Type

    has_many :transscripts, Ytctapi.Transscript
    has_many :likes, Ytctapi.Like
    
    embeds_many :words, Ytctapi.Word
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :encrypted_password])
    |> cast_attachments(params, [:avatar])
    |> validate_required([:username])
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email], [:password])
    |> validate_required([:username, :email])
    |> put_password_hash()
  end

  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
      _ -> 
        changeset
    end
  end

  def transscript_count(user) do
    Ytctapi.Repo.all from(t in Ytctapi.Transscript,
      where: t.user_id == ^user.id,
      select: count(t.id))
  end
  
end
