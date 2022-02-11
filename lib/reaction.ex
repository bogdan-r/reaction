defmodule Reaction do

  @spec run(binary(), map(), non_neg_integer()) :: non_neg_integer()
  def run(formula, rules, n) do
    initial_element_pairs = split_formula_by_pairs(formula)
    initial_element_numbers = initialize_element_numbers(formula)
    initial_acc = {initial_element_pairs, initial_element_numbers}

    {_, element_numbers} = Enum.reduce(1..n, initial_acc, &(caclulate_reaction_power(&1, &2, rules)))
    {min, max} = get_min_max(element_numbers)

    max - min
  end

  defp caclulate_reaction_power(_, {element_pairs, element_numbers}, rules) do
    reversed_pairs = Enum.reverse(element_pairs)
    {generated_pairs, updates_element_numbers} =
      Enum.reduce(reversed_pairs, {[], element_numbers}, &(generate_new_chain(&1, &2, rules)))

    {Enum.reverse(generated_pairs), updates_element_numbers}
  end

  defp generate_new_chain(pair, {pairs, element_numbers}, rules) do
    {new_element, new_chain} = make_reaction(pair, rules)

    new_pairs = split_formula_by_pairs(new_chain)
    updated_element_numbers = update_element_numbers(element_numbers, new_element)

    {add_to_pairs(pairs, new_pairs), updated_element_numbers}
  end

  defp add_to_pairs(pairs, []) do
    pairs
  end

  defp add_to_pairs(pairs, new_pairs) do
    [pair | rest] = new_pairs
    add_to_pairs([pair | pairs], rest)
  end

  defp update_element_numbers(element_numbers, element) do
    {_, updated_numbers} = Map.get_and_update(element_numbers, element, fn current_value ->
      if is_number(current_value) do
        {current_value, current_value + 1}
      else
        {current_value, 1}
      end
    end)

    updated_numbers
  end

  defp split_formula_by_pairs(formula) when is_binary(formula) do
    formula
      |> String.graphemes()
      |> generate_formula_pairs([])
  end


  defp generate_formula_pairs(elements, pairs) do
    if length(elements) <= 1 do
      Enum.reverse(pairs)
    else
      [first_element, second_element | _] = elements
      [_ | rest_elements] = elements
      pairs = ["#{first_element}#{second_element}" | pairs]

      generate_formula_pairs(rest_elements, pairs)
    end
  end

  defp make_reaction(element_pair, rules) do
    new_element = Map.get(rules, element_pair, "")
    [first_element, second_element] = String.graphemes(element_pair)
    new_element_chain = first_element <> new_element <> second_element

    {new_element, new_element_chain}
  end

  defp get_min_max(element_numbers) do
    element_numbers
      |> Map.values()
      |> Enum.min_max()
  end

  defp initialize_element_numbers(formula) do
    formula
      |> String.graphemes()
      |> Enum.frequencies()
  end
end
