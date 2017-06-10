defmodule Ytctapi.Word do
  use Ytctapi.Web, :model

  embedded_schema do
    field :simp, :string
    field :trad, :string
    field :pinyin, :string
    field :translation, :string

    #field :ytid, :string#s, {:array, :string}
    has_one :transscript, Ytctapi.Transscript
    
    field :views, :integer
    field :hsklevel, :integer
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:simp, :trad, :pinyin, :translation])
    |> validate_required([:simp])
    |> calculate_hsklevel()
    # |> Task.async(Ytctapi.Word, :calculate_hsklevel, [changeset])
  end

  defp calculate_hsklevel(changeset) do
    changeset
  end

end
