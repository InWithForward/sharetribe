class TestimonialGivenJob < Struct.new(:testimonial_id, :community_id)

  include DelayedExceptionNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have community parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    community = Community.find(community_id)
    testimonial = Testimonial.find(testimonial_id)
    receiver = testimonial.receiver
    author = testimonial.author

    Delayed::Job.enqueue(
      MixpanelTrackerJob.new(receiver.id, community_id, 'Feedback Received', {
        title: testimonial.transaction.listing.title,
        text: testimonial.text,
        grade: testimonial.grade,
        author: author.username
      })
    )

    Delayed::Job.enqueue(
      MixpanelTrackerJob.new(author.id, community_id, 'Feedback Given', {
        title: testimonial.transaction.listing.title,
        text: testimonial.text,
        grade: testimonial.grade,
        receiver: receiver.username
      })
    )

    if receiver.should_receive?("email_about_new_received_testimonials")
      PersonMailer.new_testimonial(testimonial, community).deliver
    end
  end

end
