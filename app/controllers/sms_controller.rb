class SmsController < ActionController::Base

  def accept
    body = params['Body']
    from = params['From']
    p body
    p from
    render nothing: true
  end

end
