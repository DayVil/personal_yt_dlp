defmodule PersonalYtDlp.Downloaders.DownloadServer do
  alias PersonalYtDlp.Downloaders.DownloadServer.DownloadEntry
  require Logger
  use GenServer

  @register_name __MODULE__
  @interval 2
  @download_location Path.join([:code.priv_dir(:personal_yt_dlp), "static", "downloads"])

  def start_link(_) do
    if not check_ytdlp?(), do: raise("YTDlp not installed")

    if not File.exists?(@download_location) do
      File.mkdir!(@download_location)
    else
      curpwd = File.cwd!()
      File.cd!(@download_location)

      File.ls!(@download_location)
      |> Enum.each(&File.rm!/1)

      File.cd!(curpwd)
    end

    DownloadEntry.start_link()
    GenServer.start_link(@register_name, [], name: @register_name)
  end

  def add_yt_link(link) when is_binary(link) do
    if check_link?(link) do
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
    Logger.debug("Starting Download of #{link}")

    {:ok, path} = Exyt.download_getting_filename(link, %{output_path: @download_location})
    File.rename!(path, Path.join(@download_location, video_name))

    Logger.debug("Finished Download of #{link}")

    video = %DownloadEntry{video | is_downloaded: true}

    video = %DownloadEntry{video | dl_location: "/downloads/#{video_name}"}

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

  defp check_link?(link) do
    case link do
      "https://www.youtube.com/watch?" <> _ -> true
      # "https://youtu.be/" <> _ -> true
      _ -> false
    end
  end

  defp start_loop do
    Process.send_after(@register_name, :listen_queue, :timer.seconds(@interval))
  end
end
