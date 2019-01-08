defmodule Odyssey.Utils do
  def strong_params(params, allowed_fields) when is_map(params) do
    allowed_strings = Enum.map(allowed_fields, &Atom.to_string(&1))

    Enum.reduce(params, [], fn {k, v}, acc ->
      key = check_key(k, allowed_strings)
      acc ++ [{key, v}]
    end)
    |> Enum.reject(fn {k, _v} -> k == nil end)
    |> Map.new()
  end

  defp check_key(k, allowed_strings) when is_atom(k) do
    str_key = Atom.to_string(k)

    if str_key in allowed_strings do
      k
    end
  end

  defp check_key(k, allowed_strings) when is_binary(k) do
    if k in allowed_strings do
      String.to_existing_atom(k)
    end
  end

  defp check_key(_, _), do: nil
end
