defmodule Ytctapi do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Ytctapi.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Ytctapi.Endpoint, []),
      # Start the Presence server
      supervisor(Ytctapi.Presence, []),
      # Start the Task supervisor
      supervisor(Task.Supervisor, [[name: Ytctapi.TaskSupervisor]]),
      # Start the Annotator supervisor
      supervisor(Annotator, [])
    ]

    # workers = [
    #   worker(Ytctapi.PushCollector, []),
    #   worker(Ytctapi.Pusher, [Ytctapi.PushCollector], {producer: Ytctapi.PushCollector, id: 1})
    # ] 
    
    {:ok, collector} = Ytctapi.PushCollector.start_link()
    for id <- 1..System.schedulers_online * 2 do
      Ytctapi.Pusher.start_link(Ytctapi.PushCollector, {collector, id})
    end

    # Init ExJieba Library
    ExJieba.MixSegment.init
    
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ytctapi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Ytctapi.Endpoint.config_change(changed, removed)
    :ok
  end
end
