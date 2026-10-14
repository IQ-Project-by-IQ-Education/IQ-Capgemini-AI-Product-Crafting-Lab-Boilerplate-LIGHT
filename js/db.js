// The app's database: real SQLite (sql.js), kept inside the browser.
// It is saved to IndexedDB after every write (localStorage if IndexedDB is blocked).
//
//   await DB.init()                         open the database (app.js does this once)
//   DB.run(sql, params)  -> { id, changes } INSERT / UPDATE / DELETE (saves automatically)
//   DB.all(sql, params)  -> [ {row}, ... ]  SELECT many rows
//   DB.get(sql, params)  -> {row} or null   SELECT one row
//   DB.exportFile()                         download the database as a .sqlite file
//   await DB.importFile(file)               replace the database with a .sqlite file
//   await DB.reset()                        delete everything and start empty
//
// Always pass user input as params (the ? placeholders), never glue it into the SQL text.

var DB = (function () {
  var SQL = null;
  var db = null;
  var KEY = "lab-db:" + APP_NAME;
  var saving = Promise.resolve();

  // ---- browser storage (IndexedDB first, localStorage fallback) ----

  function idbOpen() {
    return new Promise(function (resolve, reject) {
      if (!window.indexedDB) return reject(new Error("IndexedDB unavailable"));
      var req = indexedDB.open(KEY, 1);
      req.onupgradeneeded = function () { req.result.createObjectStore("files"); };
      req.onsuccess = function () { resolve(req.result); };
      req.onerror = function () { reject(req.error); };
    });
  }

  function idb(mode, action) {
    return idbOpen().then(function (handle) {
      return new Promise(function (resolve, reject) {
        var tx = handle.transaction("files", mode);
        var req = action(tx.objectStore("files"));
        tx.oncomplete = function () { handle.close(); resolve(req.result); };
        tx.onerror = function () { handle.close(); reject(tx.error); };
      });
    });
  }

  function toBase64(bytes) {
    var s = "";
    for (var i = 0; i < bytes.length; i += 0x8000) {
      s += String.fromCharCode.apply(null, bytes.subarray(i, i + 0x8000));
    }
    return btoa(s);
  }

  function fromBase64(text) {
    var s = atob(text);
    var bytes = new Uint8Array(s.length);
    for (var i = 0; i < s.length; i++) bytes[i] = s.charCodeAt(i);
    return bytes;
  }

  var store = {
    mode: "indexeddb",
    load: function () {
      return idb("readonly", function (s) { return s.get("main"); }).catch(function () {
        store.mode = "localstorage";
        var text = localStorage.getItem(KEY); // throws if site storage is disabled
        return text ? fromBase64(text) : null;
      });
    },
    save: function (bytes) {
      if (store.mode === "indexeddb") {
        return idb("readwrite", function (s) { return s.put(bytes, "main"); });
      }
      localStorage.setItem(KEY, toBase64(bytes));
      return Promise.resolve();
    },
    clear: function () {
      if (store.mode === "indexeddb") {
        return idb("readwrite", function (s) { return s.delete("main"); });
      }
      localStorage.removeItem(KEY);
      return Promise.resolve();
    },
  };

  // ---- helpers ----

  function applySchema() {
    db.exec(SCHEMA_SQL);
    (window.SCHEMA_UPGRADES || []).forEach(function (sql) {
      try { db.exec(sql); } catch (e) { /* already applied */ }
    });
  }

  function persist() {
    var bytes = db.export();
    saving = saving.then(function () { return store.save(bytes); }).catch(function (e) {
      console.error("Could not save the database", e);
      if (window.toast) toast("Could not save — browser storage is blocked");
    });
    return saving;
  }

  function rows(sql, params) {
    var stmt = db.prepare(sql);
    try {
      stmt.bind(params || []);
      var out = [];
      while (stmt.step()) out.push(stmt.getAsObject());
      return out;
    } finally {
      stmt.free();
    }
  }

  // ---- public API ----

  return {
    init: function () {
      return initSqlJs().then(function (lib) {
        SQL = lib;
        return store.load();
      }).then(function (bytes) {
        db = bytes ? new SQL.Database(bytes) : new SQL.Database();
        applySchema();
        return persist();
      });
    },

    run: function (sql, params) {
      db.run(sql, params || []);
      var result = {
        id: db.exec("SELECT last_insert_rowid()")[0].values[0][0],
        changes: db.getRowsModified(),
      };
      persist();
      return result;
    },

    all: function (sql, params) {
      return rows(sql, params);
    },

    get: function (sql, params) {
      return rows(sql, params)[0] || null;
    },

    exportFile: function () {
      var blob = new Blob([db.export()], { type: "application/x-sqlite3" });
      var a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = APP_NAME.replace(/[^a-z0-9]+/gi, "-") + "-" + new Date().toISOString().slice(0, 10) + ".sqlite";
      document.body.appendChild(a);
      a.click();
      a.remove();
      setTimeout(function () { URL.revokeObjectURL(a.href); }, 1000);
    },

    importFile: function (file) {
      return file.arrayBuffer().then(function (buf) {
        var next = new SQL.Database(new Uint8Array(buf));
        next.exec("SELECT count(*) FROM sqlite_master"); // throws if not a SQLite file
        db.close();
        db = next;
        applySchema();
        return persist();
      });
    },

    reset: function () {
      db.close();
      db = new SQL.Database();
      applySchema();
      return store.clear().then(persist);
    },

    storage: function () { return store.mode; },
  };
})();
