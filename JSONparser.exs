# om dit bestand te kunnen runnen voer je het volgende commando uit:
# elixir JSONparser.exs

defmodule Jsonparser do
    def parse(json_string) do
        parse_value(json_string)
    end

    defp parse_value(value) do
        trimmed_value = String.trim(value)
        cond do
            String.starts_with?(trimmed_value, "{") and String.ends_with?(trimmed_value, "}") ->
                parse_object(trimmed_value)

            String.starts_with?(trimmed_value, "[") and String.ends_with?(trimmed_value, "]") ->
                parse_array(trimmed_value)

            String.starts_with?(trimmed_value, "\"") and String.ends_with?(trimmed_value, "\"") ->
                parse_string(trimmed_value)

            String.match?(trimmed_value, ~r/^\d+$/) ->
                parse_number(trimmed_value)

            true ->
                parse_boolean_or_null(trimmed_value)
        end
    end

    defp parse_object(object_string) do
        object_string
        |> String.trim()
        |> remove_outer_braces()
        |> split_pairs()
        |> Enum.map(&parse_pair/1)
        |> Map.new()
    end

    defp split_pairs(string) do
        split_pairs_recursive(string, [], "", 0)
    end

    defp split_pairs_recursive(input, keyValueList, currentString, depth) do
        cond do
            String.starts_with?(input, "{") ->
                split_pairs_recursive(String.slice(input, 1..-1//1), keyValueList, currentString <> "{", depth + 1)

            String.starts_with?(input, "[") ->
                split_pairs_recursive(String.slice(input, 1..-1//1), keyValueList, currentString <> "[", depth + 1)

            String.starts_with?(input, "}") ->
                split_pairs_recursive(String.slice(input, 1..-1//1), keyValueList, currentString <> "}", depth - 1)

            String.starts_with?(input, "]") ->
                split_pairs_recursive(String.slice(input, 1..-1//1), keyValueList, currentString <> "]", depth - 1)

            String.starts_with?(input, ",") and depth == 0 ->
                split_pairs_recursive(String.slice(input, 1..-1//1), keyValueList ++ [String.trim(currentString)], "", 0)

            input == "" ->
                keyValueList ++ [String.trim(currentString)]

            true ->
                <<char::utf8, rest::binary>> = input
                split_pairs_recursive(rest, keyValueList, currentString <> <<char::utf8>>, depth)
        end
    end

    defp parse_pair(pair_string) do
        [key, value] = String.split(pair_string, ":", parts: 2)
        {parse_string(String.trim(key)), parse_value(value)}
    end

    defp parse_array(array_string) do
        array_string
        |> remove_outer_brackets()
        |> split_pairs()
        |> Enum.map(&parse_value/1)
    end

    defp remove_outer_braces(string) do
        String.slice(string, 1..-2//1)
    end

    defp remove_outer_brackets(string) do
        String.slice(string, 1..-2//1)
    end

    defp parse_string(string) do
        string
        |> String.trim()
        |> String.slice(1..-2//1)
    end

    defp parse_number(string) do
        String.to_integer(string)
    end

    defp parse_boolean_or_null(string) do
        case string do
            "true" -> true
            "false" -> false
            "null" -> nil
        end
    end
end

json_string = ~s({
    "name": "John",
    "age": 30,
    "test": null,
    "city": "New York",
    "address": {
        "street": "123 Main St",
        "zipcode": {
            "primary": 12345,
            "hobbies":[
                "reading",
                "swimming"
            ]
        }
    }
})

parsed_json = Jsonparser.parse(json_string)
IO.inspect(parsed_json)
