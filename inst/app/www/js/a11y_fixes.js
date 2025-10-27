
$(document).ready(function() {

  // --- Helper: Fix orphaned label accessibility ---
  function fix_radio_button_a11y(label) {
    const targetId = label.getAttribute("for");
    const target = document.getElementById(targetId);

    // Skip if label already processed or linked correctly
    if (label.dataset.a11yFixed) return;
    if (target && ["INPUT", "SELECT", "TEXTAREA"].includes(target.tagName)) return;

    // If the target is a container for radio buttons, fix it semantically
    if (target && target.querySelector("input[type='radio']")) {
      console.log(`Fixing radio group label for #${targetId}`);

      const fieldset = document.createElement("fieldset");
      const legend = document.createElement("legend");
      legend.textContent = label.textContent;
      legend.className = label.className;

      target.parentNode.insertBefore(fieldset, target);
      fieldset.appendChild(legend);
      fieldset.appendChild(target);

      label.dataset.a11yFixed = "true";
      label.remove();
      return;
    }

    // Otherwise, just remove invalid 'for'
    console.log(`Removing orphaned 'for' attribute from label #${label.id}`);
    label.removeAttribute("for");
    label.dataset.a11yFixed = "true";
  }

  // --- Helper: Process new labels ---
  function processNewLabels(root) {
    root.querySelectorAll("label[for]").forEach(fix_radio_button_a11y);
  }

  // --- Observe only inside Shiny content areas ---
  const observedContainers = document.querySelectorAll(
    ".tab-pane.active, .shiny-input-container, #content-maps"
  );

  const observer = new MutationObserver(mutations => {
    for (const mutation of mutations) {
      for (const node of mutation.addedNodes) {
        if (node.nodeType !== Node.ELEMENT_NODE) continue;

        // Skip if node doesn’t contain labels
        if (!node.querySelector("label[for]")) continue;

        processNewLabels(node);
      }
    }
  });

  // Attach observer to known dynamic sections
  observedContainers.forEach(container => {
    observer.observe(container, {
      childList: true,
      subtree: true
    });
  });

  // Run once on initial load
  processNewLabels(document.body);

});
