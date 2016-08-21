defmodule JsonApiAssert do
  import ExUnit.Assertions, only: [assert: 1, assert: 2, refute: 2]

  @moduledoc """
  JsonApiAssert is a collection of composable test helpers to ease
  the pain of testing [JSON API](http://jsonapi.org) payloads.

  You can use the functions individually but they are optimally used in a composable
  fashion with the pipe operator:

  ## Examples

      payload
      |> assert_data(user1)
      |> assert_data(user2)
      |> refute_data(user3)
      |> assert_relationship(pet1, as: "pets", for: user1)
      |> assert_relationship(pet2, as: "pets", for: user2)
      |> assert_included(pet1)
      |> assert_included(pet2)

  If you've tested JSON API payloads before the benefits of this pattern should
  be obvious. Hundreds of lines of code can be reduced to just a handful. Brittle tests are
  now flexible and don't care about insertion / render order.
  """

  @doc """
  Asserts that the "jsonapi" object exists in the payload

  ## Examples

      payload
      |> assert_jsonapi(version: "1.0")

  The members argument should be a key/value pair of members you expect to be be in
  the "jsonapi" object of the payload.
  """
  @spec assert_jsonapi(map, list) :: map
  def assert_jsonapi(payload, members \\ [])

  def assert_jsonapi(%{"jsonapi" => jsonapi} = payload, members) do
    enforce_top_level_constraints(payload)

    Enum.reduce(members, [], fn({key, value}, unmatched) ->
      actual_value = jsonapi[Atom.to_string(key)]

      if actual_value != value do
        unmatched ++ ["Expected:\n  `#{key}` \"#{value}\"\nGot:\n  `#{key}` \"#{actual_value}\""]
      else
        unmatched
      end
    end)
    |> case do
      [] -> payload
      unmatched ->
        raise ExUnit.AssertionError, "jsonapi object mismatch\n#{Enum.join(unmatched, ", ")}"
    end
  end

  def assert_jsonapi(_payload, _members),
    do: raise ExUnit.AssertionError, "jsonapi object not found"

  @doc """
  Asserts that a valid "links" object and it's members, "link" objects, exist
  in the payload. The `path:` atom must be passed with a list containing the
  path to the "links" object, with the last item being the object you wish
  to assert.

  ## Examples

      @links = %{
        "related" => %{
          "href" => "http://example.com/articles/1/comments"
          "meta" => {
            "count": 10
          }
        }
      }

  To assert that the above "links" object is in the root of the payload:

      payload
      |> assert_links(path: [@links])

  To assert that the above "links" object is in the data->relationships->post
  record of the payload:

      payload
      |> assert_links(path: [:data, :relationships, :post, @links])

  The optional members argument should be a map of members you expect to be in
  the "links" object of the payload.
  """
  @spec assert_links(map, [path: list]) :: map
  def assert_links(payload, [path: [%{"links" => members}]]) do
    assert payload["links"] == members

    validate_links(members)
    payload
  end
  def assert_links(payload, [path: path]) do
    data = List.last(path)

    data_path =
      List.delete_at(path, -1)
      |> Enum.map(&to_string(&1))

    assert get_in(payload, data_path) == data

    validate_links(data["links"])
    payload
  end
  def assert_links(_payload, _opts),
    do: raise ExUnit.AssertionError, "you must pass `path:` to the links object"

  defp validate_links(members) do
    unless is_map(members),
      do: raise ExUnit.AssertionError, "the value of each links member MUST be an object"

    for {key, value} <- members do
      case validate_links_member(key, value) do
        {:ok} -> true
        {:error, msg} -> raise ExUnit.AssertionError, msg
      end
    end
  end

  defp validate_links_member(_key, member) when is_binary(member),
    do: {:ok}
  defp validate_links_member(_key, member) when is_map(member) do
    keys = Map.keys(member)
    valid_keys = ["href", "meta"]
    invalid_keys = Enum.join(keys -- valid_keys, ", ")

    if length(keys -- valid_keys) > 0 do
      msg = """
      A link MUST be represented as either a string or a map containing only `href` and `meta` objects

      Invalid keys: #{invalid_keys}
      """
      {:error, msg}
    else
      {:ok}
    end
  end
  defp validate_links_member(key, _member) do
    msg = """
    A link MUST be represented as either a string or a map containing only `href` and `meta` objects

    The value for key `#{key}` must be a string or map
    """

    {:error, msg}
  end

  @doc """
  Asserts that a given record is included in the `data` object of the payload.

  ## Examples

      payload
      |> assert_data(user1)

  Can also take a list of records. The list will be iterated over asserting each record individually.
  """
  @spec assert_data(map, map | struct | list) :: map
  def assert_data(payload, []), do: payload
  def assert_data(payload, [record | records]) do
    assert_data(payload, record)
    |> assert_data(records)
  end
  def assert_data(payload, record) do
    assert_record(payload["data"], record)

    payload
  end

  @doc """
  Refutes that a given record is included in the `data` object of the payload.

  ## Examples

      payload
      |> refute_data(user1)

  Can also take a list of records. The list will be iterated over refuting each record individually.
  """
  def refute_data(payload, []), do: payload
  def refute_data(payload, [record | records]) do
    refute_data(payload, record)
    |> refute_data(records)
  end
  @spec refute_data(map, map | struct | list) :: map
  def refute_data(payload, record) do
    refute_record(payload["data"], record)

    payload
  end

  @doc """
  Asserts that a given record is included in the `included` object of the payload.

  ## Examples

      payload
      |> assert_included(pet1)

  Can also take a list of records. The list will be iterated over asserting each record individually.
  """
  @spec assert_included(map, map | struct | list) :: map
  def assert_included(payload, []), do: payload
  def assert_included(payload, [record | records]) do
    assert_included(payload, record)
    |> assert_included(records)
  end
  def assert_included(payload, record) do
    assert_record(payload["included"], record)

    payload
  end


  @doc """
  Refutes that a given record is included in the `included` object of the payload.

  ## Examples

      payload
      |> refute_included(pet1)

  Can also take a list of records. The list will be iterated over refuting each record individually.
  """
  @spec refute_included(map, map | struct | list) :: map
  def refute_included(payload, []), do: payload
  def refute_included(payload, [record | records]) do
    refute_included(payload, record)
    |> refute_included(records)
  end
  def refute_included(payload, record) do
    refute_record(payload["included"], record)

    payload
  end

  @doc """
  Asserts that the proper relationship meta data exists between a parent and child record

  ## Examples

      payload
      |> assert_relationship(pet1, as: "pets", for: [:data, owner1])

  The `as:` atom must be passed the name of the relationship. It will not be derived from the child.

  An optional `included` boolean can be passed if you'd like to assert if the record is in the `included` section of
  the payload:

      payload
      |> assert_relationship(pet1, as: "pets", for: [:data, owner1], included: true)

  This is functionally equivalent to:

      payload
      |> assert_relationship(pet1, as: "pets", for: [:data, owner1])
      |> assert_included(pet1)

  If you pass `false` instead `refute_included/3` is used.

  This function can also take a list of child records. The list will be iterated over asserting each record individually.
  """
  @spec assert_relationship(map, map | list, [as: binary, for: list, included: boolean]) :: map
  def assert_relationship(payload, [], _opts), do: payload
  def assert_relationship(payload, [child_record | child_records], opts) do
    assert_relationship(payload, child_record, opts)
    |> assert_relationship(child_records, opts)
  end
  def assert_relationship(payload, child_record, [as: as, for: path]),
    do: assert_relationship(payload, child_record, as: as, for: path, included: nil)
  def assert_relationship(payload, child_record, [as: as, for: path, included: included?]) do
    parent_record = record_from_path(payload, path)

    relationships = parent_record["relationships"]

    if !relationships do
      raise ExUnit.AssertionError, "could not find any relationships for record matching `id` #{parent_record["id"]} and `type` \"#{parent_record["type"]}\""
    end

    relationship = relationships[as]

    if !relationship do
      raise ExUnit.AssertionError, "could not find the relationship `#{as}` for record matching `id` #{parent_record["id"]} and `type` \"#{parent_record["type"]}\""
    end

    relationship =
      get_in(parent_record, ["relationships", as, "data"])
      |> List.wrap()
      |> Enum.find(&(meta_data_compare(&1, child_record)))

    assert relationship, "could not find relationship `#{as}` with `id` #{child_record["id"]} and `type` \"#{child_record["type"]}\" for record matching `id` #{parent_record["id"]} and `type` \"#{parent_record["type"]}\""

    case included? do
      nil -> payload
      true -> assert_included(payload, child_record)
      false -> refute_included(payload, child_record)
    end
  end
  def assert_relationship(_, _, [for: _]),
    do: raise ExUnit.AssertionError, "you must pass `as:` with the name of the relationship"
  def assert_relationship(_, _, [as: _]),
    do: raise ExUnit.AssertionError, "you must pass `for:` with the parent record"

  @doc """
  Refutes a relationship between two records

  ## Examples

      payload
      |> refute_relationship(pet1, as: "pets", for: [:data, owner1])

  The `as:` atom must be passed the name of the relationship. It will not be derived from the child.

  This function can also take a list of child records. The list will be iterated over refuting each record individually.
  """
  @spec refute_relationship(map, map | list, [as: binary, for: list]) :: map
  def refute_relationship(payload, [], _opts), do: payload
  def refute_relationship(payload, [child_record | child_records], opts) do
    refute_relationship(payload, child_record, opts)
    |> refute_relationship(child_records, opts)
  end
  def refute_relationship(payload, child_record, [as: as, for: path]) do
    parent_record = record_from_path(payload, path)

    parent_record
    |> get_in(["relationships", as, "data"])
    |> List.wrap()
    |> Enum.find(&(meta_data_compare(&1, child_record)))
    |> refute("was not expecting to find the relationship `#{as}` with `id` #{child_record["id"]} and `type` \"#{child_record["type"]}\" for record matching `id` #{parent_record["id"]} and `type` \"#{parent_record["type"]}\"")

    payload
  end
  def refute_relationship(_, _, [for: _]),
    do: raise ExUnit.AssertionError, "you must pass `as:` with the name of the relationship"
  def refute_relationship(_, _, [as: _]),
    do: raise ExUnit.AssertionError, "you must pass `for:` with the parent record"

  defp assert_record(data, record) do
    find_record(data, record)
    |> case do
      nil ->
        assert nil, "could not find a record with matching `id` #{record["id"]} and `type` \"#{record["type"]}\""
      %{"attributes" => attributes} = found_record ->
        Enum.reduce(attributes, [], fn({key, value}, attrs) ->
          if value != record["attributes"][key] do
            attrs ++ [key]
          else
            attrs
          end
        end)
        |> case do
          [] -> found_record
          keys ->
            opts = [
            left: Enum.into(keys, %{}, fn(key) -> {key, attributes[key]} end),
              right: Enum.into(keys, %{}, fn(key) -> {key, record["attributes"][key]} end),
              message: "record with `id` #{record["id"]} and `type` \"#{record["type"]}\" was found but had mis-matching attributes"
            ]
            raise(ExUnit.AssertionError, opts)
        end
    end
  end

  defp refute_record(data, record) do
    find_record(data, record)
    |> case do
      %{"attributes" => attributes} ->
        matching =
          attributes
          |> Enum.reduce([], fn({key, value}, attrs) ->
            if value == record["attributes"][key] do
              attrs ++ [{key, value}]
            else
              attrs
            end
          end)

        refute Map.keys(attributes) |> length() == length(matching), "did not expect #{inspect Map.delete(record, "attributes")} to be found."

      nil -> nil
    end
  end

  defp find_record(data, record) when is_list(data) do
    Enum.find(data, &(meta_data_compare(&1, record)))
  end
  defp find_record(data, record),
    do: find_record([data], record)

  defp meta_data_compare(record_1, record_2) do
    record_1["id"] == record_2["id"] && record_1["type"] == record_2["type"]
  end

  defp enforce_top_level_constraints(payload) do
    if Map.has_key?(payload, "data") && Map.has_key?(payload, "errors"),
      do: raise ExUnit.AssertionError, "the members `data` and `errors` MUST NOT coexist in the same document"

    if !Map.has_key?(payload, "data") && Map.has_key?(payload, "included"),
      do: raise ExUnit.AssertionError, "If a document does not contain a top-level data key, the included member MUST NOT be present either."

    unless Map.has_key?(payload, "data") || Map.has_key?(payload, "errors") || Map.has_key?(payload, "meta"),
      do: raise ExUnit.AssertionError, "A document MUST contain at least one of the following top-level members: 'data', 'errors', 'meta'"
  end

  defp record_from_path(payload, path) do
    data_path =
      List.delete_at(path, -1)
      |> Enum.map(&(Atom.to_string(&1)))

    get_in(payload, data_path)
    |> assert_record(Enum.at(path, -1))
  end
end
