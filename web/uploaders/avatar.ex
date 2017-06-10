defmodule Ytctapi.Avatar do
  use Arc.Definition
  use Arc.Ecto.Definition
  def __storage, do: Arc.Storage.Local 

  @versions [:original, :thumb]

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 38x38^ -gravity center -extent 38x38 -format png", :png}
  end

  # Override the persisted filenames:
  def filename(version, {file, scope}) do
    "#{scope.id}_#{version}_#{file.file_name}_"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    "/media/uploads/#{scope.id}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  def default_url(version, _scope) do
    "/media/uploads/default_profile/default_profile_#{version}.jpg"
  end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end
end
