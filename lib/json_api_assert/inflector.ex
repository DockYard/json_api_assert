defmodule JsonApiAssert.Inflector do
  @moduledoc """
  Inflection functions

  `use` this module in any module you wish to add inflection functions. It is
  necessary so the inflection rules are imported at compile-time to ensure fast lookup.

  To add a new rule add the following to your config:

      config :json_api_assert, :plural_rules,
        [{"dog", "dogs"},
         {"person", "people"}]

  Each member of the list *must* be a tuple with the first element being the singular form
  and the second element being the pluralized form.
  """

  defmacro __using__([]) do
    quote do
      @rules Application.get_env(:json_api_assert, :plural_rules)
             |> Enum.reduce(%{}, fn({singular, plural}, rules) ->
               rules
               |> Map.put(singular, plural)
               |> Map.put(plural, singular)
             end)

      @doc """
      Pluralize the given word

      Will try to use a pre-defined rule or default to appending "s" to the end of the word.
      """
      def pluralize(word) when is_binary(word) do
        @rules
        |> Map.get(word, "#{word}s")
      end
      @doc """
      Singuliarze the given word

      Will try to use a pre-defined rule or default to removing the "s" at the end of the word.
      """
      def singularize(word) when is_binary(word) do
        @rules
        |> Map.get(word, String.replace(word, ~r/s$/, ""))
      end
    end
  end
end
