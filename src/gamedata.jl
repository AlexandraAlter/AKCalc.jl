module GameData

using JSON
using HTTP
using DataFrames
using Dates

using AKCalc

export GDKengxxiao, GDAceShip

include("gamedata_types.jl")

abstract type Source end

# Source accessors
function resource_types end
function factory_recipes end
function workshop_recipes end
function operator_bases end
function enemy_bases end
function enemies end
function tiles end
function maps end
function stages end

"""
  GameData Source that simply stores objects in memory.
"""
mutable struct SourceInMem <: Source
  resource_types::Union{Array{ResourceType}, Nothing}
  factory_recipes::Union{Array{FactoryRecipe}, Nothing}
  workshop_recipes::Union{Array{WorkshopRecipe}, Nothing}
  operator_bases::Union{Array{OperatorBase}, Nothing}
  enemy_bases::Union{Array{EnemyBase}, Nothing}
  enemies::Union{Array{EnemyStats}, Nothing}
  tiles::Union{Array{Tile}, Nothing}
  maps::Union{Array{Map}, Nothing}
  stages::Union{Array{Stage}, Nothing}

  function SourceInMem()
    return new(nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing)
  end
end

"""
  GameData Source that caches results in memory, or falls back on another provided source.
"""
mutable struct SourceCache <: Source
  source::Source
  cache::SourceInMem

  function SourceCache(source::Source)
    return new(source, SourceInMem())
  end
end

function Base.show(io::IO, sc::SourceCache)
  print(io, "SourceCache($(sc.source))")
end

function _load_and_cache(sc::SourceCache, name::Symbol, accessor::Function)
  if isnothing(Base.getproperty(sc.cache, name))
    val = accessor(sc.source)
    Base.setproperty!(sc.cache, name, val)
    return val
  else
    return Base.getproperty(sc.cache, name)
  end
end

resource_types(sc::SourceCache)   = _load_and_cache(sc, :resource_types, resource_types)
factory_recipes(sc::SourceCache)  = _load_and_cache(sc, :factory_recipes, factory_recipes)
workshop_recipes(sc::SourceCache) = _load_and_cache(sc, :workshop_recipes, workshop_recipes)
operator_bases(sc::SourceCache)   = _load_and_cache(sc, :operator_bases, operator_bases)
enemy_bases(sc::SourceCache)      = _load_and_cache(sc, :enemy_bases, enemy_bases)
enemies(sc::SourceCache)          = _load_and_cache(sc, :enemies, enemies)
tiles(sc::SourceCache)            = _load_and_cache(sc, :tiles, tiles)
maps(sc::SourceCache)             = _load_and_cache(sc, :maps, maps)
stages(sc::SourceCache)           = _load_and_cache(sc, :stages, stages)

"""
  Returns the contents of a gamedata file, parsed out of JSON into a Juila type.
"""
function _fetch_file end

"""
  GameData Source that pulls data from a URL.
  Caches intermediate JSON results.
"""
struct SourceByURL <: Source
  base_url::String
  lang::String
  cache::Dict{AbstractString, Any}
end
SourceByURL(base_url::String, lang::String) = SourceByURL(base_url, lang, Dict())

function Base.show(io::IO, su::SourceByURL)
  print(io, "SourceByURL($(su.base_url), $(su.lang))")
end

function _fetch_file(source::SourceByURL, file::String)
  url = "$(source.base_url)/$(source.lang)/$file"
  return get!(source.cache, url) do
    JSON.parse(String(HTTP.get(url).body))
  end
end

struct SourceByPath <: Source
  base_path::String
  lang::String
  cache::Union{Dict{AbstractString, AbstractString}, Nothing}
end

function Base.show(io::IO, su::SourceByPath)
  print(io, "SourceByPath($(su.base_path), $(su.lang))")
end

function _fetch_file(source::SourceByPath, file::String)
end

const LANGS = Dict(
  :en => "en_US",
  :ja => "ja_JP",
  :ko => "ko_KR",
  :zhcn => "zh_CN",
  :zhtw => "zh_TW",
)

