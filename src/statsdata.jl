# accessors
function stage_reports end
function recruit_reports end

module StatsData

using JSON
using HTTP
using DataFrames

using AKCalc

abstract type Source end

struct SourceInMem <: Source
  stage_reports::DataFrame
  recruit_reports::DataFrame
end

stage_reports(pd::SourceInMem) = pd.stage_reports::DataFrame
recruit_reports(pd::SourceInMem) = pd.recruit_reports::DataFrame

end

