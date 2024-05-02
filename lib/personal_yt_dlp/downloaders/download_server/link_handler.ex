defmodule PersonalYtDlp.Downloaders.DownloadServer.LinkHandler do
  def is_valid_link?(link) do
    case extract_id(link) do
      nil -> false
      _ -> true
    end
  end

  def extract_id(link) do
    {rest, delim} = extract_by_pattern(link)

    if rest == nil do
      nil
    else
      String.split(rest, delim, parts: 2, trim: true) |> List.first()
    end
  end

  defp extract_by_pattern("https://" <> rest), do: extract_by_pattern(rest)
  defp extract_by_pattern("www." <> rest), do: extract_by_pattern(rest)

  defp extract_by_pattern("youtu.be/" <> rest) do
    {rest, "?"}
  end

  defp extract_by_pattern("youtube.com/watch?v=" <> rest) do
    {rest, "&"}
  end

  defp extract_by_pattern("youtube.com/shorts/" <> rest) do
    {rest, "?"}
  end

  defp extract_by_pattern(_), do: {nil, nil}
end
