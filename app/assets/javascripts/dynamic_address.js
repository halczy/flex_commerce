// document.addEventListener("turbolinks:load", function() {

  $(document).ready(function() {
    return $("#provinces_select").on("change", function() {
      return $.ajax({
        url: "/addresses/update_selector",
        type: "GET",
        dataType: "script",
        data: {
          province_id: $('#provinces_select option:selected').val()
        }
      });
    });
  });

  $(document).ready(function() {
    return $("#cities_select").on("change", function() {
      return $.ajax({
        url: "/addresses/update_selector",
        type: "GET",
        dataType: "script",
        data: {
          province_id: $('#provinces_select option:selected').val(),
          city_id: $('#cities_select option:selected').val()
        }
      });
    });
  });

  $(document).ready(function() {
    return $("#districts_select").on("change", function() {
      return $.ajax({
        url: "/addresses/update_selector",
        type: "GET",
        dataType: "script",
        data: {
          province_id: $('#provinces_select option:selected').val(),
          city_id: $('#cities_select option:selected').val(),
          district_id: $('#districts_select option:selected').val()
        }
      });
    });
  });

// });
