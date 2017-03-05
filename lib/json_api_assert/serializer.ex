defmodule JsonApiAssert.Serializer do
  @moduledoc """
  Basic record serializer for use with JsonApiAssert
  """

  @doc """
  Will serialize a record into the JSON API format.

      %User{first_name: "Brian", last_name: "Cardarella", id: 1}
      |> serialize()

      # Result:

      %{
        "id" => "1",
        "type" => "users",
        "attributes" => %{
          "first-name" => "Brian",
          "last-name" => "Cardarella"
        }
      }

  Options:

  * `type` - override the type being derived from the record. Or provide one if a type cannot be derived
  * `primary_key` - override the key from which the primary_key value will be obtained
  * `only` - a list of attributes to limit serialization to
  * `except` - a list of attributes to exclude in serialization
  """
  @spec serialize(struct, type: binary, primary_key: atom) :: map
  def serialize(record, opts \\ []) do
    %{}
    |> put_id(record, opts[:primary_key])
    |> put_type(record, opts[:type])
    |> put_attributes(record, opts)
  end

  @doc """
  Shortened alias of `serialize`
  """
  def s(record, opts \\ []),
    do: serialize(record, opts)

  defp put_id(serialized_record, record, primary_key) do
    id = Map.get(record, get_primary_key(record, primary_key))
         |> to_string

    Map.put(serialized_record, "id", id)
  end

  defp get_primary_key(record, primary_key) when is_binary(primary_key),
    do: get_primary_key(record, String.to_atom(primary_key))
  defp get_primary_key(_record, primary_key),
    do:  primary_key || :id

  defp put_type(map, %{__struct__: struct}, nil) do
    type =
      struct
      |> Module.split()
      |> List.last()
      |> Mix.Utils.underscore()

    Map.put(map, "type", type)
  end
  defp put_type(_map, _record, nil),
    do: raise ArgumentError, "No type can be derived from record. Please pass a type to `serialize`."
  defp put_type(map, _record, type),
    do: Map.put(map, "type", type)

  defp put_attributes(map, %{__struct__: _struct} = record, opts),
    do: put_attributes(map, Map.from_struct(record), opts)
  defp put_attributes(map, record, opts) do
    primary_key = get_primary_key(record, opts[:primary_key])

    except =
      (opts[:except] || [])
      |> Enum.into(%{}, fn(key) -> {key, true} end)
      |> Map.put(primary_key, true)

    only =
      ((opts[:only] || []) -- Map.keys(except))
      |> Enum.into(%{}, fn(key) -> {key, true} end)

    attributes =
      Enum.reduce(record, %{}, fn({key, value}, attributes) ->
        cond do
          Map.has_key?(except, key) and Map.has_key?(only, key) ->
            attributes
          Map.has_key?(except, key) ->
            attributes
          only == %{} ->
            put_serialized_kv(attributes, key, value)
          !Map.has_key?(only, key) ->
            attributes
          true ->
            put_serialized_kv(attributes, key, value)
        end
      end)

    Map.put(map, "attributes", attributes)
  end

  defp put_serialized_kv(attributes, key, value) do
    Map.put(attributes, serialize_key(key), serialize_value(value))
  end

  defp serialize_key(key) when is_atom(key),
    do: key
        |> Atom.to_string()
        |> serialize_key()
  defp serialize_key(key) when is_binary(key),
    do: key
        |> String.downcase()
        |> String.replace("_", "-")

  defp serialize_value(%{__struct__: Ecto.DateTime} = value),
    do: apply(Ecto.DateTime, :to_iso8601, [value])
  defp serialize_value(%{__struct__: Ecto.Time} = value),
    do: apply(Ecto.Time, :to_iso8601, [value])
  defp serialize_value(%{__struct__: Ecto.Date} = value),
    do: apply(Ecto.Date, :to_iso8601, [value])
  defp serialize_value(%{__struct__: NaiveDateTime} = value),
    do: apply(NaiveDateTime, :to_iso8601, [value])
  defp serialize_value(value), do: value
end
