defmodule Previewer.Fetcher do
  use GenServer

  @regex ~r/background-image: url\((.*?)\)\;/

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def fetch(server, ytid) do
    GenServer.call(server, {:fetch, ytid})
  end

  def handle_call({:fetch, ytid}, _from, db = state) do

  	url = "https://www.youtube.com/watch?v=#{ytid}"
	 
	%HTTPotion.Response{status_code: 200, body: html} = HTTPotion.get(url)

  	css = html
	|> Floki.find("div.ytp-tooltip-bg")
	|> Floki.attribute("style")

	url = Regex.run(@regex, css, capture: :all_but_first)

    {:reply, url, state}
  end

end

#<div class="ytp-tooltip-bg" style="width: 159px; height: 89.5px; background-image: url(https://i9.ytimg.com/sb/7wzpOJP4N-E/storyboard3_L1/M0.jpg?sigh=fMTr_9ECIDiFbiOrN1YrJvu-REM); background-size: 1600px 900px; background-position: -320px -810px; background-repeat: initial initial;"><div class="ytp-tooltip-duration"></div></div>