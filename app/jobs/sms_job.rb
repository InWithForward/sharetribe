class SmsJob < Struct.new(:to, :from, :body)

  def perform
    Twilio::REST::Client.new.messages.create(
      to: to,
      from: from || APP_CONFIG.twilio_from,
      body: body
    )
  end

end
