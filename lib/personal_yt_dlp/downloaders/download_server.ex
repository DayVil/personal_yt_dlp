defmodule PersonalYtDlp.Downloaders.DownloadServer do
  use GenServer

  @register_name __MODULE__

  # Client

  def start_link(_) do
    GenServer.start_link(@register_name, [], name: @register_name)
  end

  def add_yt_link(link) when is_binary(link) do
    GenServer.cast(@register_name, {:append, link})
  end

  # Server

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
    state =
      case state do
        [] ->
          []

        [value | state] ->
          IO.inspect(value)
          state
      end

    start_loop()
    {:noreply, state}
  end

  defp start_loop do
    Process.send_after(@register_name, :listen_queue, :timer.seconds(2))
  end
end
