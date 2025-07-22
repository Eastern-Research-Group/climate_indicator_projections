// Tab switching function
document.addEventListener('DOMContentLoaded', function() {
    const tabNav = document.querySelector('.tab-nav');
    const tabLinks = document.querySelectorAll('.tab-nav a');
    const tabContents = document.querySelectorAll('.tab-content');

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
});