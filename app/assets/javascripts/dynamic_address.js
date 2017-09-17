$("#provinces_select").on("change", function() {
  $.ajax({
    url: "/addresses/update_selector",
    type: "GET",
    dataType: "script",
    data: {
      province_id: $('#provinces_select option:selected').val()
    }
  });
});

$("#cities_select").on("change", function() {
  $.ajax({
    url: "/addresses/update_selector",
    type: "GET",
    dataType: "script",
    data: {
      province_id: $('#provinces_select option:selected').val(),
      city_id: $('#cities_select option:selected').val()
    }
  });
});

$("#districts_select").on("change", function() {
  $.ajax({
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
