defmodule PersonalYtDlpWeb.DownloadLiveTest do
  use PersonalYtDlpWeb.ConnCase

  import Phoenix.LiveViewTest
  import PersonalYtDlp.DownloadersFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_download(_) do
    download = download_fixture()
    %{download: download}
  end

  describe "Index" do
    setup [:create_download]

    test "lists all downloads", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/downloads")

      assert html =~ "Listing Downloads"
    end

    test "saves new download", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/downloads")

      assert index_live |> element("a", "New Download") |> render_click() =~
               "New Download"

      assert_patch(index_live, ~p"/downloads/new")

      assert index_live
             |> form("#download-form", download: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#download-form", download: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/downloads")

      html = render(index_live)
      assert html =~ "Download created successfully"
    end

    test "updates download in listing", %{conn: conn, download: download} do
      {:ok, index_live, _html} = live(conn, ~p"/downloads")

      assert index_live |> element("#downloads-#{download.id} a", "Edit") |> render_click() =~
               "Edit Download"

      assert_patch(index_live, ~p"/downloads/#{download}/edit")

      assert index_live
             |> form("#download-form", download: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#download-form", download: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/downloads")

      html = render(index_live)
      assert html =~ "Download updated successfully"
    end

    test "deletes download in listing", %{conn: conn, download: download} do
      {:ok, index_live, _html} = live(conn, ~p"/downloads")

      assert index_live |> element("#downloads-#{download.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#downloads-#{download.id}")
    end
  end

  describe "Show" do
    setup [:create_download]

    test "displays download", %{conn: conn, download: download} do
      {:ok, _show_live, html} = live(conn, ~p"/downloads/#{download}")

      assert html =~ "Show Download"
    end

    test "updates download within modal", %{conn: conn, download: download} do
      {:ok, show_live, _html} = live(conn, ~p"/downloads/#{download}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Download"

      assert_patch(show_live, ~p"/downloads/#{download}/show/edit")

      assert show_live
             |> form("#download-form", download: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#download-form", download: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/downloads/#{download}")

      html = render(show_live)
      assert html =~ "Download updated successfully"
    end
  end
end
