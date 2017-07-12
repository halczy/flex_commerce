module CategoriesHelper

  def parent_count(category)
    parent_count = 0
    until category.parent.nil?
      category = category.try(:parent)
      parent_count += 1 if category
    end
    return parent_count
  end

end
