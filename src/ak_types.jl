@enum ResourceItemType begin 
  i_material
  i_card_exp
  i_act_item
  i_diamond
  i_diamond_shard
  i_ap_item
  i_ap_base
  i_ap_supply
  i_ap_gameplay
  i_exp_player
  i_lim_ticket_10
  i_epgs
  i_ticket
  i_ticket_try
  i_ticket_recruit
  i_ticket_10
  i_ticket_inst_fin
  i_ticket_rand_prsv
  i_gold
  i_voucher_pick
  i_voucher_rand_m
  i_voucher_rand_c
  i_et_stage
  i_rep_coin
  i_crs_shop_coin
  i_crs_rune_coin
  i_social_pt
  i_hgg_shd
  i_lmtgs_coin
  i_lgg_shd
  i_activity_coin
  i_unknown
end
@enum ResourceClassType c_material c_normal c_consume c_none c_unknown

"""
"""
struct ResourceType
  id::String
  name::String
  item_type::ResourceItemType
  class_type::ResourceClassType
  abbrev::Union{String, Nothing}
  usage::String
  desc::String
  obtaining::Union{String, Nothing}
  rarity::Int8
  sort_id::Int64
end

function Base.show(io::IO, rt::ResourceType)
  print(io, "ResourceType($(rt.id), $(rt.name), $(rt.abbrev), $(rt.rarity))")
end

"""
  Used primarily in PlayerData, but must be pre-defined for GameData
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
struct OperatorBase
  id::Int64
  name::String
  rank::Int8
end

"""
"""
struct EnemyFlags
  infected_creature::Bool
  possessed::Bool
  sarkaz::Bool
  drone::Bool
end

@enum EnemyRank ordinary=1 elite=2 leader=3
@enum EnemyGrade e=1 d=2 c=3 b=4 a=5 ap=6

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
struct OperatorLevel
  level::Int16
  promotion::PromotionPhase
end

"""
"""
struct Operator
  id::Int64
  base::OperatorBase
  level::OperatorLevel
  trust::Int64
  xp::Int64
  skill_rank::Union{Int8, Nothing}
  skill_1_mastery::Union{Int8, Nothing}
  skill_2_mastery::Union{Int8, Nothing}
  skill_3_mastery::Union{Int8, Nothing}
  potential::Int8
end

"""
"""
struct StageReport
  id::String
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

function Base.show(io::IO, rr::RecruitReport)
  print(io, "RecruitReport()")
end

