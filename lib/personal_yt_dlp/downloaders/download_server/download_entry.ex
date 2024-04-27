defmodule PersonalYtDlp.Downloaders.DownloadServer.DownloadEntry do
  alias PersonalYtDlp.Downloaders.DownloadServer.DownloadEntry

  @type t :: %__MODULE__{
          id: binary(),
          link: binary(),
          title: binary(),
          thumbnail: binary(),
          is_downloaded: boolean()
        }

  defstruct id: "",
            link: "",
            title: "",
            thumbnail: "",
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
    # |> Enum.reverse()
  end

  def replace_entry(%DownloadEntry{} = video) do
    all_videos = get_all()
    vid_id = find_index_by_videoid(video.id)

    case vid_id do
      nil ->
        nil

      vid_id ->
        new_state = List.replace_at(all_videos, vid_id, video)

        Agent.update(@name, fn state ->
          %{state | entries: new_state}
        end)

        Enum.at(new_state, vid_id)
    end
  end

  def find_index_by_videoid(video_id) do
    Enum.find_index(get_all(), fn agent_vid -> video_id === agent_vid.id end)
  end

  # TODO: video_ids might be doubled
  def add_link(link) do
    "https://www.youtube.com/watch?v=" <> video_id = link
    index = find_index_by_videoid(video_id)
    add_link(index, link, video_id)
  end

  defp add_link(nil, link, video_id) do
    api_key = get_key()

    url_request =
      "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=#{video_id}&key=#{api_key}"

    {title, thumbnail_url} =
      Req.get!(url_request).body
      |> get_titles_thumbnails()
      |> List.first()

    entry = %DownloadEntry{
      id: video_id,
      link: link,
      title: title,
      thumbnail: thumbnail_url,
      is_downloaded: false
    }

    Agent.update(@name, fn %{entries: entries} = state ->
      %{state | entries: [entry | entries]}
    end)

    {:ok, entry}
  end

  defp add_link(id, _link, _video_id) when is_integer(id) do
    entry =
      get_all()
      |> Enum.at(id)

    {:error, entry}
  end

  defp get_key do
    Agent.get(@name, & &1).api_key
  end

  defp get_titles_thumbnails(request_content) do
    request_content
    |> get_in(["items"])
    |> Enum.map(fn video ->
      {get_in(video, ~w(snippet title)), get_in(video, ~w(snippet thumbnails standard url))}
    end)
  end
end
