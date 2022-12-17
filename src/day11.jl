using DataStructures: Queue, enqueue!, dequeue!

import Base.parse
import Base.split
import Base.rstrip
  
using Base: Fix1, Fix2

# partial application versions of some useful functions in `Base`
parse(T::Type) = Fix1(parse, T)

split(s) = Fix2(split, s)

rstrip(s::AbstractChar) = Fix1(rstrip, ==(s))

split_csv = split(r",\s*")
split_records = split(r"\n\n+")

# how do I make this type stable?
mutable struct Monkey
  # TODO: `id` might be redundant if array prepared properly
  id::Int
  items::Queue{Int}
  test::Int
  op::Expr
  partners::NTuple{2, Int}
end

function parse_last(xs, T::Type)
  xs |> split_whitespace |> last |> parse(T)
end

function parse(::Type{Monkey}, s)
  lines = split_newline(s)
  # laying pipe like an absolute chad
  id = lines[1]  |>  split_whitespace  |>  last  |>  rstrip(':')  |>  parse(Int)
  
  starting_items_strs = lines[2]  |>  split_csv
  first_item          = starting_items_strs  |>  first  |>  split_whitespace  |>  last  |>  parse(Int)
  remaining_items     = parse.(Int, starting_items_strs[2:end])
  items               = Queue{Int}()
  enqueue!(items, first_item)
  for item in remaining_items
    enqueue!(items, item)
  end

  test = parse_last(lines[4], Int)

  t_partner = parse_last(lines[5], Int)
  f_partner = parse_last(lines[6], Int)
  partners  = (t_partner, f_partner)

  op = lines[3] |> split(r":\s*") |> last |> Meta.parse

  Monkey(id, items, test, op, partners)
end

function solve11_1(s)
  monkeys = s |> split_records .|> parse(Monkey)
end
