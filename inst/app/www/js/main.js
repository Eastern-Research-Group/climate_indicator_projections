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
