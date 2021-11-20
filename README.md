# etfx

An Elixir userspace implementation of [Erlang External Term Format](https://www.erlang.org/doc/apps/erts/erl_ext_dist.html).

I did this mainly as a teaching/learning device and a comparison with my previous [Rust implementation](https://github.com/ckampfe/etf).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `etfx` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:etfx, git: "https://github.com/ckampfe/etfx"}
  ]
end
```

## Benchmarks

### tl;dr

This implementation of ETF is about 3.5x slower than the built-in Erlang `binary_to_term` function, which is written in C, and about 2x faster than Elixir's current favorite JSON library, [Jason](https://hex.pm/packages/jason). I've only done minor optimization on this library after reading the Erlang guide on [optimizing binaries](https://www.erlang.org/doc/efficiency_guide/binaryhandling.html). To me this is a testament to just how highly optimized Erlang's binary pattern matching functionality is, showing that a hastily-written <200-line Elixir binary parser can be within a few multiples of the throughput of a highly optimized C library.

### `benchee` benchmarks

```
$ MIX_ENV=bench mix run bench.exs
Operating System: macOS
CPU Information: Apple M1 Max
Number of Available Cores: 10
Available memory: 64 GB
Elixir 1.13.0-rc.1
Erlang 24.1.5

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 1.05 min

Benchmarking big_list_bif...
Benchmarking big_list_elixir...
Benchmarking big_list_jason...
Benchmarking big_map_bif...
Benchmarking big_map_elixir...
Benchmarking big_map_jason...
Benchmarking small_map_bif...
Benchmarking small_map_elixir...
Benchmarking small_map_jason...

Name                       ips        average  deviation         median         99th %
small_map_bif        3565.94 K        0.28 μs  ±9209.29%           0 μs        0.99 μs
small_map_elixir     1061.66 K        0.94 μs  ±1405.14%        0.99 μs        0.99 μs
small_map_jason       518.26 K        1.93 μs   ±794.67%        1.99 μs        2.99 μs
big_map_bif            25.72 K       38.87 μs     ±7.87%       37.99 μs       45.99 μs
big_map_elixir         12.40 K       80.64 μs     ±8.86%       78.99 μs      107.99 μs
big_map_jason           6.52 K      153.42 μs     ±3.14%      152.99 μs      167.99 μs
big_list_bif            0.63 K     1586.60 μs    ±39.64%     1316.99 μs     2589.99 μs
big_list_elixir       0.0989 K    10112.76 μs     ±2.41%    10130.99 μs    10502.07 μs
big_list_jason        0.0233 K    42954.25 μs     ±1.74%    42596.99 μs    47047.55 μs

Comparison:
small_map_bif        3565.94 K
small_map_elixir     1061.66 K - 3.36x slower +0.66 μs
small_map_jason       518.26 K - 6.88x slower +1.65 μs
big_map_bif            25.72 K - 138.62x slower +38.59 μs
big_map_elixir         12.40 K - 287.54x slower +80.36 μs
big_map_jason           6.52 K - 547.08x slower +153.14 μs
big_list_bif            0.63 K - 5657.72x slower +1586.32 μs
big_list_elixir       0.0989 K - 36061.46x slower +10112.48 μs
big_list_jason        0.0233 K - 153172.17x slower +42953.97 μs
```
