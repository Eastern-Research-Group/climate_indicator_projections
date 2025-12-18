// Tab switching function
document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll("nav a.link_clickable").forEach(link => {
    link.addEventListener("click", function (e) {
      e.preventDefault();

      const tabId = this.dataset.tab || this.id;
      Navigation.activateMainTab(tabId, this);
    });
  });
});


// Hamburger menu toggle for sidebar
document.addEventListener('DOMContentLoaded', function() {
    var hamburger = document.querySelector('.sidebar-hamburger');
    var sidebar = document.querySelector('.sidebar');
    if (hamburger && sidebar) {
        hamburger.addEventListener('click', function() {
            sidebar.classList.toggle('open');
        });
        // Optional: close sidebar when clicking outside
        document.addEventListener('click', function(e) {
            if (sidebar.classList.contains('open') && !sidebar.contains(e.target) && e.target !== hamburger && !hamburger.contains(e.target)) {
                sidebar.classList.remove('open');
            }
        });
        // Hide sidebar when a link inside it is clicked (mobile UX)
        sidebar.addEventListener('click', function(e) {
            if (sidebar.classList.contains('open') && e.target.tagName === 'A') {
                sidebar.classList.remove('open');
            }
        });
    }
});
