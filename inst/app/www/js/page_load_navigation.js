let navigationHandled = false;

function handleInitialNavigation() {
  if (navigationHandled) return;

  const params = new URLSearchParams(window.location.search);

  if (params.has("nav")) {
    navigationHandled = true; // Only trigger this once on a page load
    Navigation.navigatePath(params.get("nav"), {
      async: false
    });
  }
}

function debounce(fn, delay = 100, debounce_only = false) {
  let timer = null;
  return function(debounce_only=false) {
    return function (...args) {
      clearTimeout(timer);
      if (!debounce_only) {
        timer = setTimeout(() => {
          fn.apply(this, args);
        }, delay);
      }
    };
  };
}

const debouncedHandleInitialNavigation = debounce(handleInitialNavigation, 600);

$(document).on("shiny:idle", debouncedHandleInitialNavigation(debounce_only=false));
$(document).on("shiny:busy", debouncedHandleInitialNavigation(debounce_only=true));
//$(document).on("shiny:sessioninitialized", debouncedHandleInitialNavigation);
