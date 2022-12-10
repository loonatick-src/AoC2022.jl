function argmaxall(xs)
  first_argmax = argmax(xs)
  max_value = xs[first_argmax]
  findall(
    x -> x == max_value,
    xs[first_argmax:end]
  ) .+ (first_argmax - 1)
end

const VISIBLE = 0x00
const MAYBE_INVISIBLE = 0x01
const INVISIBLE = 0x02

export VISIBLE, INVISIBLE, MAYBE_INVISIBLE

function parse_tree_heights(input_lines)
  grid_sz = (length(input_lines), length(input_lines[1]))
  tree_heights = Matrix{UInt8}(undef, grid_sz...)
  parse_tree_heights!(tree_heights, input_lines)
  tree_heights
end

function parse_tree_heights!(tree_heights, input_lines)
  for (i,row) in enumerate(input_lines)
    for (j,col) in enumerate(row)
      tree_heights[i,j] = parse(UInt8, col)
    end
  end
end

function is_boundary(i::CartesianIndex, idxs::CartesianIndices)
  (r,c) = i.I
  lims = idxs.indices
  r == 1 || r == lims[1].stop || c == 1 || c == lims[2].stop
end

function visible_along_col(idx, tree_heights)
  h = tree_heights[idx]
  (r,c) = idx.I
  top_subcol = tree_heights[begin:r-1,c]
  if all(<(h), top_subcol)
    return true
  end
  bottom_subcol = tree_heights[r+1:end,c]
  all(<(h), bottom_subcol)
end

function visible_along_row(idx, tree_heights)
  h = tree_heights[idx]
  (r,c) = idx.I
  left_subrow = tree_heights[r, begin:c-1]
  if all(<(h), left_subrow)
    return true
  end
  right_subrow = tree_heights[r,c+1:end]
  all(<(h), right_subrow)
end


"""There has to be a more elegant solution to this"""
function solve8_1(s)
  input_lines = split_newline(s)
  (nrows,ncols) = grid_sz = (length(input_lines), length(input_lines[1]))
  tree_heights = parse_tree_heights(input_lines)
  
  visibility_map = fill!(similar(tree_heights, Bool),
                         true)
  idxs = CartesianIndices(tree_heights)
  for (i, h) in zip(collect(idxs), tree_heights)
    if is_boundary(i, idxs)
      continue
    end
    visibility_map[i] = visible_along_col(i, tree_heights) || visible_along_row(i, tree_heights)
  end
  count(==(true), visibility_map)
end

"""I really do not like this to be honest"""
function compute_score(i, tree_heights)
  h = tree_heights[i]
  (nrows, ncols) = size(tree_heights)
  (r,c) = i.I
  total_score = 1
  row = tree_heights[r,:]
  col = tree_heights[:,c]
  left_subrow = row[begin:c-1]
  first_taller = findfirst(>=(h), reverse(left_subrow))
  if first_taller === nothing
    first_taller = c-1
  end
  total_score *= first_taller

  right_subrow = row[c+1:end]
  first_taller = findfirst(>=(h), right_subrow)
  if first_taller === nothing
    first_taller = ncols - c
  end
  total_score *= first_taller

  top_subcol = col[begin:r-1]
  first_taller = findfirst(>=(h), reverse(top_subcol))
  if first_taller === nothing
    first_taller = r-1
  end
  total_score *= first_taller
  
  bottom_subcol = col[r+1:end]
  first_taller = findfirst(>=(h), bottom_subcol)
  if first_taller === nothing
    first_taller = nrows - r
  end
  total_score *= first_taller
  total_score
end

function solve8_2(s)
  input_lines = split_newline(s)
  (nrows,ncols) = grid_sz = (length(input_lines), length(input_lines[1]))
  tree_heights = parse_tree_heights(input_lines)
  score_map = similar(tree_heights, Int)

  idxs = CartesianIndices(score_map)
  for (i,h) in zip(collect(idxs), tree_heights)
    if is_boundary(i, idxs)
      score_map[i] = 0
    else
      score_map[i] = compute_score(i, tree_heights)
    end
  end
  maximum(score_map)
end
