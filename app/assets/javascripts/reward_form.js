$('#reward_select').on("change", function() {
  if ($('#reward_select').val() == 'referral') {
    $('#referral_section').show();
  } else {
    $('#referral_section').hide();
  }
});

$('#reward_select').change();
