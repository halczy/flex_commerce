document.addEventListener("turbolinks:load", function() {

// Enable admin dashboard menu toggle
  $("#menu-toggle").click(function(e) {
          e.preventDefault();
          $("#wrapper").toggleClass("toggled");
  });

});
