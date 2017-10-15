class Admin::TransferController < Admin::AdminController

  def index
    @transfers = Transfer.all
  end

end
