defmodule Ytctapi.PushCollector do
  use GenStage

  @max_buffer_size 100000
  
  # Client
  
  def push(pid, push_requests) do
    GenServer.cast(pid, {:push, push_requests})
  end
  
  # Server
  
  def start_link do
    GenStage.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def init(_args) do
    # Run as producer and specify the max amount 
    # of push requests to buffer.
    {:producer, :ok, buffer_size: @max_buffer_size}
  end
  
  def handle_cast({:push, push_requests}, state) do
    # Dispatch the push_requests as events.
    # These will be buffered if there are no consumers ready.
    {:noreply, push_requests, state}
  end
  
  def handle_demand(_demand, state) do
    # Do nothing. Events will be dispatched as-is.
    {:noreply, [], state}
  end
end