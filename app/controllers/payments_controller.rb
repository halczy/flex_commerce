class PaymentsController < ApplicationController
  before_action :verify_params, only: [ :alipay_return ]

  def alipay_return
    payment = Payment.find(params[:id])
    payment.update(processor_response_return: request.query_parameters.to_json)
    payment_service = PaymentService.new(payment_id:  payment.id)
    if payment_service.alipay_confirm
      redirect_to success_order_path(id: payment.order.id,
                                     payment_id: payment.id)
    else
      flash[:danger] = 'Unable to confirm your order at the moment.
                        Please contact customer service'
      redirect_to root_url
    end

  end

  private

    def verify_params
      alipay_client = helpers.create_alipay_client
      unless alipay_client.verify?(request.query_parameters)
        flash[:danger] = 'Invalid response from ALIPAY. Please contact customer
                          service.'
        redirect_to root_url
      end
    end
end
