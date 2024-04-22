defmodule PersonalYtDlp.DownloadersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PersonalYtDlp.Downloaders` context.
  """

  @doc """
  Generate a download.
  """
  def download_fixture(attrs \\ %{}) do
    {:ok, download} =
      attrs
      |> Enum.into(%{

      })
      |> PersonalYtDlp.Downloaders.create_download()

    download
  end
end
