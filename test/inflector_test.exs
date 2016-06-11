defmodule InflectorTest do
  use ExUnit.Case
  use JsonApiAssert.Inflector

  test "will pluralize words with no rules by adding `s` to the end" do
    assert pluralize("post") == "posts"
  end

  test "will pluralize words according to rule if it exists" do
    assert pluralize("person") == "people"
  end

  test "will singularize words with no rules by removing trailing `s` on the end" do
    assert singularize("posts") == "post"
  end

  test "will singularize words according to rule if it exists" do
    assert singularize("people") == "person"
  end
end
