defmodule Ytctapi.Transscript do
  use Ytctapi.Web, :model

  alias Mongo.Ecto

  schema "transscripts" do
    field :ytid, :string
    field :title, :string
    field :description, :string
    field :language, :string
    field :lines, {:array, :map}, default: [], on_replace: :delete

    field :views_count, :integer, default: 0
    field :likes_count, :integer, default: 0
    field :words_count, :integer, default: 0
    field :comments_count, :integer, default: 0
    field :appreciate_count, :integer, default: 0
    
    field :difficulty, :integer, default: 1
    field :category, :string
    field :topic, :string
    field :gif_url, :string
    # embeds_many :lines, Line, on_replace: :delete

    belongs_to :user, Ytctapi.User
    has_many :likes, Ytctapi.Like
    has_many :comments, Ytctapi.Comment
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:ytid, :title, :language, :lines, :user_id, :words_count])
  end

  def changeset_update(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :language, :lines])
  end

  def generate_preview() do
    
  end

  def cache_likes_count() do
    
  end

  def temporary_dict(path) do
    name = Path.basename(path)
    dict = Path.join(System.tmp_dir, "#{name}")
    File.mkdir(dict)
    dict
  end

  def multi_id(<<_::24-binary>> = transscript_id), do: %{id: transscript_id}
  def multi_id(transscript_id) do
    %{ytid: transscript_id}
  end

end

# defmodule Line do
#   use Ecto.Model

#   embedded_schema do
#     field :t, Ecto.LazyFloat
#     field :q, :string
#     field :a, :string
#   end

#    def changeset(struct, params \\ %{}) do
#     struct
#     |> cast(params, [:t, :q, :a])
#   end
# end


