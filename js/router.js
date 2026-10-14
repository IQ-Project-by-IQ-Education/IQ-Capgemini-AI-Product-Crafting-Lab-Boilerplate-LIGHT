// One page, many screens: each screen is a "#/path" in the address bar.
//
//   Router.on("/items/:id", function (params) { ... })   register a screen
//   Router.go("/items/3")                                 open a screen
//   render(html)                                          show html in the page
//   esc(text)                                             make user text safe to put in html
//   toast("Saved")                                        small message at the bottom

var Router = (function () {
  var routes = [];
  var fallback = "/items";

  function match(pattern, path) {
    var p = pattern.split("/");
    var s = path.split("/");
    if (p.length !== s.length) return null;
    var params = {};
    for (var i = 0; i < p.length; i++) {
      if (p[i].charAt(0) === ":") params[p[i].slice(1)] = decodeURIComponent(s[i]);
      else if (p[i] !== s[i]) return null;
    }
    return params;
  }

  function handle() {
    var path = (location.hash.replace(/^#/, "") || fallback).split("?")[0];
    for (var i = 0; i < routes.length; i++) {
      var params = match(routes[i].pattern, path);
      if (params) {
        try {
          routes[i].handler(params);
        } catch (e) {
          console.error(e);
          render('<p class="empty">Something went wrong on this screen.</p>');
        }
        window.scrollTo(0, 0);
        return;
      }
    }
    Router.go(fallback);
  }

  return {
    on: function (pattern, handler) { routes.push({ pattern: pattern, handler: handler }); },
    go: function (path) {
      if (location.hash === "#" + path) handle();
      else location.hash = path;
    },
    home: function (path) { fallback = path; },
    start: function () {
      window.addEventListener("hashchange", handle);
      handle();
    },
  };
})();

function render(html) {
  document.getElementById("app").innerHTML = html;
}

function esc(value) {
  return String(value == null ? "" : value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function toast(message) {
  var el = document.getElementById("toast");
  el.textContent = message;
  el.hidden = false;
  clearTimeout(toast.timer);
  toast.timer = setTimeout(function () { el.hidden = true; }, 2500);
}
