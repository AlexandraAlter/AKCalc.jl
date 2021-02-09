module PlayerData

using JSON
using HTTP
using DataFrames

using AKCalc

export PDSQLite

include("playerdata_types.jl")

abstract type Source end

# Source accessors
function operators end
function resources end

struct SourceInMem <: Source
  operators::DataFrame
  resources::DataFrame
end

operators(pd::SourceInMem) = pd.operators::DataFrame
resources(pd::SourceInMem) = pd.resources::DataFrame

include("playerdata_sqlite.jl")

PDSQLite(file) = SourceInSQL(file)

end

