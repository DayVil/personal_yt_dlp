defmodule PersonalYtDlp.Downloaders do
  @moduledoc """
  The Downloaders context.
  """
  alias Phoenix.PubSub
  @topic inspect(__MODULE__)
  @pubsub_name PersonalYtDlp.PubSub

  def subscripe_downloads() do
    PubSub.subscribe(@pubsub_name, @topic)
  end

  def broadcast_download_finished(vid_id) do
    PubSub.broadcast(@pubsub_name, @topic, {:finished_download, vid_id})
  end
end
