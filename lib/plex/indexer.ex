defmodule Plex.Indexer do
  alias Plex.{Client, Container, SRT}

  def index({container_key, streams}), do: index(container_key, streams)

  def index(container_key, streams) do
    with [container] <- Container.list(container_key),
         metadata <- index_metadata(container) do
      streams
      |> Enum.map(&index_stream(&1, metadata))
      |> List.flatten()
    end
  end

  def index_metadata(%{type: "episode"} = metadata) do
    %{
      key: metadata.key,
      show: metadata.grandparent_title,
      season: metadata.parent_title,
      episode: metadata.index,
      title: metadata.title
    }
  end

  def index_metadata(%{type: "movie"} = metadata) do
    %{
      key: metadata.key,
      title: metadata.title
    }
  end

  def index_metadata(_), do: %{}

  def index_stream(%{key: key, language_code: language_code}, metadata) do
    Client.get(key)
    |> SRT.parse()
    |> Enum.with_index(1)
    |> Enum.map(fn {title, index} ->
      %{
        id: "#{key}:#{index}",
        lang: language_code,
        start: title.start,
        end: title.end,
        text: title.text
      }
      |> Map.merge(metadata)
    end)
  end

  def index_stream(_), do: []
end
