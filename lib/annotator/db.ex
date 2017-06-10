defmodule Annotator.DB do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

   def init(:ok) do
    
    db = []
    # db = File.stream!("cedict_ts.u8", [], :line)
    # |> Stream.filter(fn(x) -> String.at(x, 0) != "#" end)
    # |> Stream.map(fn(x) -> match(x) end)
    # |> Enum.into(%{})

    # File.close(db)

    {:ok, db}
  end

  def match(string) do
    regex = ~r/(?<trad>.*)\s(?<simp>.*)\s\[(?<piny>.*)\]\s(?<trans>.*)/
    matches = Regex.named_captures(regex, string)
    {matches["simp"], matches}
  end

  def lookup(server, string) do
    GenServer.call(server, {:lookup, string})
  end

  def handle_call({:lookup, string}, _from, db = state) do
    {:reply, Map.fetch(db, string), state}
  end

end
