// Function to apply accessibility attributes and keyboard handling
function applyCircleAttributes(element) {
  element.setAttribute('tabindex', '0');
  element.setAttribute('role', 'button');
  element.setAttribute('aria-label', 'Map Circle Marker');

  if (!element.dataset.a11yBound) {
    // Keyboard activation (Enter or Space)
    element.addEventListener('keydown', function(event) {
      if (event.key === 'Enter' || event.key === ' ' || event.keyCode === 13 || event.keyCode === 32) {
        event.preventDefault();

        // Trigger Leaflet click event
        const clickEvent = new MouseEvent('click', { bubbles: true, cancelable: true });
        element.dispatchEvent(clickEvent);
      }
    });

    // Optional: simulate hover on focus to show tooltip
    element.addEventListener('focus', function() {
      const mouseOverEvent = new MouseEvent('mouseover', { bubbles: true, cancelable: true });
      element.dispatchEvent(mouseOverEvent);
    });

    // Optional: simulate mouse out when blur to hide tooltip
    element.addEventListener('blur', function() {
      const mouseOutEvent = new MouseEvent('mouseout', { bubbles: true, cancelable: true });
      element.dispatchEvent(mouseOutEvent);
    });

    element.dataset.a11yBound = 'true';
  }
}

$(document).ready(function() {
  const observer = new MutationObserver(mutations => {
    for (const mutation of mutations) {
      for (const node of mutation.addedNodes) {
        if (node.nodeType === Node.ELEMENT_NODE) {
          if (node.classList.contains('circle_tabbable')) {
            applyCircleAttributes(node);
          }

          node.querySelectorAll('.circle_tabbable').forEach(el => applyCircleAttributes(el));
        }
      }
    }
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true
  });

  document.querySelectorAll('.circle_tabbable').forEach(applyCircleAttributes);
});
