defmodule Previewer do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    
    children = [
      worker(Previewer.Fetcher, [])
    ]
  
    supervise(children, [strategy: :one_for_one, name: Previewer.Supervisor])
  end

  def fetch(strings) when is_list(strings) do Enum.map(strings, fn(x) -> fetch(x) end) end
  def fetch(string) do
    
    case GenServer.call(Previewer.Fetcher, {:fetch, string})  do
      {:ok, result} -> result   
      :error -> %{}     
    end
  end

end
