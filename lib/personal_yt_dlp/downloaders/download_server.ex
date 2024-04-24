defmodule PersonalYtDlp.Downloaders.DownloadServer do
  require Logger
  use GenServer

  @register_name __MODULE__
  @interval 2
  @download_location "./downloads"

  def start_link(_) do
    if not check_ytdlp?(), do: raise("YTDlp not installed")
    if not File.exists?(@download_location), do: File.mkdir!(@download_location)

    GenServer.start_link(@register_name, [], name: @register_name)
  end

  def add_yt_link(link) when is_binary(link) do
    if check_link?(link) do
      GenServer.cast(@register_name, {:append, link})
    else
      Logger.debug("not a youtube link")
    end
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

  defp handle_queue([link | rest]) do
    Logger.debug("Starting Download of #{link}")
    Exyt.download(link, %{output_path: @download_location})
    Logger.debug("Finished Download of #{link}")

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
      _ -> false
    end
  end

  defp start_loop do
    Process.send_after(@register_name, :listen_queue, :timer.seconds(@interval))
  end
end
