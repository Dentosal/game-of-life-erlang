# [Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life), in [Erlang](https://erlang.org/)

Standard Game of Life rules, but on a fixed-size world. The edges of the world are marked as dead, not wrapping around.

The code is optimized for readibility instead of performance. It attempts to use Rust-type record-and-associated-methods -style, with C-style "methods". That doesn't seem to work with more Lisp-y style of Erlang well. It uses an [`array`](https://erlang.org/doc/man/array.html) of arrays to represent the grid.

It would be rather interesting to parallelize the code a bit, and do some performance measurements. The game of life is [embarrassingly parallel](https://en.wikipedia.org/wiki/Embarrassingly_parallel) as each row (and cell!) can be computed in parallel.

## Running

```bash
erlc game.erl && erl -pa game -eval 'game:main()'
```