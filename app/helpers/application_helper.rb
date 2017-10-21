module ApplicationHelper

  def active?(path)
    "active" if current_page?(path)
  end

  def active_controller?(nav_controller)
    "active" if controller.controller_name.downcase == nav_controller
  end

  def page_title(title = "")
    unless title.empty?
      "#{title} | #{app_title}"
    else
      app_title
    end
  end

  def app_title
    ApplicationConfiguration.get('application_title') ||
    'Flex Commerce'
  end

  def icp_license
    license = ApplicationConfiguration.get('icp_license')
    license.present? ? license : nil
  end

  def admin_controller?(controller)
    controller.controller_path.match?(/admin/)
  end

  def alert_icon(message_type)
    case message_type
    when 'success'
      'fa-check-circle'
    when 'info'
      'fa-info-circle'
    when 'warning'
      'fa-warning'
    when 'danger'
      'fa-exclamation-circle'
    end
  end

end
