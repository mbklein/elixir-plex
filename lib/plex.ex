defmodule Plex do
  defmodule Config do
    defstruct url: nil, token: nil

    def config do
      %__MODULE__{
        url: Application.get_env(:plex, :plex_host),
        token: Application.get_env(:plex, :api_token)
      }
    end
  end

  def deep_filter(enum, fun) when is_struct(enum) do
    enum
    |> Map.from_struct()
    |> Enum.reduce([], fn {_, member}, acc ->
      result = if filter_match?(member, fun), do: [member | acc], else: acc

      case Enumerable.impl_for(member) do
        nil -> result
        _ -> result ++ deep_filter(member, fun)
      end
    end)
  end

  def deep_filter(enum, fun) when is_list(enum) do
    Enum.filter(enum, fn member -> filter_match?(member, fun) end) ++
      Enum.reduce(enum, [], fn member, acc -> acc ++ deep_filter(member, fun) end)
  end

  def deep_filter(enum, fun) when is_map(enum) do
    Enum.filter(enum, fn {_, member} -> filter_match?(member, fun) end) ++
      Enum.reduce(enum, [], fn {_, member}, acc -> acc ++ deep_filter(member, fun) end)
  end

  def deep_filter(_, _), do: []

  def filter_match?(item, fun) do
    case fun.(item) do
      nil -> false
      false -> false
      _ -> true
    end
  end
end
