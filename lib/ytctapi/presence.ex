defmodule Ytctapi.Presence do
  use Phoenix.Presence, otp_app: :ytctapi,
                        pubsub_server: Ytctapi.PubSub
end
