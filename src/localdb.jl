struct LocalDB
  sqlite::SQLite.DB

  function LocalDB(file::AbstractString)
    db = new(SQLite.DB(file))
    _localdb_init(db)
    return db
  end
end
LocalDB() = LocalDB(":memory:")

SourceKind(::LocalDB) = MultiSourceData()
has_const_data(::LocalDB) = true
has_stats_data(::LocalDB) = true
has_player_data(::LocalDB) = true

function _localdb_haspatch(db::LocalDB, patch::Int)
  stmt = DBInterface.prepare(db.sqlite, """
    SELECT * FROM meta WHERE patch = ?;
  """)
  results = DBInterface.execute(stmt, [patch])
  return length(result) > 0
end

function _localdb_addpatch(db::LocalDB, patch::Int,
    notes::AbstractString, sql::AbstractString)
  stmt = DBInterface.prepare(db.sqlite, """
    INSERT INTO meta VALUES(?, ?, ?, ?)")
  """)
  res = DBInterface.execute(stmt, [patch, notes, false, nothing])

  if !res
    stmt = DBInterface.prepare(db.sqlite, """
      INSERT INTO meta VALUES(?, ?, ?, ?)")
    """)
    DBInterface.execute(stmt, [patch, notes, true, error_msg])
  end
end

function _localdb_init(db::LocalDB)
  DBInterface.execute(db.sqlite, """
    PRAGMA foreign_keys = ON;
  """)

  DBInterface.execute(db.sqlite, """
    CREATE TABLE IF NOT EXISTS sources(
      id INTEGER PRIMARY KEY,
      name TEXT UNIQUE NOT NULL,
      version TEXT
    );
  """)

  DBInterface.execute(db.sqlite, """
    CREATE TABLE IF NOT EXISTS resource_types(
      id INTEGER PRIMARY KEY,
      source INTEGER,
      name TEXT NOT NULL,
      abbrev TEXT NOT NULL,
      rank INTEGER
    );
  """)

  DBInterface.execute(db.sqlite, """
    CREATE TABLE IF NOT EXISTS resources(
      val INTEGER DEFAULT 0,
      type INTEGER,

      FOREIGN KEY(type) REFERENCES resource_types(id)
    );
  """)

  DBInterface.execute(db.sqlite, """
    CREATE TABLE IF NOT EXISTS factory_recipes(
      id INTEGER PRIMARY KEY,
      product INTEGER,
      product_quant INTEGER,
      res1 INTEGER,
      res1_quant INTEGER,
      res2 INTEGER,
      res2_quant INTEGER,
      res3 INTEGER,
      res3_quant INTEGER,
      time INTEGER,
      capacity INTEGER,

      FOREIGN KEY(product) REFERENCES resources(id),
      FOREIGN KEY(res1) REFERENCES resources(id),
      FOREIGN KEY(res2) REFERENCES resources(id),
      FOREIGN KEY(res3) REFERENCES resources(id)
    );
  """)

  DBInterface.execute(db.sqlite, """
    CREATE TABLE IF NOT EXISTS workshop_recipes(
      id INTEGER PRIMARY KEY,
      product INTEGER,
      product_quant INTEGER,
      res1 INTEGER,
      res1_quant INTEGER,
      res2 INTEGER,
      res2_quant INTEGER,
      res3 INTEGER,
      res3_quant INTEGER,
      lmd INTEGER,
      morale INTEGER,

      FOREIGN KEY(product) REFERENCES resources(id),
      FOREIGN KEY(res1) REFERENCES resources(id),
      FOREIGN KEY(res2) REFERENCES resources(id),
      FOREIGN KEY(res3) REFERENCES resources(id)
    );
  """)

  DBInterface.execute(db.sqlite, """
    CREATE TABLE IF NOT EXISTS meta(
      id INTEGER PRIMARY KEY,
      patch INTEGER,
      notes TEXT,
      errored BOOLEAN,
      error_msg TEXT
    );
  """)

  DBInterface.execute(db.sqlite, """
    CREATE TABLE IF NOT EXISTS operator_bases(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      rank INTEGER
    );
  """)

  DBInterface.execute(db.sqlite, """
    CREATE TABLE IF NOT EXISTS operators(
      id INTEGER PRIMARY KEY,
      base INTEGER,

      FOREIGN KEY(base) REFERENCES operator_bases(id)
    );
  """)
end

function sources(db::LocalDB)
  return DBInterface.execute(db.sqlite, """
    SELECT * FROM sources;
  """) |> DataFrame
end

function merge_sources!(db::LocalDB, sources::)
  return DBInterface.execute(db.sqlite, """
    SELECT * FROM sources;
  """) |> DataFrame
end

function resource_types(db::LocalDB)
  return DBInterface.execute(db.sqlite, """
    SELECT * FROM resource_types;
  """) |> DataFrame
end


