using Documenter
using CellLists

makedocs(
    sitename = "CellLists",
    format = Documenter.HTML(),
    modules = [CellLists]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
