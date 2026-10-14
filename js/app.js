// The app's screens. The "items" example below (list -> form -> detail) is the
// pattern to copy for every new thing the app keeps track of.

// ---------- Items: list ----------
Router.on("/items", function () {
  var items = DB.all("SELECT * FROM items ORDER BY id DESC");
  render(`
    <div class="page-head">
      <h1>Items</h1>
      <a class="button primary" href="#/items/new">New item</a>
    </div>
    ${items.length === 0 ? '<p class="empty">Nothing here yet. Add your first item.</p>' : `
      <ul class="list">
        ${items.map(function (item) {
          return `<li><a href="#/items/${item.id}">
            <strong>${esc(item.title)}</strong>
            <span class="muted">${esc(item.created_at)}</span>
          </a></li>`;
        }).join("")}
      </ul>`}
  `);
});

// ---------- Items: new / edit form ----------
function itemForm(item) {
  render(`
    <div class="page-head"><h1>${item ? "Edit item" : "New item"}</h1></div>
    <form id="item-form" class="card form">
      <label>Title
        <input name="title" required value="${esc(item && item.title)}">
      </label>
      <label>Notes
        <textarea name="notes" rows="4">${esc(item && item.notes)}</textarea>
      </label>
      <div class="actions">
        <button type="submit" class="primary">Save</button>
        <a class="button" href="${item ? "#/items/" + item.id : "#/items"}">Cancel</a>
      </div>
    </form>
  `);
  document.getElementById("item-form").addEventListener("submit", function (e) {
    e.preventDefault();
    var f = e.target;
    var title = f.title.value.trim();
    var notes = f.notes.value.trim();
    if (item) {
      DB.run("UPDATE items SET title = ?, notes = ? WHERE id = ?", [title, notes, item.id]);
      toast("Saved");
      Router.go("/items/" + item.id);
    } else {
      var result = DB.run("INSERT INTO items (title, notes) VALUES (?, ?)", [title, notes]);
      toast("Saved");
      Router.go("/items/" + result.id);
    }
  });
}

Router.on("/items/new", function () { itemForm(null); });

Router.on("/items/:id/edit", function (params) {
  var item = DB.get("SELECT * FROM items WHERE id = ?", [params.id]);
  if (!item) return Router.go("/items");
  itemForm(item);
});

// ---------- Items: detail ----------
Router.on("/items/:id", function (params) {
  var item = DB.get("SELECT * FROM items WHERE id = ?", [params.id]);
  if (!item) return Router.go("/items");
  render(`
    <p><a href="#/items">&larr; All items</a></p>
    <article class="card">
      <h1>${esc(item.title)}</h1>
      <p class="muted">Added ${esc(item.created_at)}</p>
      <p class="notes">${esc(item.notes) || '<span class="muted">No notes.</span>'}</p>
      <div class="actions">
        <a class="button primary" href="#/items/${item.id}/edit">Edit</a>
        <button type="button" id="btn-delete" class="danger">Delete</button>
      </div>
    </article>
  `);
  document.getElementById("btn-delete").addEventListener("click", function () {
    if (!confirm("Delete this item?")) return;
    DB.run("DELETE FROM items WHERE id = ?", [item.id]);
    toast("Deleted");
    Router.go("/items");
  });
});

// ---------- Export / Import / Reset (header buttons) ----------
document.getElementById("btn-export").addEventListener("click", function () {
  DB.exportFile();
  toast("Exported — check your Downloads folder");
});

document.getElementById("btn-import").addEventListener("click", function () {
  document.getElementById("import-file").click();
});

document.getElementById("import-file").addEventListener("change", function (e) {
  var file = e.target.files[0];
  e.target.value = "";
  if (!file) return;
  if (!confirm("Replace all current data with " + file.name + "?")) return;
  DB.importFile(file).then(function () {
    toast("Imported");
    Router.go("/items");
  }).catch(function () {
    toast("That file is not a database export");
  });
});

document.getElementById("btn-reset").addEventListener("click", function () {
  if (!confirm("Delete ALL data in this app? Export first if you want a copy.")) return;
  DB.reset().then(function () {
    toast("Everything was deleted");
    Router.go("/items");
  });
});

// ---------- Start ----------
document.title = APP_NAME;
document.getElementById("app-name").textContent = APP_NAME;

DB.init().then(function () {
  Router.home("/items");
  Router.start();
}).catch(function (e) {
  console.error(e);
  render(`<p class="loading">Loading…</p>
    <p class="empty">This browser is not allowing the app to save data (site storage is disabled).
    Try Edge or Chrome, or ask IT to allow site data for local files.</p>`);
});
