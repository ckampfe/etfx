small_map = <<
  131,
  116,
  0,
  0,
  0,
  6,
  100,
  0,
  1,
  97,
  97,
  73,
  100,
  0,
  1,
  98,
  98,
  0,
  0,
  32,
  56,
  100,
  0,
  1,
  99,
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
  100,
  0,
  1,
  100,
  100,
  0,
  2,
  111,
  107,
  100,
  0,
  1,
  101,
  97,
  99,
  100,
  0,
  1,
  102,
  70,
  64,
  215,
  172,
  135,
  231,
  108,
  31,
  228
>>

small_map_term = :erlang.binary_to_term(small_map)
small_map_json = Jason.encode!(small_map_term)

big_list = File.read!("fixtures/big_list.etf")
big_list_term = :erlang.binary_to_term(big_list)
big_list_json = Jason.encode!(big_list_term)

big_map = File.read!("fixtures/big_map.etf")
big_map_term = :erlang.binary_to_term(big_map)
big_map_json = Jason.encode!(big_map_term)

Benchee.run(%{
  "small_map_elixir" => fn -> Etfx.binary_to_term(small_map) end,
  "small_map_bif" => fn -> :erlang.binary_to_term(small_map) end,
  "big_list_elixir" => fn -> Etfx.binary_to_term(big_list) end,
  "big_list_bif" => fn -> :erlang.binary_to_term(big_list) end,
  "big_map_elixir" => fn -> Etfx.binary_to_term(big_map) end,
  "big_map_bif" => fn -> :erlang.binary_to_term(big_map) end,
  "small_map_jason" => fn -> Jason.decode!(small_map_json) end,
  "big_map_jason" => fn -> Jason.decode!(big_map_json) end,
  "big_list_jason" => fn -> Jason.decode!(big_list_json) end
})
