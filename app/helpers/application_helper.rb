module ApplicationHelper

  def active?(path)
    "active" if current_page?(path)
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
    admin_controllers = [ 'dashboard', 'categories' ]
    admin_controllers.include?(controller.controller_name.downcase)
  end

end
