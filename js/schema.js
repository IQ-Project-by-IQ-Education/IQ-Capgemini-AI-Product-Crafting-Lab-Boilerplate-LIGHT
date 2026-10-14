// Every table the app needs. Runs on every start, so always use CREATE TABLE IF NOT EXISTS.
// To add a column to an existing table, add an ALTER TABLE line to SCHEMA_UPGRADES below.
var SCHEMA_SQL = `
CREATE TABLE IF NOT EXISTS items (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  title      TEXT NOT NULL,
  notes      TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
`;

// Optional one-off changes to tables that already exist (e.g. a new column).
// Each line is tried once per start; "duplicate column" errors are ignored.
var SCHEMA_UPGRADES = [
  // "ALTER TABLE items ADD COLUMN status TEXT DEFAULT 'open'",
];
