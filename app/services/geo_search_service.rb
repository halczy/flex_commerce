class GeoSearchService < SearchService

  def search
    build('id', 'name')
    Geo.where(where_clause, where_args)
  end

  def full_search
    build('id', 'name', 'parent_id')
    Geo.where(where_clause, where_args)
  end

end
