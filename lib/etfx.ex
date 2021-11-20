defmodule Etfx do
  @moduledoc """
  Documentation for `Etfx`.
  """

  @atom_tag 100
  @atom_utf8_tag 118
  @binary_tag 109
  @integer_tag 98
  @large_big_tag 111
  @large_tuple_tag 105
  @list_tag 108
  @map_tag 116
  @new_float_tag 70
  @nil_tag 106
  @small_atom_tag 115
  @small_atom_utf8_tag 119
  @small_big_tag 110
  @small_integer_tag 97
  @small_tuple_tag 104
  @version_number_tag 131

  @spec binary_to_term(binary()) :: term()
  def binary_to_term(binary) when is_binary(binary) do
    case binary do
      <<@version_number_tag, rest::binary()>> ->
        case parse_term(rest) do
          {:ok, {"", term}} -> {:ok, term}
          {:error, _} = e -> e
        end

      <<_other_start_byte, _rest::binary()>> ->
        {:error, :invalid_version_byte}

      <<>> ->
        {:error, {:expected_input, 1}}
    end
  end

  defp parse_term(<<binary::binary()>>) do
    case binary do
      <<@atom_tag, len::16-big-unsigned-integer, contents::binary-size(len), rest::binary()>> ->
        {:ok, {rest, String.to_atom(contents)}}

      <<@binary_tag, len::32-big-unsigned-integer, contents::binary-size(len), rest::binary()>> ->
        {:ok, {rest, contents}}

      <<@small_integer_tag, i::8-big-unsigned-integer, rest::binary()>> ->
        {:ok, {rest, i}}

      <<@integer_tag, i::32-big-signed-integer, rest::binary()>> ->
        {:ok, {rest, i}}

      <<@new_float_tag, f::64-big-float, rest::binary()>> ->
        {:ok, {rest, f}}

      <<@map_tag, len::32-big-unsigned-integer, rest::binary>> ->
        case parse_map_elements(rest, [], len) do
          {:ok, {<<_rest::binary()>>, _term}} = ok -> ok
          {:error, _} = e -> e
        end

      <<@list_tag, len::32-big-unsigned-integer, rest::binary()>> ->
        case parse_list_elements(rest, [], len) do
          {:ok, {<<rest::binary()>>, list}} ->
            case parse_term(rest) do
              {:ok, {rest, []}} ->
                {:ok, {rest, :lists.reverse(list)}}

              {:ok, {rest, tail}} ->
                {:ok, {rest, :lists.reverse([tail | list])}}
            end

          {:error, _} = e ->
            e
        end

      <<@nil_tag, rest::binary()>> ->
        {:ok, {rest, []}}

      <<@small_tuple_tag, len::8-big-unsigned-integer, rest::binary()>> ->
        res = parse_list_elements(rest, [], len)

        case res do
          {:ok, {<<rest::binary()>>, list}} ->
            tuple = list |> :lists.reverse() |> :erlang.list_to_tuple()
            {:ok, {rest, tuple}}

          {:error, _} = e ->
            e
        end

      <<@large_tuple_tag, len::32-big-unsigned-integer, rest::binary()>> ->
        res = parse_list_elements(rest, [], len)

        case res do
          {:ok, {<<rest::binary()>>, list}} ->
            tuple = list |> :lists.reverse() |> :erlang.list_to_tuple()
            {:ok, {rest, tuple}}

          {:error, _} = e ->
            e
        end

      <<@atom_utf8_tag, len::16-big-unsigned-integer, contents::binary-size(len), rest::binary()>> ->
        {:ok, {rest, String.to_atom(contents)}}

      <<@small_atom_utf8_tag, len::8-big-unsigned-integer, contents::binary-size(len),
        rest::binary()>> ->
        {:ok, {rest, String.to_atom(contents)}}

      <<@small_atom_tag, len::8-big-unsigned-integer, contents::binary-size(len), rest::binary()>> ->
        {:ok, {rest, String.to_atom(contents)}}

      <<@small_big_tag, n::8, sign::8, digits::binary-size(n), rest::binary()>> ->
        bignum = decode_bignum(digits, sign)
        {:ok, {rest, bignum}}

      <<@large_big_tag, n::32, sign::8, digits::binary-size(n), rest::binary()>> ->
        bignum = decode_bignum(digits, sign)
        {:ok, {rest, bignum}}

      <<>> ->
        {:error, {:expected_input, 1}}
    end
  end

  defp parse_list_elements(<<rest::binary()>>, list, 0) do
    {:ok, {rest, list}}
  end

  defp parse_list_elements(<<rest::binary()>>, list, elements_remaining) do
    case parse_term(rest) do
      {:ok, {<<rest::binary()>>, term}} ->
        parse_list_elements(
          rest,
          [term | list],
          elements_remaining - 1
        )

      {:error, _} = e ->
        e
    end
  end

  defp parse_map_elements(<<rest::binary()>>, kv_list, 0) do
    {:ok, {rest, Map.new(kv_list)}}
  end

  defp parse_map_elements(<<rest::binary()>>, kv_list, pairs_remaining) do
    with {:ok, {<<rest::binary()>>, key_term}} <- parse_term(rest),
         {:ok, {<<rest::binary()>>, value_term}} <- parse_term(rest) do
      parse_map_elements(
        rest,
        [{key_term, value_term} | kv_list],
        pairs_remaining - 1
      )
    else
      {:error, _} = e -> e
    end
  end

  defp decode_bignum(<<digits::binary()>>, sign) do
    decode_bignum(digits, 0, sign, 0)
  end

  defp decode_bignum(<<>>, bignum, _sign, _exponent), do: bignum

  defp decode_bignum(<<digit::8-integer, digits::binary()>>, n, sign, exponent) do
    decode_bignum(digits, digit * 256 ** exponent + n, sign, exponent + 1)
  end

  # @spec term_to_binary(any) :: binary()
  # def term_to_binary(term) do
  # end
end
