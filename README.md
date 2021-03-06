# etfx

[![Elixir CI](https://github.com/ckampfe/etfx/actions/workflows/elixir.yml/badge.svg)](https://github.com/ckampfe/etfx/actions/workflows/elixir.yml)

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
small_map_bif        3565.94 K        0.28 ??s  ??9209.29%           0 ??s        0.99 ??s
small_map_elixir     1061.66 K        0.94 ??s  ??1405.14%        0.99 ??s        0.99 ??s
small_map_jason       518.26 K        1.93 ??s   ??794.67%        1.99 ??s        2.99 ??s
big_map_bif            25.72 K       38.87 ??s     ??7.87%       37.99 ??s       45.99 ??s
big_map_elixir         12.40 K       80.64 ??s     ??8.86%       78.99 ??s      107.99 ??s
big_map_jason           6.52 K      153.42 ??s     ??3.14%      152.99 ??s      167.99 ??s
big_list_bif            0.63 K     1586.60 ??s    ??39.64%     1316.99 ??s     2589.99 ??s
big_list_elixir       0.0989 K    10112.76 ??s     ??2.41%    10130.99 ??s    10502.07 ??s
big_list_jason        0.0233 K    42954.25 ??s     ??1.74%    42596.99 ??s    47047.55 ??s

Comparison:
small_map_bif        3565.94 K
small_map_elixir     1061.66 K - 3.36x slower +0.66 ??s
small_map_jason       518.26 K - 6.88x slower +1.65 ??s
big_map_bif            25.72 K - 138.62x slower +38.59 ??s
big_map_elixir         12.40 K - 287.54x slower +80.36 ??s
big_map_jason           6.52 K - 547.08x slower +153.14 ??s
big_list_bif            0.63 K - 5657.72x slower +1586.32 ??s
big_list_elixir       0.0989 K - 36061.46x slower +10112.48 ??s
big_list_jason        0.0233 K - 153172.17x slower +42953.97 ??s
```
