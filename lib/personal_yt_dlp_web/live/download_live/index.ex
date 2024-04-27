defmodule PersonalYtDlpWeb.DownloadLive.Index do
  alias PersonalYtDlp.Downloaders.DownloadServer
  use PersonalYtDlpWeb, :live_view
  alias PersonalYtDlpWeb.DownloadLive.FormComponent

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: PersonalYtDlp.Downloaders.subscripe_downloads()

    socket =
      socket
      |> assign(:page_title, "DownloadAnything")
      |> assign(:form, to_form(%{"url" => ""}))
      |> assign(:downloads, DownloadServer.get_videos() |> Enum.reverse())

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"url" => link}, socket) do
    DownloadServer.add_yt_link(link)

    socket =
      socket
      |> assign(
        :downloads,
        DownloadServer.get_videos() |> Enum.reverse()
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info({:finished_download, _vid_id}, socket) do
    socket =
      socket
      |> assign(:downloads, DownloadServer.get_videos() |> Enum.reverse())

    {:noreply, socket}
  end
end
