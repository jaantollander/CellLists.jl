module CellLists

include("sequential.jl")
include("parallel.jl")
export CellList, near_neighbors, brute_force!, distance_condition, merge

end # module
