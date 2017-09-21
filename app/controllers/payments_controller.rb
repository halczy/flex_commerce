class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:alipay_notify]
  before_action :verify_return_params,  only: [ :alipay_return ]
  before_action :verify_notify_params,  only: [ :alipay_notify ]
  after_action  :process_alipay_notify, only: [ :alipay_notify ]

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

  def alipay_notify
    notify_data = request.request_parameters
    logger.info notify_data
    @payment = Payment.find(params[:id])
    @payment.update(processor_response_notify: notify_data.to_json)
    render plain: 'success' if notify_data.present?
  end

  def process_alipay_notify
    payment_service = PaymentService.new(payment_id:  @payment.id)
    payment_service.alipay_confirm
  end

  private

    def verify_return_params
      alipay_client = helpers.create_alipay_client
      unless alipay_client.verify?(request.query_parameters)
        flash[:danger] = 'Invalid response from ALIPAY. Please contact customer
                          service.'
        redirect_to root_url
      end
    end

    def verify_notify_params
      alipay_client = helpers.create_alipay_client
      unless alipay_client.verify?(request.request_parameters)
        render plain: 'fail'
      end
    end
end
