defmodule Ytctapi.TransscriptController do
  use Ytctapi.Web, :controller
  use Guardian.Phoenix.Controller

  alias Ytctapi.Transscript
  alias Mongo

  # plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__
require IEx

  def index(conn, params, _u, _c) do
    transscripts = Repo.all(from t in Transscript, order_by: [desc: :inserted_at]) 
                  |> Repo.preload(:likes)
                  

  IEx.pry
    {transscripts, kerosene} = Repo.paginate(transscripts)
    IO.inspect kerosene

    render(conn, "index.json", transscripts: transscripts, kerosene: kerosene)
  end

  def create(conn, %{"transscript" => transscript_params}, user, _claims) do
    #if {}"zh/zh" = Map.get(transscript_params, "language", lines) do end
    {lines, words_count} = Enum.map_reduce(
      Map.get(transscript_params, "lines"), 0, fn(line, acc) ->
        # Word HSK Level?
        words = ExJieba.MixSegment.cut( Map.get(line, "q") )
        {Map.put(line, "jieba_q", words), Enum.count(words) + acc} 
      end
    )
    transscript_params = Map.put(transscript_params, "lines", lines)
    # transscript_params = %{transscript_params | lines: lines}
    transscript_params = Map.put(transscript_params, "words_count", words_count)

    transscript_params = Map.put(transscript_params, "user_id", user.id)
    changeset = Transscript.changeset(%Transscript{}, transscript_params)

    # Cache gif preview
    Task.Supervisor.start_child(Ytctapi.TaskSupervisor, fn ->
      IO.puts "starting child: Task"

      # ytid = Ecto.Changeset.get_field(changeset, :ytid)
      # gif_path = "/media/gifs/#{ytid}.gif"
      # youtube_url = "https://www.youtube.com/watch?v=" <> ytid
      
      with ytid = Ecto.Changeset.get_field(changeset, :ytid),
         tmp = Transscript.temporary_dict(ytid),
         gif_path = "/media/gifs/#{ytid}.gif",
         video_path = Path.join(tmp, ytid<>".mp4"),
         args = ["-f", "bestvideo[height<=240]/mp4", "https://www.youtube.com/watch?v=#{ytid}", "-o", "#{video_path}"],
         {_output, _} <- System.cmd("youtube-dl", args),
         args = ["-i", "#{video_path}", "-f", "null", "/dev/null"],
         {framestring, _} = System.cmd("ffmpeg", args, stderr_to_stdout: true),
         frames = String.split(framestring, "frame=") |> Enum.at(1) |> String.split("fps=") |> Enum.at(0) |> String.trim,
         ffmpeg_arguments = ["-i", "#{video_path}", "-vf", "fps=10/(#{frames})", Path.join(tmp, ytid<>"_%03d.png")],
         {_, _} <- System.cmd("ffmpeg", ffmpeg_arguments, stderr_to_stdout: true),
         convert_args = ["-loop", "0", "-delay", "100", "-resize", "375", Path.join(tmp, ytid<>"_*.png"), gif_path],
         do: System.cmd("convert", convert_args)
          
         
        # |> Ecto.Changeset.change
        # Ecto.Changeset.put_change(changeset, :gif_url, "/gifs/#{ytid}.gif")
        # Repo.update!(changeset)
      IO.puts "ending child: Task"
    end) 
  
    case Repo.insert(changeset) do
      {:ok, transscript} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", transscript_path(conn, :show, transscript))
        |> render("show.json", transscript: transscript)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Ytctapi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _user, _claims) do
    transscript = Repo.get_by!(Transscript, Transscript.multi_id(id))
    
    render(conn, "show.json", transscript: transscript)
  end

  def update(conn, %{"id" => id, "transscript" => transscript_params}, user, _claims) do
    transscript = Repo.get_by!(Transscript, id: id, user_id: user.id)
    changeset = Transscript.changeset(transscript, transscript_params)

    case Repo.update(changeset) do
      {:ok, transscript} ->
        render(conn, "show.json", transscript: transscript)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Ytctapi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user, _claims) do
    transscript = Repo.get_by!(Transscript, id: id, user_id: user.id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(transscript)

    #TODO:
    # Update Likes Count in Transscript

    send_resp(conn, :no_content, "")
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> json(%{message: "Authentication required"})
  end

end
