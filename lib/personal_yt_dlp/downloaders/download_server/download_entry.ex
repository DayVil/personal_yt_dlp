defmodule PersonalYtDlp.Downloaders.DownloadServer.DownloadEntry do
  alias PersonalYtDlp.Downloaders.DownloadServer.YoutubeFileInfo
  alias PersonalYtDlp.Downloaders.DownloadServer.LinkHandler
  alias PersonalYtDlp.Downloaders.DownloadServer.DownloadEntry

  @type t :: %__MODULE__{
          id: binary(),
          link: binary(),
          title: binary(),
          thumbnail: binary(),
          is_downloaded: boolean(),
          time_added: DateTime.t()
        }

  defstruct id: "",
            link: "",
            title: "",
            thumbnail: "",
            is_downloaded: false,
            dl_location: "",
            time_added: DateTime.utc_now()

  use Agent

  @name __MODULE__

  def start_link do
    Agent.start_link(fn -> %{entries: []} end, name: @name)
  end

  def get_all do
    Agent.get(@name, & &1).entries
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

  def add_link(link) do
    video_id = LinkHandler.extract_id(link)
    index = find_index_by_videoid(video_id)
    add_link(index, link, video_id)
  end

  defp add_link(nil, link, video_id) do
    {title, thumbnail_url} =
      YoutubeFileInfo.get_video_thumbnails_titles(video_id)
      |> List.first()

    entry = %DownloadEntry{
      id: video_id,
      link: link,
      title: title,
      thumbnail: thumbnail_url,
      is_downloaded: false,
      time_added: DateTime.utc_now()
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
end
