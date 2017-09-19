$('#method_select').on("change", function() {
  if ($('#method_select').val() == 'delivery') {
    $('#address_section').hide();
    $('#shipping_rates_section').show();
  } else if ($('#method_select').val() == 'self_pickup') {
    $('#shipping_rates_section').show();
    $('#address_section').show();
  } else {
    $('#shipping_rates_section').hide();
    $('#address_section').hide();
  }
});

$('#method_select').change();
