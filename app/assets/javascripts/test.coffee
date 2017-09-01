$(document).ready ->
  $("#provinces_select").on "change", ->
    $.ajax
      url: "/addresses/update_cities"
      type: "GET"
      dataType: "script"
      data:
        province_id: $('#provinces_select option:selected').val()
