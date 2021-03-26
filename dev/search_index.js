var documenterSearchIndex = {"docs":
[{"location":"#CellLists.jl","page":"CellLists.jl","title":"CellLists.jl","text":"","category":"section"},{"location":"","page":"CellLists.jl","title":"CellLists.jl","text":"(Image: )","category":"page"},{"location":"","page":"CellLists.jl","title":"CellLists.jl","text":"Documentation for CellLists.jl","category":"page"},{"location":"#Serial","page":"CellLists.jl","title":"Serial","text":"","category":"section"},{"location":"","page":"CellLists.jl","title":"CellLists.jl","text":"CellList\nCellList(::Array{T, 2}, ::T) where T <: AbstractFloat\nnear_neighbors(::CellList, ::Array{T, 2}, ::T) where T <: AbstractFloat","category":"page"},{"location":"#CellLists.CellList","page":"CellLists.jl","title":"CellLists.CellList","text":"CellList type. The indices dictionary maps the CartesianIndex of each cell to the indices of points in that cell.\n\n\n\n\n\n","category":"type"},{"location":"#CellLists.CellList-Union{Tuple{T}, Tuple{Array{T,2},T}} where T<:AbstractFloat","page":"CellLists.jl","title":"CellLists.CellList","text":"Construct CellList from points p and radius r>0.\n\nExamples\n\nn, d, r = 100, 2, 0.01\np = rand(n, d)\nc = CellLists(p, r)\n\n\n\n\n\n","category":"method"},{"location":"#CellLists.near_neighbors-Union{Tuple{T}, Tuple{CellList,Array{T,2},T}} where T<:AbstractFloat","page":"CellLists.jl","title":"CellLists.near_neighbors","text":"Return a vector of all pairs that are in neighboring cells in the cell list.\n\nExamples\n\njulia> near_neighbors(c, p, r)\n[(1, 4), (3, 11), ...]\n\n\n\n\n\n","category":"method"},{"location":"#Parallel","page":"CellLists.jl","title":"Parallel","text":"","category":"section"},{"location":"","page":"CellLists.jl","title":"CellLists.jl","text":"merge(::CellList{d}, ::CellList{d}) where d\nCellList(::Array{T, 2}, ::T, ::Val{:parallel}) where T <: AbstractFloat\np_near_neighbors(::CellList, ::Array{T, 2}, ::T) where T <: AbstractFloat","category":"page"},{"location":"#Base.merge-Union{Tuple{d}, Tuple{CellList{d},CellList{d}}} where d","page":"CellLists.jl","title":"Base.merge","text":"Merge two CellList{d}s with same dimension d.\n\nExamples\n\nn, d, r = 100, 2, 0.01\np = (rand(n, d), rand(n, d))\nmerge(CellList(p[1], r), CellList(p[2], r))\n\n\n\n\n\n","category":"method"},{"location":"#CellLists.CellList-Union{Tuple{T}, Tuple{Array{T,2},T,Val{:parallel}}} where T<:AbstractFloat","page":"CellLists.jl","title":"CellLists.CellList","text":"Multi-threaded constructor for CellList.\n\nExamples\n\nn, d, r = 100, 2, 0.01\np = rand(n, d)\nc = CellList(p, r, Val(:parallel))\n\n\n\n\n\n","category":"method"},{"location":"#CellLists.p_near_neighbors-Union{Tuple{T}, Tuple{CellList,Array{T,2},T}} where T<:AbstractFloat","page":"CellLists.jl","title":"CellLists.p_near_neighbors","text":"Parallel near neighbors\n\n\n\n\n\n","category":"method"}]
}
