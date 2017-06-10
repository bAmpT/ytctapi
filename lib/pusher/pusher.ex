defmodule Ytctapi.Pusher do
  use GenStage
  # The maximum number of requests Firebase allows at once
  @max_demand 100 
  
  defstruct [
    :producer,
    :producer_from,
    :conn_id,
    :pending_requests, # %{messageid: message}
    :next_id
  ]
  
  def start_link(producer, conn_id, opts \\ []) do
    GenStage.start_link(__MODULE__, {producer, conn_id}, opts)
  end
  
  def init({producer, conn_id}) do
    state = %__MODULE__{
      next_id: 1,
      pending_requests: Map.new,
      producer: producer,
      conn_id: conn_id,
    }
    send(self, :init)
    # Run as consumer
    {:consumer, state}
  end
  
  def handle_info(:init, %{producer: producer}=state) do
    # Subscribe to the Push Collector
    GenStage.async_subscribe(self, to: producer, cancel: :temporary)
    {:noreply, [], state}
  end
  
  def handle_subscribe(:producer, _opts, from, state) do
    # Start demanding requests now that we are subscribed
    GenStage.ask(from, @max_demand)
    {:manual, %{state | producer_from: from}}
  end
  
  def handle_events(push_requests, _from, state) do
    # We got some push requests from the Push Collector.
    # Let’s send them.
    for push_request <- push_requests do
      IO.inspect {self(), push_request}
      state = do_send(state, push_request)
    end
    # state = Enum.reduce(push_requests, state,  &do_send/2)
    {:noreply, [], state}
  end
  
  # Send the message to FCM, track as a pending request
  defp do_send(%{conn_id: _conn_id, pending_requests: pending_requests}=state, push_request) do
    {message_id, state} = generate_id(state)
    # xml = PushRequest.to_xml(push_request, message_id)
    # :ok = Ytctapi.Connection.send(conn_id, xml)
    #do_response(%{message_id: message_id}, state)

    pending_requests = Map.put(pending_requests, message_id, push_request)
    %{state | pending_requests: pending_requests}
  end
  
  # FCM response handling
  defp do_response(%{message_id: message_id}=response, %{pending_requests: pending_requests, producer_from: producer_from}=state) do
    {push_request, pending_requests} = Map.pop(pending_requests, message_id)
    
    # Since we finished a request, ask the Push Collector for more.
    GenStage.ask(producer_from, 1)
    
    %{state | pending_requests: pending_requests}
  end

  defp generate_id(%{next_id: next_id}=state) do
    {to_string(next_id), %{state | next_id: next_id + 1}}
  end
end

 