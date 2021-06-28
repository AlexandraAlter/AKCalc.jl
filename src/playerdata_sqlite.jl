using SQLite
using Tables

struct SourceInSQL <: Source
  db::SQLite.DB
  cache::SourceInMem

  function SourceInSQL(file::AbstractString)
    db = new(SQLite.DB(file))
    init(db)
    return db
  end
end
SourceInSQL() = SourceInSQL(":memory:")

function haspatch(source::SourceInSQL, patch::Int)
  stmt = DBInterface.prepare(source.db, """
    SELECT * FROM meta WHERE patch = ?;
  """)
  results = DBInterface.execute(stmt, [patch])
  return length(result) > 0
end

function addpatch(source::SourceInSQL, patch::Int,
    notes::AbstractString, sql::AbstractString)
  stmt = DBInterface.prepare(source.db, """
    INSERT INTO meta VALUES(?, ?, ?, ?)")
  """)
  res = DBInterface.execute(stmt, [patch, notes, false, nothing])

  if !res
    stmt = DBInterface.prepare(source.db, """
      INSERT INTO meta VALUES(?, ?, ?, ?)")
    """)
    DBInterface.execute(stmt, [patch, notes, true, error_msg])
  end
end

function init(source::SourceInSQL)
  DBInterface.execute(source.db, "PRAGMA foreign_keys = ON;")

  DBInterface.execute(source.db, """
    CREATE TABLE IF NOT EXISTS resources(
      id TEXT PRIMARY KEY,
      val INTEGER NOT NULL DEFAULT 0
    );
  """)

  DBInterface.execute(source.db, """
    CREATE TABLE IF NOT EXISTS operators(
      id TEXT PRIMARY KEY,
      level INTEGER NOT NULL DEFAULT 0,
      promotion INTEGER NOT NULL CHECK (promotion BETWEEN 0 and 2) DEFAULT 0,
      xp INTEGER NOT NULL DEFAULT 0,
      skill_rank INTEGER NOT NULL DEFAULT 0,
      skill_1_mastery INTEGER NOT NULL DEFAULT 0,
      skill_2_mastery INTEGER NOT NULL DEFAULT 0,
      skill_3_mastery INTEGER NOT NULL DEFAULT 0,
      trust INTEGER NOT NULL DEFAULT 0,
      potential INTEGER NOT NULL DEFAULT 0
    );
  """)
end

function operators(source::SourceInSQL, gamedata::GameData.Source)
  query = DBInterface.execute(source.db, "SELECT * FROM operators;")
  ops = map(Tables.rows(query)) do row
    bases = filter(b -> row.id == b.id, GameData.operator_bases(gamedata))
    if length(bases) == 0
      throw(DomainError(row.id, "Could not find a matching operator base"))
    end
    level = OperatorLevel(row.level, PromotionPhase(row.promotion))
    skills = OperatorSkills(row.skill_rank, row.skill_1_mastery, row.skill_2_mastery, row.skill_3_mastery)
    Operator(first(bases), level, row.trust, row.xp, skills, row.potential)
  end
  return ops
end

function Base.append!(source::SourceInSQL, ops::AbstractArray{Operator})
  stmt = DBInterface.prepare(source.db, """
    INSERT INTO operators (id) VALUES (?);")
  """)
  for op in ops
    DBInterface.execute(stmt, [op.base.id])
  end
end

function resources(source::SourceInSQL)
  stmt = DBInterface.execute(source.db, """
    SELECT * FROM resources;
  """)
  return stmt
end

