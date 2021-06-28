module PlayerData

using JSON
using HTTP
using DataFrames

using AKCalc
using AKCalc: GameData

export operators, resources
export PDSQLite

include("playerdata_types.jl")

abstract type Source end

# Source accessors
function operators end
function resources end

mutable struct SourceInMem <: Source
  operators::Union{Array{Operator}, Nothing}
  resources::Union{Array{Resource}, Nothing}
end
SourceInMem() = SourceInMem(nothing, nothing)

operators(pd::SourceInMem) = pd.operators
resources(pd::SourceInMem) = pd.resources

include("playerdata_sqlite.jl")

const PDSQLite = SourceInSQL

end

