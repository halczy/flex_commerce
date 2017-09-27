class SearchService
  attr_reader :where_clause, :where_args, :search_term

  def initialize(search_term)
    @where_clause = ""
    @where_args = {}
    @search_term = search_term.strip
  end

  def build_clause(field_name)
    "CAST(#{field_name} AS TEXT) ILIKE :#{field_name}"
  end

  def build_args
    "%" + @search_term + "%"
  end

  def build(*args)
    raise ArgumentError if args.empty?
    args.each do |field_name|
      @where_clause << " OR " unless @where_clause.empty?
      @where_clause << build_clause(field_name)
      @where_args[:"#{field_name}"] = build_args
    end
  end
end
