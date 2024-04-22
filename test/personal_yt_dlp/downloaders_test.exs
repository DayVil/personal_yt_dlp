defmodule PersonalYtDlp.DownloadersTest do
  use PersonalYtDlp.DataCase

  alias PersonalYtDlp.Downloaders

  describe "downloads" do
    alias PersonalYtDlp.Downloaders.Download

    import PersonalYtDlp.DownloadersFixtures

    @invalid_attrs %{}

    test "list_downloads/0 returns all downloads" do
      download = download_fixture()
      assert Downloaders.list_downloads() == [download]
    end

    test "get_download!/1 returns the download with given id" do
      download = download_fixture()
      assert Downloaders.get_download!(download.id) == download
    end

    test "create_download/1 with valid data creates a download" do
      valid_attrs = %{}

      assert {:ok, %Download{} = download} = Downloaders.create_download(valid_attrs)
    end

    test "create_download/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Downloaders.create_download(@invalid_attrs)
    end

    test "update_download/2 with valid data updates the download" do
      download = download_fixture()
      update_attrs = %{}

      assert {:ok, %Download{} = download} = Downloaders.update_download(download, update_attrs)
    end

    test "update_download/2 with invalid data returns error changeset" do
      download = download_fixture()
      assert {:error, %Ecto.Changeset{}} = Downloaders.update_download(download, @invalid_attrs)
      assert download == Downloaders.get_download!(download.id)
    end

    test "delete_download/1 deletes the download" do
      download = download_fixture()
      assert {:ok, %Download{}} = Downloaders.delete_download(download)
      assert_raise Ecto.NoResultsError, fn -> Downloaders.get_download!(download.id) end
    end

    test "change_download/1 returns a download changeset" do
      download = download_fixture()
      assert %Ecto.Changeset{} = Downloaders.change_download(download)
    end
  end
end
