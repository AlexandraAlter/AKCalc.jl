# Generic types for Arknights data repositories

"""
  Interface for determining whether a structure is a source of AK data

  All types implementing this interface should provide:
    SourceKind(T)::SourceKind
    sources(t)::AbstractArray{Source}
    has_const_data(T)::Bool
    has_stats_data(T)::Bool
    has_player_data(T)::Bool
  Types for which has_const_data is true should also provide:
    resource_types(t)::AbstractArray{ResourceType}
    factory_recipes(t)::AbstractArray{FactoryRecipe}
    workshop_recipes(t)::AbstractArray{WorkshopRecipe}
    operator_bases(t)::AbstractArray{OperatorBase}
    enemy_bases(t)::AbstractArray{EnemyBase}
    enemies(t)::AbstractArray{Enemy}
    tiles(t)::AbstractArray{Tile}
    maps(t)::AbstractArray{Map}
    stages(t)::AbstractArray{Stage}
  Types for which has_stats_data is true should also provide:
    stage_reports(t)::AbstractArray{StageReport}
  Types for which has_player_data is true should also provide:
    resources(t)::AbstractArray{Resource}
    operators(t)::AbstractArray{Operator}
"""
abstract type SourceKind end
struct NotSource <: SourceKind end
struct OneSourceData <: SourceKind end
struct MultiSourceData <: SourceKind end

SourceKind(x) = SourceKind(typeof(x))
SourceKind(::Type) = MultiSourceData() # default
SourceKind(::Type{Any}) = NotSource()

abstract type SourceMutability end
struct ImmSource <: SourceMutability end
struct MutSource <: SourceMutability end

SourceMutability(x) = SourceKind(typeof(x))
SourceMutability(::Type) = ImmSource() # default
SourceMutability(::Type{Any}) = ImmSource()

"""
  List all AKCalc.Source entries for this data source
"""
function sources end
sources(d) = sources(typeof(d), d)
sources(::MultiSourceData, d) = d.sources
sources(::OneSourceData, d) = [d.source]

function has_const_data end
has_const_data(t) = has_const_data(typeof(t))
has_const_data(::Type) = false

function has_stats_data end
has_stats_data(t) = has_stats_data(typeof(t))
has_stats_data(::Type) = false

function has_player_data end
has_player_data(t) = has_player_data(typeof(t))
has_player_data(::Type) = false

# constants

function resource_types end
function merge_resource_types! end

function factory_recipes end
function merge_factory_recipes! end

function workshop_recipes end
function merge_workshop_recipes! end

function operator_bases end
function merge_operator_bases! end

function enemy_bases end
function merge_enemy_bases! end

function enemies end
function merge_enemies! end

function tiles end
function merge_tiles! end

function maps end
function merge_maps! end

function stages end
function merge_stages! end

# stats

function stage_reports end
function merge_stage_reports! end

# state

function resources end
function merge_resources! end

function operators end
function merge_operators! end

# typeless defaults

resource_types(d) = d.resource_types::DataFrame
factory_recipes(d) = d.factory_recipes::DataFrame
workshop_recipes(d) = d.workshop_recipes::DataFrame
operator_bases(d) = d.operator_bases::DataFrame
enemy_bases(d) = d.enemy_bases::DataFrame
enemies(d) = d.enemies::DataFrame
tiles(d) = d.tiles::DataFrame
maps(d) = d.maps::DataFrame
stages(d) = d.stages::DataFrame
stage_reports(d) = d.stage_reports::DataFrame
resources(d) = d.resources::DataFrame
operators(d) = d.operators::DataFrame

