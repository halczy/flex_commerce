class ProductSearchService < SearchService

  def quick_search
    build('name', 'tag_line')
    Product.where(where_clause, where_args).order(updated_at: :desc)
  end

end
