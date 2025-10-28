// Tab switching function
let currentTab = null;
document.addEventListener("DOMContentLoaded", function () {
    const links = document.querySelectorAll(".link_clickable");

    links.forEach(link => {
        link.addEventListener("click", function (e) {
            e.preventDefault();

            // Remove active class from all
            links.forEach(l => l.classList.remove("active"));
            this.classList.add("active");

            // Tell Shiny to switch tab
            let tabId = this.getAttribute("data-tab");

            if (tabId == null) {
              tabId = this.id;
            }
            if (currentTab != tabId) {
              Shiny.setInputValue("main_tabs", tabId, { priority: "event" });
              currentTab = tabId;
            }
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