defmodule Ytctapi.Like do
  use Ytctapi.Web, :model

  schema "likes" do
    belongs_to :user, Ytctapi.User
    belongs_to :transscript, Ytctapi.Transscript

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :transscript_id])
  end
end
