// Tab switching function
/*
document.addEventListener('DOMContentLoaded', function() {
    const tabNav = document.querySelector('.tab-nav');
    const tabLinks = document.querySelectorAll('.tab-nav a');
    const tabContents = document.querySelectorAll('.tab-content');

    if (tabNav) {
        tabNav.addEventListener('click', function(e) {
        if (e.target.tagName === 'A') {
            e.preventDefault();
            const tab = e.target.id.replace('tab-', '');
            // Hide all tab contents and remove active classes
            tabContents.forEach(el => {
                el.style.display = 'none';
                el.classList.remove('active');
            });
            tabLinks.forEach(link => link.classList.remove('active'));
            // Show selected tab content and set active class
            const content = document.getElementById('content-' + tab);
            if (content) {
                content.style.display = 'block';
                content.classList.add('active');
            }
            e.target.classList.add('active');
        }
    });
    }

});
*/
$(document).on('click', 'a.link_clickable', function(event) {
  // Get ID of clicked <a> element
  Shiny.setInputValue("selected_tab", event.target.id);
  $(".link_clickable.active").removeClass("active");
  event.target.classList.add('active');

  //$('#' + event.target.id.replace("-link", "-button")).click();
});