const FILES = Dict(
  :buffs => "gamedata/buff_table.json",

  :activities       => "gamedata/excel/activity_table.json",
  :audio            => "gamedata/excel/audio_data.json",
  :buildings        => "gamedata/excel/building_data.json",
  :characters       => "gamedata/excel/character_table.json",
  :char_words       => "gamedata/excel/charword_table.json",
  :checkins         => "gamedata/excel/checkin_table.json",
  :clues            => "gamedata/excel/clue_data.json",
  :crisises         => "gamedata/excel/crisis_table.json",
  :version          => "gamedata/excel/data_version.txt",
  :handbook_enemies => "gamedata/excel/enemy_handbook_table.json",
  :favors           => "gamedata/excel/favor_table.json",
  :gatcha           => "gamedata/excel/gacha_table.json",
  :consts           => "gamedata/excel/gamedata_const.json",
  :handbook_info    => "gamedata/excel/handbook_info_table.json",
  :hanbook          => "gamedata/excel/handbook_table.json",
  :handboox_teams   => "gamedata/excel/handbook_team_table.json",
  :items            => "gamedata/excel/item_table.json",
  :medals           => "gamedata/excel/medal_table.json",
  :missions         => "gamedata/excel/mission_table.json",
  :open_servers     => "gamedata/excel/open_server_table.json",
  :ranges           => "gamedata/excel/range_table.json",
  :replicates       => "gamedata/excel/replicate_table.json",
  :roguelike        => "gamedata/excel/roguelike_table.json",
  :runes            => "gamedata/excel/rune_table.json",
  :shop             => "gamedata/excel/shop_client_table.json",
  :skills           => "gamedata/excel/skill_table.json",
  :skins            => "gamedata/excel/skin_table.json",
  :stages           => "gamedata/excel/stage_table.json",
  :story_reviews    => "gamedata/excel/story_review_table.json",
  :story            => "gamedata/excel/story_table.json",
  :tips             => "gamedata/excel/tip_table.json",
  :tokens           => "gamedata/excel/token_table.json",
  :zones            => "gamedata/excel/zone_table.json",

  :enemies => "gamedata/levels/enemydata/enemy_database.json",
)

const RESOURCE_ITEM_TYPES = Dict(
  "MATERIAL" => i_material,
  "CARD_EXP" => i_card_exp,
  "TKT_TRY" => i_ticket_try,
  "TKT_RECRUIT" => i_ticket_recruit,
  "TKT_GACHA" => i_ticket,
  "TKT_GACHA_10" => i_ticket_10,
  "TKT_INST_FIN" => i_ticket_inst_fin,
  "TKT_GACHA_PRSV" => i_ticket_rand_prsv,
  "LIMITED_TKT_GACHA_10" => i_lim_ticket_10,
  "ACTIVITY_ITEM" => i_act_item,
  "DIAMOND" => i_diamond,
  "DIAMOND_SHD" => i_diamond_shard,
  "EXP_PLAYER" => i_exp_player,
  "AP_ITEM" => i_ap_item,
  "AP_BASE" => i_ap_base,
  "AP_SUPPLY" => i_ap_supply,
  "AP_GAMEPLAY" => i_ap_gameplay,
  "VOUCHER_MGACHA" => i_voucher_rand_m,
  "VOUCHER_CGACHA" => i_voucher_rand_c,
  "VOUCHER_PICK" => i_voucher_pick,
  "GOLD" => i_gold,
  "ET_STAGE" => i_et_stage,
  "EPGS_COIN" => i_epgs,
  "REP_COIN" => i_rep_coin,
  "CRS_SHOP_COIN" => i_crs_shop_coin,
  "CRS_RUNE_COIN" => i_crs_rune_coin,
  "LMTGS_COIN" => i_lmtgs_coin,
  "ACTIVITY_COIN" => i_activity_coin,
  "SOCIAL_PT" => i_social_pt,
  "HGG_SHD" => i_hgg_shd,
  "LGG_SHD" => i_lgg_shd,
)

const RESOURCE_CLASS_TYPES = Dict(
  "MATERIAL" => c_material,
  "NORMAL" => c_normal,
  "CONSUME" => c_consume,
  "NONE" => c_none,
)

function resource_types(source::Source)
  json = _fetch_file(source, FILES[:items])
  items = ResourceType[]
  sizehint!(items, 400)

  for (id, val) in pairs(json["items"])
    name = val["name"]
    item_type = get(RESOURCE_ITEM_TYPES, val["itemType"]) do
      println("Unknown itemType $(val["itemType"])")
      i_unknown
    end
    class_type = get(RESOURCE_CLASS_TYPES, val["classifyType"]) do
      println("Unknown classifyType $(val["classifyType"])")
      c_unknown
    end
    abbrev = nothing
    usage = val["usage"]
    desc = val["description"]
    obtaining = val["obtainApproach"]
    rarity = val["rarity"]
    sort_id = val["sortId"]

    rt = ResourceType(id, name, item_type, class_type, abbrev, usage, desc, obtaining, rarity, sort_id)
    push!(items, rt)
  end

  return items
end

GDMem() = SourceInMem()
const GDKengxxiao = SourceCache(SourceByURL("https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master", LANGS[:en]))
const GDAceShip = SourceByURL("https://raw.githubusercontent.com/Aceship/AN-EN-Tags/master/json/gamedata", LANGS[:en])

end

