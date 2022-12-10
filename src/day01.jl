function solve1_2(input_str::S) where {S <: AbstractString}
  split_input = split(input_str, '\n')
  elf = 1
  elf_capacities = Vector{Int}()
  record_breaks = findall(s->s=="", split_input)
  nelves = length(record_breaks)-1  # ignoring the last newline
  rb_prev = 1
  for rb in record_breaks
    push!(elf_capacities,
          sum(parse.(Int,
                     split_input[rb_prev:rb-1])))

    rb_prev = rb + 1
  end
  sum(elf_capacities[end-1:end])
end
