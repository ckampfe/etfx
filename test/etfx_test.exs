defmodule EtfxTest do
  use ExUnit.Case
  doctest Etfx

  import Etfx

  test "atom" do
    string = <<131, 100, 0, 5, 104, 101, 108, 108, 111>>
    assert {:ok, :hello} == binary_to_term(string)
  end

  test "atom_utf8" do
    string = <<131, 118, 0, 5, 104, 101, 108, 108, 111>>
    assert {:ok, :hello} == binary_to_term(string)
  end

  test "small_atom" do
    string = <<131, 115, 5, 104, 101, 108, 108, 111>>
    assert {:ok, :hello} == binary_to_term(string)
  end

  test "small_atom_utf8" do
    string = <<131, 119, 5, 104, 101, 108, 108, 111>>
    assert {:ok, :hello} == binary_to_term(string)
  end

  test "string" do
    string = <<131, 109, 0, 0, 0, 5, 104, 101, 108, 108, 111>>
    assert {:ok, "hello"} == binary_to_term(string)

    string = <<131, 109, 0, 0, 0, 0>>
    assert {:ok, ""} == binary_to_term(string)
  end

  test "map" do
    empty_map = <<131, 116, 0, 0, 0, 0>>
    assert {:ok, %{}} == binary_to_term(empty_map)

    map = <<
      131,
      116,
      0,
      0,
      0,
      1,
      109,
      0,
      0,
      0,
      5,
      104,
      101,
      108,
      108,
      111,
      109,
      0,
      0,
      0,
      5,
      116,
      104,
      101,
      114,
      101
    >>

    assert {:ok, %{"hello" => "there"}} == binary_to_term(map)

    no_key = <<131, 116, 0, 0, 0, 1>>
    assert {:error, {:expected_input, 1}} == binary_to_term(no_key)

    no_value = <<131, 116, 0, 0, 0, 1, 100, 0, 0>>
    assert {:error, {:expected_input, 1}} == binary_to_term(no_value)
  end

  test "empty_list" do
    string = <<131, 106>>
    assert {:ok, []} == binary_to_term(string)
  end

  test "list" do
    string = <<131, 108, 0, 0, 0, 1>>
    assert {:error, {:expected_input, 1}} == binary_to_term(string)

    string = <<131, 108, 0, 0, 0, 1, 109, 0, 0, 0, 5, 104, 101, 108, 108, 111, 106>>
    assert {:ok, ["hello"]} == binary_to_term(string)
  end

  test "improper_list" do
    improper_list = :erlang.term_to_binary([1 | 2])
    assert {:ok, [1, 2]} == binary_to_term(improper_list)
  end

  test "small_integer" do
    string = <<131, 97, 12>>
    assert {:ok, 12} == binary_to_term(string)
  end

  test "integer" do
    string = <<131, 98, 255, 255, 255, 244>>
    assert {:ok, -12} == binary_to_term(string)
  end

  test "new_float" do
    string = <<131, 70, 64, 64, 12, 204, 204, 204, 204, 205>>
    assert {:ok, 32.1} == binary_to_term(string)
  end

  test "small_tuple" do
    small_tuple =
      <<131, 104, 5, 100, 0, 1, 49, 100, 0, 1, 50, 100, 0, 1, 51, 100, 0, 1, 52, 100, 0, 1, 53>>

    assert {:ok, {:"1", :"2", :"3", :"4", :"5"}} == binary_to_term(small_tuple)
  end

  test "large_tuple" do
    large_tuple = File.read!("fixtures/large_tuple.etf")
    parsed = binary_to_term(large_tuple)

    atoms =
      1..256
      |> Enum.map(fn n -> String.to_atom("#{n}") end)
      |> List.to_tuple()

    assert {:ok, atoms} == parsed
  end

  test "small_big" do
    small_big = File.read!("fixtures/small_big.etf")
    assert {:ok, 111_111_111_111_111_111_111_111_111_111_111} == binary_to_term(small_big)
  end

  test "large_big" do
    large_big = File.read!("fixtures/large_big.etf")
    expected = :erlang.binary_to_term(large_big)
    assert {:ok, expected} == binary_to_term(large_big)
  end
end
