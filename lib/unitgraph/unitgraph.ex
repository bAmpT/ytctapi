defmodule Unitgraph do
  use GenServer

  def start_link(default) do
	GenServer.start_link(__MODULE__, default)
  end

  def init(state) do
    
    {:ok, state}
  end

  ## 

  def push(pid, item) do
    GenServer.cast(pid, {:push, item})
  end

  def handle_call(:pop, _from, [h | t]) do
    {:reply, h, t}
  end

  def handle_cast({:push, item}, state) do
    {:noreply, [item | state]}
  end

end