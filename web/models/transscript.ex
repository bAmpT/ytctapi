defmodule Ytctapi.Transscript do
  use Ytctapi.Web, :model

  schema "transscripts" do
    field :ytid, :string
    field :title, :string
    field :language, :string
    field :lines, {:array, :map}
    field :views_count, :integer, default: 0
    field :likes_count, :integer, default: 0

    belongs_to :user, Ytctapi.User
    has_many :likes, Ytctapi.Like
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:ytid, :title, :language, :lines, :user_id])
  end

  def changeset_update(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :language, :lines])
  end
end
