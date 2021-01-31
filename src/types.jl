"""
"""
struct Source
  id::Int8
  name::String
  version::String
end

Source(row::DataFrameRow) = Source(row.id, row.name, row.version)

"""
"""
struct SourceFlags
  flags::Int64
end

Base.convert(::Type{Int64}, sf::SourceFlags) = sf.flags
Base.show(io::IO, sf::SourceFlags) =
  show(io, bin(sf.flags))

"""
"""
struct ResourceType
  id::Int64
  sources::SourceFlags
  name::String
  abbrev::String
  rank::Int8
end

ResourceType(r::Tables.Row) = ResourceType(r.id, r.name, r.abbrev, r.rank)

function Base.show(io::IO, rt::ResourceType)
  print(io, "ResourceType($(rt.id), $(rt.name), $(rt.abbrev), $(rt.rank))")
end

"""
"""
struct Resource
  val::UInt64
  type::ResourceType

  Resource(val, type) = new(Base.convert(UInt64, val), type)
end

function Base.show(io::IO, r::Resource)
  print(io, "Resource($(r.val), $(r.type.abbrev))")
end

"""
"""
struct FactoryRecipe
  sources::SourceFlags
  product::Resource
  inputs::Array{Resource, 3}
  time::Dates.AbstractTime
  capacity::Int8
end

function Base.show(io::IO, fr::FactoryRecipe)
  print(io, "FactoryRecipe()")
end

"""
"""
struct WorkshopRecipe
  sources::SourceFlags
  product::Resource
  inputs::Array{Resource, 3}
  lmd::Resource
  morale::Int8
end

function Base.show(io::IO, wr::WorkshopRecipe)
  print(io, "WorkshopRecipe()")
end

@enum PromotionPhase e0=0 e1=1 e2=2

@enum AtkType no_atk=0 melee=1 ranged=2
@enum DmgType no_dmg=0 phys_dmg=1 arts_dmg=2 true_dmg=3

"""
"""
struct OperatorLevel
  level::Int16
  promotion::PromotionPhase
end

"""
"""
struct OperatorBase
  id::Int64
  name::String
  rank::Int8
end

"""
"""
struct Operator
  id::Int64
  base::OperatorBase
end

@enum EnemyRank ordinary=1 elite=2 leader=3
@enum EnemyGrade e=1 d=2 c=3 b=4 a=5 ap=6

"""
"""
struct EnemyFlags
  infected_creature::Bool
  possessed::Bool
  sarkaz::Bool
  drone::Bool
end

"""
"""
struct EnemyBase
  id::String
  name::String
  species::String
  flavour_text::String
  rank::EnemyRank
  atk_type::AtkType
  dmg_type::DmgType
  hp::EnemyGrade
  atk::EnemyGrade
  def::EnemyGrade
  res::EnemyGrade
  special::String
  base_stats::Any # EnemyStats
end

function Base.show(io::IO, m::EnemyBase)
  print(io, "EnemyBase()")
end

"""
"""
struct Resistances
  silence::Bool
  stun::Bool
  sleep::Bool
end

"""
"""
struct EnemyStats
  id::Int64
  type::EnemyBase
  level::Int64
  hp::Int64
  regen::Float64
  atk::Int64
  atk_int::Float64
  atk_radius::Float64
  def::Int64
  res::Float64
  mov::Float64
  weight::Int8
  resistances::Resistances
end

function Base.show(io::IO, m::EnemyStats)
  print(io, "EnemyStats()")
end

"""
"""
struct Tile
  id::Integer
  name::String
  ascii_art::Char
end

function Base.show(io::IO, t::Tile)
  print(io, t.ascii_art)
end

"""
"""
struct Map
  tiles::Vector{Tile}
end

function Base.show(io::IO, m::Map)
  print(io, "Map()")
end

@enum DropRarity unknown=0 guranteed=1 common=2 uncommon=3 rare=4 very_rare=5 three_stars=10

"""
"""
struct Stage
  id::String
  sources::SourceFlags
  # meta
  sanity_cost::Resource
  plan_cost::Resource
  rec_level::Int64
  # combat
  hp_seals::Int64
  enemy_count::Int64
  deployment_limit::Int64
  initial_cp::Int64
  max_cp::Int64
  enemies::Dict{EnemyStats, Int64}
  map::Map
  # rewards
  exp::Int64
  trust::Int64
  lmd::Resource
  first_drops::Dict{ResourceType, DropRarity}
  regular_drops::Dict{ResourceType, DropRarity}
  special_drops::Dict{ResourceType, DropRarity}
  extra_drops::Vector{ResourceType}
end

function Base.show(io::IO, s::Stage)
  print(io, "Stage()")
end

"""
"""
struct StageReport
  id::String
  sources::SourceFlags
  stars::Int8
  time::Dates.AbstractTime
  exp::Int64
  trust::Int64
  lmd::Resource
  drops::Dict{ResourceType, Int64}
end

function Base.show(io::IO, sr::StageReport)
  print(io, "StageReport()")
end

"""
"""
struct RecruitReport
  id::Integer
end

function Base.show(io::IO, sr::RecruitReport)
  print(io, "RecruitReport()")
end

