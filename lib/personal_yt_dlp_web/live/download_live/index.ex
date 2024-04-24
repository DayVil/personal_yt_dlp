defmodule PersonalYtDlpWeb.DownloadLive.Index do
  alias PersonalYtDlp.Downloaders.DownloadServer
  use PersonalYtDlpWeb, :live_view
  alias PersonalYtDlpWeb.DownloadLive.FormComponent

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "DownloadAnything")
      |> assign(:form, to_form(%{"url" => ""}))

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"url" => link}, socket) do
    DownloadServer.add_yt_link(link)

    {:noreply, socket}
  end
end
