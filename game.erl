-module(game).
-export([main/0]).

% TODO: move to own module?
-record(grid, {width, height, array}).

to_index(Grid, X, Y) -> X + Y * Grid#grid.width.
to_xy(Grid, I) -> {I rem Grid#grid.width, I div Grid#grid.width}.

grid_new(W, H) -> #grid{width=W, height=H, array=array:new(W * H)}.

grid_at(Grid, X, Y) -> if
    X < 0 -> undefined;
    Y < 0 -> undefined;
    X >= Grid#grid.width -> undefined;
    Y >= Grid#grid.height -> undefined;
    true -> grid_at(Grid, to_index(Grid, X, Y))
end.

grid_at(Grid, Index) -> if
    Index < 0 -> undefined;
    Index >= Grid#grid.width * Grid#grid.height -> undefined;
    true -> array:get(Index, Grid#grid.array)
end.

grid_set_at(Grid, X, Y, Value) -> grid_set_at(Grid, to_index(Grid, X, Y), Value).
grid_set_at(Grid, Index, Value) -> Grid#grid{array=array:set(Index, Value, Grid#grid.array)}.

grid_update(Grid, Array) -> Grid#grid{array=Array}.

unwrap_or(Value, Default) -> if
    Value == undefined -> Default;
    true -> Value
end.

% How many neightbors are alive?
sum_around(Grid, X, Y) -> lists:foldl(
    fun(Item, Acc) -> Acc + (case unwrap_or(Item, dead) of alive -> 1; dead -> 0 end) end,
    0,
    [
        grid_at(Grid, X - 1, Y - 1),
        grid_at(Grid, X - 1, Y),
        grid_at(Grid, X - 1, Y + 1),
        grid_at(Grid, X, Y - 1),
        grid_at(Grid, X, Y + 1),
        grid_at(Grid, X + 1, Y - 1),
        grid_at(Grid, X + 1, Y),
        grid_at(Grid, X + 1, Y + 1)
    ]
).

% A single step of simulation
step(Grid) -> grid_update(Grid, array:map(
    fun(I, _) ->
        {X, Y} = to_xy(Grid, I),
        C = grid_at(Grid, X, Y),
        S = sum_around(Grid, X, Y),
        if
            S < 2 -> dead;
            S > 3 -> dead;
            S == 3 -> alive;
            S == 2 -> C
        end
    end,
    Grid#grid.array
)).

% String representation of a cell
format_cell(Cell) -> case Cell of
    dead -> ".";
    alive -> "#"
end.

% String representation of the whole grid
% Built in reverse order, so the (0, 0) point is
% at bottom-right instead of the usual top-left.
format(Grid) -> array:foldl(
    fun(I, V, A) ->
        F = [format_cell(grid_at(Grid, I)) | " "],
        if
            (I rem Grid#grid.width) == 0 ->  [F | [ "\n" | A ] ];
            true -> [F | A]
        end
    end,
    "",
    Grid#grid.array
).

% World initialization
initialize() ->
    Grid = grid_new(30, 20),
    % glider
    SetAlive = [
        to_index(Grid, 1, 0),
        to_index(Grid, 2, 1),
        to_index(Grid, 2, 2),
        to_index(Grid, 1, 2),
        to_index(Grid, 0, 2)
    ],
    grid_update(Grid, array:map(
        fun(I, _) ->
            case lists:member(I, SetAlive) of
                true -> alive ;
                false -> dead
            end
        end,
        Grid#grid.array
    ))
.

% Main loop
loop(Grid) ->
    % Clear screen
    io:format("\ec"),
    % Print world
    io:fwrite("~s\n", [format(Grid)]),
    % Wait a bit
    timer:sleep(200),
    % Update world and repeat
    loop(step(Grid))
.

main() -> loop(initialize()).
