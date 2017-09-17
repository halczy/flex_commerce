module ApplicationHelper

  def active?(path)
    "active" if current_page?(path)
  end

  def active_controller?(nav_controller)
    "active" if controller.controller_name.downcase == nav_controller
  end

  def page_title(title = "")
    application_title = ApplicationConfiguration.
                          find_by(name: 'application_title').try(:plain) ||
                        'Flex Commerce'

    unless title.empty?
      "#{title} | #{application_title}"
    else
      application_title
    end
  end

  def admin_controller?(controller)
    controller.controller_path.match?(/admin/)
  end

  def alert_icon(message_type)
    case message_type
    when 'success'
      'fa-check-circle'
    when 'warning'
      'fa-warning'
    when 'danger'
      'fa-exclamation-circle'
    end
  end

end
