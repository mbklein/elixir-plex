defmodule Plex.SubtitleStreams do
  def stream(enum, codecs \\ :all) do
    Stream.resource(
      fn -> %{enum: enum, codecs: codecs} end,
      &next/1,
      &complete/1
    )
  end

  defp next(%{enum: []}), do: {:halt, %{enum: []}}

  defp next(%{enum: container, codecs: codecs}) when is_list(container) do
    container
    |> Enum.map(fn member ->
      next(%{enum: member, codecs: codecs})
    end)
    |> Enum.reduce({[], %{enum: [], codecs: codecs}}, &result_reducer/2)
  end

  defp next(%{enum: container, codecs: codecs}) do
    {find_nested(container, codecs), %{enum: Plex.Container.list(container), codecs: codecs}}
  end

  defp complete(container), do: container

  defp result_reducer({results, %{enum: fetched}}, {result_acc, fetched_acc}) do
    {
      result_acc ++ results,
      put_in(fetched_acc.enum, fetched_acc.enum ++ fetched)
    }
  end

  defp find_nested(container, codecs) do
    result =
      container
      |> Plex.deep_filter(fn item ->
        case codecs do
          :all -> is_struct(item) and Map.get(item, :stream_type) == 3
          val when is_binary(val) -> is_struct(item) and Map.get(item, :codec) == val
          val when is_list(val) -> is_struct(item) and Enum.member?(val, Map.get(item, :codec))
        end
      end)

    case result do
      [] -> []
      list -> [{container.key, list}]
    end
  end
end
