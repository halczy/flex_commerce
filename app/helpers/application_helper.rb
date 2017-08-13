module ApplicationHelper

  def active?(path)
    "active" if current_page?(path)
  end

  def active_controller?(nav_controller)
    "active" if controller.controller_name.downcase == nav_controller
  end

  def page_title(title = "")
    application_title = 'Flex Commerce'
    unless title.empty?
      "#{title} | #{application_title}"
    else
      application_title
    end
  end

  def admin_controller?(controller)
    controller.controller_path.match?(/admin/)
  end

  def link_to_add_fields(name, f, association, options={})
    new_object = f.object.class.reflect_on_association(association).klass.new

    fields = f.fields_for(association,
        new_object,
        :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end

    link_to_function(name,
      h("add_fields(this,
        \"#{association}\", \"#{escape_javascript(fields)}\"); return false;"),
        class: 'btn btn-success mb-5')
  end

  def link_to_function(name, js, opts={})
    link_to name, '#', opts.merge({onclick: js})
  end

end
