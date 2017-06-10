defmodule Annotator do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    
    children = [
      worker(Annotator.DB, [])
    ]

    # Init ExJieba Library
    #ExJieba.MixSegment.init
  
    supervise(children, [strategy: :one_for_one, name: Annotator.Supervisor])
  end

  def jieba(string) do
    ExJieba.MixSegment.cut string
  end

  def lookup(strings) when is_list(strings) do Enum.map(strings, fn(x) -> lookup(x) end) end
  def lookup(string) do
    
    case GenServer.call(Annotator.DB, {:lookup, string})  do
      {:ok, result} -> result   
      :error -> %{}     
    end

  end

  def annotate(strings, type) do
    Enum.map(strings, fn(x) ->
      type.annotate(x)
    end)
    |> Enum.join
  end

end

