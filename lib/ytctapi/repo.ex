defmodule Ytctapi.Repo do
  use Ecto.Repo, otp_app: :ytctapi
  use Kerosene, per_page: 10
end
