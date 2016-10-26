defmodule Ytctapi.LineView do
  use Ytctapi.Web, :view

  def render("lines.json", %{lines: lines}) do
    render_many(lines, Ytctapi.LineView, "line.json")
  end

  def render("line.json", %{line: line}) do
    %{t: line.t, q: line.q, a: line.a}
  end

end