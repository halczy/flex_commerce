module CarouselsHelper

  def build_carousel_indicators(image_count)
    indicators_html = ""
    image_count = 1 if image_count == 0
    image_count.times do |n|
      if n == 0
        indicators_html << content_tag(:li, '',
          data: { target: '#carouselIndicators', slide_to: n }, class: 'active') + "\n"
      else
        indicators_html << content_tag(:li, '',
          data: { target: '#carouselIndicators', slide_to: n }) + "\n"
      end
    end
    indicators_html
  end

  def build_carousel_inner(images)
    inner_html = ""
    images = Image.placeholder if images.empty?
    images.each_with_index do |image, idx|
      if idx == 0
        inner_html << content_tag(:div, image_tag(image.image_url(:original), class: 'd-block w-100'), class: "carousel-item active")
      else
        inner_html << content_tag(:div, image_tag(image.image_url(:original), class: 'd-block w-100'), class: "carousel-item")
      end
    end
    inner_html
  end
end
