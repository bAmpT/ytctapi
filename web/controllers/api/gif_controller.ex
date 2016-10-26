defmodule Ytctapi.GifController do
  use Ytctapi.Web, :controller

  alias Ytctapi.Transscript

  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def show(conn, %{"id" => id}) do

    # priv_dir = :code.priv_dir(:ytctapi)
    # gif_path = "#{priv_dir}/static/gifs/#{id}.gif"
    gif_path = "/media/gifs/#{id}.gif"

    if File.regular?(gif_path) do 
      conn 
      |> put_status(:unprocessable_entity)
      |> redirect(to: "/gifs/"<>id<>".gif") 
      |> halt()

    else 
      youtube_url = "https://www.youtube.com/watch?v=" <> id
      video_path = temporary_path_for(id, id <> ".mp4")

      # youtube-dl -f 'bestvideo[height<=240]/mp4' https://www.youtube.com/watch?v=PpccpglnNf0 -o video.mp4
      youtubedl_args = %{f: "bestvideo[height<=240]/mp4"}
      {output, _} = System.cmd "youtube-dl", youtubedl_arguments(youtube_url, video_path, youtubedl_args), stderr_to_stdout: true
      IO.inspect output
      IO.puts "-----------------------------------------------------"
      
      images_path = temporary_path_for(id, id <> "%03d.png")
      
      #exec.Command("ffmpeg", "-i", filename, "-vf", "fps=1/60", "MantouGushi/images/ffout%03d.png")
      ffmpeg_args = %{i: video_path, vf: "fps=1/60"}
      IO.inspect ffmpeg_arguments(images_path, ffmpeg_args)
      {output, _} = System.cmd "ffmpeg", ffmpeg_arguments(images_path, ffmpeg_args), stderr_to_stdout: true
      IO.inspect output
      IO.puts "-----------------------------------------------------"

      input_path = String.replace(images_path, "%03d", "*")

      # convert -loop 0 -delay 100 -resize 365 ffout*.png output.gif
      convert_args = %{loop: "0", delay: "100", resize: "375"}
      {output, _} = System.cmd "convert", arguments(input_path, gif_path, convert_args), stderr_to_stdout: true
      IO.inspect output
      IO.puts "-----------------------------------------------------"
      
      File.rm_rf(temporary_path_for(id, ""))


      # changeset = transscript
      #   |> Ecto.Changeset.change
      #   |> Ecto.Changeset.put_change(:gif_url, gif_url)

      #  Repo.update!(changeset)
      conn
      |> put_status(:created)
      |> redirect(to: "/gifs/"<>id<>".gif")
    end
  end

  defp youtubedl_arguments(input_path, output_path, operations) do
    base_arguments = ~w(#{input_path} -o #{String.replace(output_path, " ", "\\ ")})
    additional_arguments = Enum.flat_map operations, fn {option,params} -> ~w(-#{option} #{params}) end

    additional_arguments ++ base_arguments
  end

  defp ffmpeg_arguments(output_path, operations) do
    base_arguments = ~w(#{String.replace(output_path, " ", "\\ ")})
    additional_arguments = Enum.flat_map operations, fn {option,params} -> ~w(-#{option} #{params}) end

    additional_arguments ++ base_arguments
  end

  defp arguments(image_path, gif_path, operations) do
    base_arguments = ~w(#{String.replace(image_path, " ", "\\ ")} #{gif_path})
    additional_arguments = Enum.flat_map operations, fn {option,params} -> ~w(-#{option} #{params}) end

    additional_arguments ++ base_arguments
  end

  def temporary_path_for(dict, path) do
    name = Path.basename(path)
    Path.join(System.tmp_dir, "/#{dict}/#{name}")
  end

  def do_temporary_path_for(path) do
    name = Path.basename(path)
    random = :crypto.rand_uniform(100_000, 999_999)
    Path.join(System.tmp_dir, "#{random}-#{name}")
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> json(%{message: "Authentication required"})
  end

end
