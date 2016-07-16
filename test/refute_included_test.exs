defmodule RefuteIncludedTest do
  use ExUnit.Case
  import JsonApiAssert, only: [refute_included: 2]
  import JsonApiAssert.TestData, only: [data: 1]

  test "will not raise when record is not found" do
    author =
      data(:author)
      |> put_in(["attributes", "first-name"], "Yosemite")
      |> put_in(["attributes", "last-name"], "Sam")

    refute_included(data(:payload), author)
  end

  test "will raise when record is found" do
    record = %{
      "id" => "1",
      "type" => "author"
    }

    msg = "did not expect #{inspect record} to be found."

    try do
      refute_included(data(:payload), data(:author))
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "will return the original payload" do
    author =
      data(:author)
      |> put_in(["attributes", "first-name"], "Yosemite")
      |> put_in(["attributes", "last-name"], "Sam")

    payload = refute_included(data(:payload), author)

    assert payload == data(:payload)
  end

  test "will not raise if we force an value mis-match and everything else matches" do
    author =
      data(:author)
      |> put_in(["id"], "2")

    refute_included(data(:payload), author)
  end
end
