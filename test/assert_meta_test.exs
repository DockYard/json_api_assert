defmodule AssertMetaTest do
  use ExUnit.Case
  import JsonApiAssert, only: [assert_meta: 2, assert_meta: 1]
  import JsonApiAssert.TestData, only: [data: 1]

  test "assert will return original payload" do
    result = Map.merge(data(:payload), data(:meta))
    expected = assert_meta(Map.merge(data(:payload), data(:meta)), data(:meta)["meta"])

    assert result == expected
  end

  test "assert will not raise when meta object is empty" do
    Map.merge(data(:payload), %{"meta" => %{}})
    |> assert_meta
  end

  test "assert will raise when meta is not found" do
    msg = "meta object not found"

    try do
      assert_meta(data(:payload))
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end

  test "assert will raise when meta object is not a map" do
    msg = "the value of each meta member MUST be an object"

    try do
      Map.merge(data(:payload), %{"meta" => []})
      |> assert_meta
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end

    try do
      Map.merge(data(:payload), %{"meta" => ""})
      |> assert_meta
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end

  test "assert will raise when matching meta object does not exist" do
    msg = "Assertion with == failed"

    try do
      Map.merge(data(:payload), data(:meta))
      |> assert_meta(Map.merge(%{"copywrite" => "2016"}, data(:meta)["meta"]))
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end
end
