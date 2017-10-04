class CustomerSearchService < SearchService

  def search
    build('id', 'name', 'member_id', 'cell_number', 'email')
    Customer.where(where_clause, where_args).order(updated_at: :desc)
  end

end
