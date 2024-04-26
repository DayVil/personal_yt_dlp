defmodule PersonalYtDlp.Downloaders.DownloadServer.DownloadEntry do
  alias PersonalYtDlp.Downloaders.DownloadServer.DownloadEntry

  @type t :: %__MODULE__{
          id: binary(),
          link: binary(),
          title: binary(),
          is_downloaded: boolean()
        }

  defstruct id: "",
            link: "",
            title: "",
            is_downloaded: false

  use Agent

  @name __MODULE__

  def start_link do
    case System.get_env("YOUTUBE_API") do
      nil -> raise "Couldn't find the YT API Key"
      key -> Agent.start_link(fn -> %{api_key: key, entries: []} end, name: @name)
    end
  end

  def get_all do
    Agent.get(@name, & &1).entries
    |> Enum.reverse()
  end

  # TODO: video_ids might be doubled
  def add_link(link) do
    "https://www.youtube.com/watch?v=" <> video_id = link


    api_key = get_key()

    url_request =
      "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=#{video_id}&key=#{api_key}"

    title =
      Req.get!(url_request).body |> get_titles() |> List.first()

    entry = %DownloadEntry{
      id: video_id,
      link: link,
      title: title,
      is_downloaded: false
    }

    Agent.update(@name, fn %{entries: entries} = state ->
      %{state | entries: [entry | entries]}
    end)
  end

  defp get_key do
    Agent.get(@name, & &1).api_key
  end

  defp get_titles(request_content) do
    request_content
    |> get_in(["items"])
    |> Enum.map(fn video ->
      get_in(video, ~w(snippet title))
    end)
  end
end
