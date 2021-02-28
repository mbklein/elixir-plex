defmodule Plex.SRT do
  defstruct index: nil, start: nil, end: nil, text: nil

  @entry_regex ~r/^(?<index>\d+)\r?\n(?<start>[0-9:,]+)\s*-->\s*(?<end>[0-9:,]+)\r?\n(?<text>[\S\s\r\n]+)$/

  def parse(srt) do
    srt
    |> Codepagex.to_string!("VENDORS/MICSFT/WINDOWS/CP1252")
    |> String.split(~r/(\r?\n){2}/)
    |> Enum.map(&parse_entry/1)
  end

  defp parse_entry(entry) do
    struct(
      __MODULE__,
      Regex.named_captures(@entry_regex, entry)
      |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
      |> Enum.map(fn
        {:index, value} -> {:index, String.to_integer(value)}
        {:text, value} -> {:text, String.replace(value, ~r/[\r\n]+/, " ")}
        {:start, value} -> {:start, Time.from_iso8601!(String.replace(value, ",", "."))}
        {:end, value} -> {:end, Time.from_iso8601!(String.replace(value, ",", "."))}
        other -> other
      end)
      |> Enum.into(%{})
    )
  end
end
