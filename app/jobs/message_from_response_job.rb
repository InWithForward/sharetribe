class MessageFromResponseJob < Struct.new(:params)

  def perform
    decoded = Maybe(params["MailboxHash"])
      .map { |h| Base64.decode64(h) }
      .map { |j| JSON.parse(j) }
      .get

    conversation = Conversation.find(decoded['c'])
    sender = Person.find(decoded['s'])

    message = Message.new(
      content: params["TextBody"],
      conversation: conversation,
      sender: sender
    )

    message.save!

    Delayed::Job.enqueue(
      MessageSentJob.new(message.id, conversation.community.id)
    )
  end

end
