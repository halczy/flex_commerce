function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  $(link).prev().append(content.replace(regexp, new_id));
  return false;
}
