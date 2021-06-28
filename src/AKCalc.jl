module AKCalc

using Dates
using Tables
using DataFrames
using JSON

export @ak_str

# accessors
export resource_types, factory_recipes, workshop_recipes, operator_bases
export enemy_bases, enemies, tiles, maps, stages, stage_reports
export operators, resources

# AK types
export ResourceItemType, ResourceClassType, ResourceType, Resource
export FactoryRecipe, WorkshopRecipe
export AtkType, DmgType, Resistances
export PromotionPhase, OperatorBase, OperatorLevel, OperatorSkills, Operator
export EnemyFlags, EnemyRank, EnemyGrade, EnemyBase, EnemyStats
export Tile, Map, DropRarity, Stage
export StageReport, RecruitReport

# loaded early so the loops below can gather type instances
include("ak_types.jl")

for s in instances(ResourceItemType)
  @eval export $(Symbol(s))
end
for s in instances(ResourceClassType)
  @eval export $(Symbol(s))
end

export GDMem, GDKengxxiao, GDAceShip
export PDMem, PDSQLite
export SDMem

include("gamedata.jl")
include("playerdata.jl")
include("statsdata.jl")
include("queries.jl")
include("config.jl")
include("repl.jl")

using .GameData
using .PlayerData
using .StatsData
using .REPLMode: @ak_str

const DEFAULT_IO = Ref{IO}()

function __init__()
  DEFAULT_IO[] = stderr
  if isdefined(Base, :active_repl)
    REPLMode.repl_init(Base.active_repl)
  else
    atreplinit() do repl
      if isinteractive() && repl isa REPL.LineEditREPL
        isdefined(repl, :interface) || (repl.interface = REPL.setup_interface(repl))
        REPLMode.repl_init(repl)
      end
    end
  end
  return nothing
end

end

