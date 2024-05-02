defmodule PersonalYtDlp.Downloaders.DownloadServer.YoutubeFileInfo do
  def get_video_thumbnails_titles(video_id) do
    get_video_url(video_id)
    |> Req.get!()
    |> Map.get(:body)
    |> get_in(["items"])
    |> Enum.map(fn video ->
      {get_in(video, ~w(snippet title)), get_in(video, ~w(snippet thumbnails standard url))}
    end)
  end

  defp get_video_url(video_id) do
    api_key = get_api_key()

    "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=#{video_id}&key=#{api_key}"
  end

  defp get_api_key do
    System.get_env("YOUTUBE_API")
  end
end
