/* navigation.js
 * Single source of truth for all navigation behavior
 */

(function (window) {

  let currentMainTab = null;

  // ---------- utils ----------

  function normalize(x) {
    return String(x || "").trim().toLowerCase();
  }

  function getKey(el) {
    if (el.dataset && el.dataset.value !== undefined) {
      return normalize(el.dataset.value);
    }

    if (el.getAttribute("href") === "#" && el.id) {
      return normalize(el.id);
    }

    return normalize(el.textContent);
  }

  // ---------- main tab activation ----------

  function activateMainTab(tabId, sourceEl = null) {
    const links = document.querySelectorAll("nav a.link_clickable");

    if (!tabId) return null;

    if (currentMainTab === tabId) {
      return document.querySelector(`.tab-pane[data-value="${tabId}"]`);
    }

    //  Set which item is selected as highlighted in the visible navigation selection
    links.forEach(l => l.classList.remove("active"));

    if (sourceEl) {
      sourceEl.classList.add("active");
    } else {
      const el = Array.from(links).find(l =>
        (l.dataset.tab || l.id) === tabId
      );
      if (el) el.classList.add("active");
    }
    // End

    // Trigger navigation change for shiny
    if (window.Shiny && Shiny.setInputValue) {
      Shiny.setInputValue("main_tabs", tabId, { priority: "event" });
    }
    // Keep track of which one is active
    currentMainTab = tabId;

    window.scrollTo(0, 0);

    return document.querySelector(`.tab-pane[data-value="${tabId}"]`);
  }

  function activateMainTabBySegment(segment) {
    const seg = normalize(segment);
    const links = document.querySelectorAll("nav a.link_clickable");

    const match = Array.from(links).find(l => getKey(l) === seg);

    if (!match) {
      console.error("Main tab not found:", segment);
      return null;
    }

    const tabId = match.dataset.tab || match.id;

    if (!tabId) {
      console.error("Main tab has no id or data-tab:", match);
      return null;
    }

    return activateMainTab(tabId, match);
  }

  // ---------- nested tab activation ----------

  function activateNestedTab(scope, segment) {
    if (!scope) return null;

    const seg = normalize(segment);
    const tabs = scope.querySelectorAll(".nav-tabs a[data-toggle='tab']");

    let matchedViaTitle = false;

    const match = Array.from(tabs).find(a => {
      if (a.dataset.value !== undefined) {
        return normalize(a.dataset.value) === seg;
      }
      if (normalize(a.textContent) === seg) {
        matchedViaTitle = true;
        return true;
      }
      return false;
    });

    if (!match) {
      console.error("Nested tab not found:", segment);
      return null;
    }

    if (!match.classList.contains("active") &&
        !match.parentElement.classList.contains("active")) {
      match.click();
      window.scrollTo(0, 0);
    }

    if (matchedViaTitle) {
      const href = match.getAttribute("href");
      if (href && href.startsWith("#")) {
        return document.querySelector(href);
      }
    }

    if (match.dataset.value !== undefined) {
      return scope.querySelector(
        `.tab-pane[data-value="${match.dataset.value}"]`
      );
    }

    return null;
  }

  // ---------- path-based navigation ----------

  function navigatePath(path, { async = false, delay = 50 } = {}) {
    const steps = path
      .split("/")
      .map(normalize)
      .filter(Boolean);

    function step(i, scope) {
      if (i >= steps.length) return;

      const nextScope =
        i === 0
          ? activateMainTabBySegment(steps[i])
          : activateNestedTab(scope, steps[i]);

      if (!nextScope) return;

      if (async) {
        setTimeout(() => step(i + 1, nextScope), delay);
      } else {
        step(i + 1, nextScope);
      }
    }

    step(0, null);
  }

  // ---------- public API ----------

  window.Navigation = {
    activateMainTab,
    activateMainTabBySegment,
    activateNestedTab,
    navigatePath
  };

})(window);
