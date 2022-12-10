"""Radical"""
parse_int(s) = parse(Int, s)

@enum CMD begin
  ls
  cd
end

mutable struct DirNode
  children::Vector{Union{Int, DirNode}}
  parent::Union{DirNode, Nothing}
  name::String
  size::Int

  DirNode(name) = new(Union{Int, DirNode}[], nothing, name, 0)
  DirNode(parent, name) = new(Union{Int, DirNode}[], parent, name, 0)
end

FileOrDir = Union{Int, DirNode}

parse_filesize(s) = s |> split_whitespace |> first |> parse_int

function parse_cmd(s)
  tokens = split_whitespace(s)
  cmd_name = tokens[2]
  @match cmd_name begin
    "ls" => ls
    "cd" => cd
    _ => ls   # unreachable for nice input and good logic
  end
end

function process_ls!(ds::DirNode, curr_dir::DirNode, input_lines::Vector{SubString{String}}, line_number::Integer)
  line_number += 1
  while line_number <= length(input_lines)
    line = input_lines[line_number]
    split_line = split_whitespace(line)
    if (split_line[1]) == "dir"
      push!(curr_dir.children, DirNode(curr_dir, split_line[2]))
    elseif split_line[1] != raw"$"
      push!(curr_dir.children, parse_filesize(line))
    else
      return line_number
    end
    line_number += 1
  end
  line_number
end

function process_cd!(ds, curr_dir, line)
  dir_name = split_whitespace(line)[3]
  if dir_name == ".."
    return curr_dir.parent
  else
    for item in curr_dir.children
      if item isa DirNode && item.name == dir_name && return item
      end
    end
  end
end

function construct_dirtree(s)
  ds = DirNode("/")
  input_lines = split(s, '\n')
  curr_dir = ds
  line_number = 2
  while line_number < length(input_lines)
    l = input_lines[line_number]
    cmd = parse_cmd(l)
    if cmd == ls
      line_number = process_ls!(ds, curr_dir, input_lines, line_number)
    else
      curr_dir = process_cd!(ds, curr_dir, l)
      line_number += 1
    end
  end
  ds
end

function calculate_dir_size(dir::DirNode, sub_size)
  total_size = 0
  for item in dir.children
    if item isa Integer
      total_size += item
    else
      # this can be made tail-recursive
      (item.size, sub_size) = calculate_dir_size(item, sub_size)
      if item.size <= 100_000
        sub_size += item.size
      end
      total_size += item.size
    end
  end
  (total_size, sub_size)
end

function solve7_1(s)
  dir_tree = construct_dirtree(s)
  (dir_tree.size, sub_size) = calculate_dir_size(dir_tree, 0)
  sub_size
end

function find_dir_to_delete(ds, to_free)
  curr_size = typemax(Int)
  delete_internal(ds, to_free, curr_size)
end

function delete_internal(ds, to_free, curr_size)
  for item in ds.children
    if item isa Int
      continue
    elseif item.size < to_free
      continue
    elseif item.size < curr_size
      curr_size = item.size
      curr_size = delete_internal(item, to_free, curr_size)
    end
  end
  curr_size
end

function solve7_2(s)
  total_space = 70_000_000
  required_space = 30_000_000
  dir_tree = construct_dirtree(s)
  (dir_tree.size, _) = calculate_dir_size(dir_tree, 0)
  free_space = total_space - dir_tree.size
  to_free = required_space - free_space
  delete_size = find_dir_to_delete(dir_tree, to_free)
  final_free_space = dir_tree.size - delete_size
  delete_size
end
