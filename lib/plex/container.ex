defmodule Plex.Container do
  alias Plex.Client

  import SweetXml

  @int_pattern ~r/^\d+$/
  @float_pattern ~r/^\d+\.\d+$/
  @date_pattern ~r/^\d{4}-\d{2}-\d{2}$/
  @datetime_pattern ~r/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/

  def list(%{key: key}) when is_integer(key), do: list("/library/sections/#{key}/all")
  def list(%{key: key} = container), do: list(key) -- [container]

  def list(path) do
    Client.get(path)
    |> map(~x"/MediaContainer/*"l)
  end

  def map(xml, parent) do
    xml
    |> SweetXml.xpath(parent)
    |> transform()
  end

  defp transform([]), do: []

  defp transform([result | results]) do
    [transform(result) | transform(results)]
    |> Enum.reject(&is_nil/1)
  end

  defp transform(node) do
    node
    |> Tuple.to_list()
    |> transform_node()
  end

  defp transform_node([:xmlElement | [tag | rest]]) do
    with mod <- String.to_existing_atom("Elixir.Plex.Containers.#{tag}") do
      data =
        rest
        |> Enum.at(5)
        |> Enum.map(fn {:xmlAttribute, name, _, _, _, _, _, _, value, _} ->
          {
            name |> to_string() |> Inflex.underscore() |> String.to_atom(),
            value |> to_string() |> transform_value(name)
          }
        end)
        |> Enum.into(%{children: transform(Enum.at(rest, 6))})

      struct(mod, %{}) |> Map.merge(data)
    end
  rescue
    ArgumentError -> nil
  end

  defp transform_node(_), do: nil

  defp transform_value(value, name) do
    cond do
      name |> to_string() |> String.ends_with?("At") ->
        timestamp(value)

      value |> String.match?(@int_pattern) ->
        value |> String.to_integer()

      value |> String.match?(@float_pattern) ->
        value |> String.to_float()

      true ->
        value
    end
  end

  defp timestamp(value) do
    cond do
      value |> String.match?(@int_pattern) ->
        value |> String.to_integer() |> DateTime.from_unix!()

      value |> String.match?(@date_pattern) ->
        Date.from_iso8601!(value)

      value |> String.match?(@datetime_pattern) ->
        with {:ok, result, _} <- DateTime.from_iso8601(value) do
          result
        end

      true ->
        value
    end
  rescue
    ArgumentError -> value
  end
end
