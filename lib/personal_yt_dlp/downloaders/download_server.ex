defmodule PersonalYtDlp.Downloaders.DownloadServer do
  alias PersonalYtDlp.Downloaders.DownloadServer.LinkHandler
  alias PersonalYtDlp.Downloaders.DownloadServer.DownloadEntry
  require Logger
  use GenServer

  @register_name __MODULE__
  @interval 2

  def start_link(_) do
    if not check_ytdlp?(), do: raise("YTDlp not installed")
    dl_location = get_download_location()
    reset_dl_path(dl_location)

    DownloadEntry.start_link()
    GenServer.start_link(@register_name, [], name: @register_name)
  end

  def add_yt_link(link) when is_binary(link) do
    if LinkHandler.is_valid_link?(link) do
      case DownloadEntry.add_link(link) do
        {:ok, video} = entry ->
          GenServer.cast(@register_name, {:append, video})
          entry

        entry ->
          entry
      end
    else
      Logger.debug("not a youtube link")
      {:error, "Not a youtube link"}
    end
  end

  def get_videos() do
    DownloadEntry.get_all()
  end

  @impl true
  def init(init_arg) do
    init =
      case init_arg do
        values when is_list(init_arg) -> values
        values when is_binary(init_arg) -> String.split(values, " ", trim: true)
        _ -> []
      end

    start_loop()
    {:ok, init}
  end

  @impl true
  def handle_cast({:append, link}, state) do
    state = List.insert_at(state, -1, link)

    {:noreply, state}
  end

  @impl true
  def handle_info(:listen_queue, state) do
    state = handle_queue(state)

    start_loop()
    {:noreply, state}
  end

  defp handle_queue([]), do: []

  defp handle_queue([%DownloadEntry{} = video | rest]) do
    link = video.link
    video_name = "#{video.id}.webm"
    Logger.debug("Starting Download of #{video.id}")

    download_location = get_download_location()
    {:ok, path} = Exyt.download_getting_filename(link, %{output_path: download_location})
    File.rename!(path, Path.join(download_location, video_name))

    Logger.debug("Finished Download of #{video.id}")

    video = %DownloadEntry{video | is_downloaded: true, dl_location: "/downloads/#{video_name}"}
    DownloadEntry.replace_entry(video)

    PersonalYtDlp.Downloaders.broadcast_download_finished(video.id)

    rest
  end

  defp check_ytdlp?() do
    case Exyt.check_setup() do
      "Installed yt-dlp" <> _ -> true
      "There some issue with your yt-dlp" <> _ -> false
    end
  end

  defp start_loop do
    Process.send_after(@register_name, :listen_queue, :timer.seconds(@interval))
  end

  defp get_download_location do
    Path.join([:code.priv_dir(:personal_yt_dlp), "static", "downloads"])
  end

  defp reset_dl_path(dl_location) do
    if not File.exists?(dl_location) do
      File.mkdir!(dl_location)
    else
      curpwd = File.cwd!()
      File.cd!(dl_location)

      File.ls!(dl_location)
      |> Enum.each(&File.rm!/1)

      File.cd!(curpwd)
    end

    nil
  end
end
