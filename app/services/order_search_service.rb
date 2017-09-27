class OrderSearchService < SearchService

  def search
    @result = []
    search_in_order
    search_in_user
    @result.flatten
  end

  def search_in_order
    build('id')
    @result << Order.where(where_clause, where_args)
  end

  def search_in_user
    build('id', 'name', 'email', 'cell_number', 'member_id')
    User.where(where_clause, where_args).each do |user|
      @result << user.orders
    end
  end


end
