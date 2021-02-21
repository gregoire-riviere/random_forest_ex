#code from https://github.com/seantanly/elixir-combination/blob/master/lib/combination.ex

defmodule Combination do
  @moduledoc """
  Provide a set of algorithms to generate combinations and permutations.
  For source collection containing non-distinct elements, pipe the resultant list through `Enum.uniq/1`
  to remove duplicate elements.
  """

  @doc """
  Generate combinations based on given collection.
  ## Examples
      iex> 1..3 |> Combination.combine(2)
      [[3, 2], [3, 1], [2, 1]]
  """
  @spec combine(Enum.t(), non_neg_integer) :: [list]
  def combine(collection, k) when is_integer(k) and k >= 0 do
    list = Enum.to_list(collection)
    list_length = Enum.count(list)

    if k > list_length do
      raise Enum.OutOfBoundsError
    else
      do_combine(list, list_length, k, [], [])
    end
  end

  defp do_combine(_list, _list_length, 0, _pick_acc, _acc), do: [[]]
  # optimization
  defp do_combine(list, _list_length, 1, _pick_acc, _acc), do: list |> Enum.map(&[&1])

  defp do_combine(list, list_length, k, pick_acc, acc) do
    list
    |> Stream.unfold(fn [h | t] -> {{h, t}, t} end)
    |> Enum.take(list_length)
    |> Enum.reduce(acc, fn {x, sublist}, acc ->
      sublist_length = Enum.count(sublist)
      pick_acc_length = Enum.count(pick_acc)

      if k > pick_acc_length + 1 + sublist_length do
        # insufficient elements in sublist to generate new valid combinations
        acc
      else
        new_pick_acc = [x | pick_acc]
        new_pick_acc_length = pick_acc_length + 1

        case new_pick_acc_length do
          ^k -> [new_pick_acc | acc]
          _ -> do_combine(sublist, sublist_length, k, new_pick_acc, acc)
        end
      end
    end)
  end
end
