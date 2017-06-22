module ApplicationHelper

  def active?(path)
    "active" if current_page?(path)
  end

  def page_title
    base_title = 'Flex Commerce'
    if @title
      "#{@title} | #{base_title}"
    else
      base_title
    end
  end

end
