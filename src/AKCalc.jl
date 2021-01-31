module AKCalc

using Dates
using Tables
using SQLite
using DataFrames

# export Source, SourceFlags
# export ResourceType, Resource
# export FactoryRecipe, WorkshopRecipe

include("types.jl")
include("interfaces.jl")
# include("resources.jl")
# include("factory.jl")
# include("workshop.jl")
include("localdb.jl")
include("defaults.jl")
include("queries.jl")

end
