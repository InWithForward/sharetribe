class CreateTrelloCardJob < Struct.new(:booking_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    community = Community.where(id: community_id).first
    booking = Booking.where(id: booking_id).first

    destination = booking.transaction.listing.location.address
    guest = booking.transaction.starter

    transport_needed = guest.
      custom_field_values.
      where(custom_fields: { key: :transport_needed }).
      first

    selected_option = Maybe(transport_needed).
      selected_options.
      first

    return unless selected_option.is_some? && selected_option.get.title == "Yes"

    card = Trello.post('/cards', {
      name: destination,
      desc: "#{guest.full_name}\n #{guest.phone_number}",
      pos: "top",
      due: booking.start_at,
      idList: Trello::BOARD_ID
    })

    # Trello.post("/cards/#{card['id']}/attachments", {
    #   url: "https://www.google.com/maps/dir/#{pickup_address}/#{destination}"
    # })

    Trello.post("/cards/#{card['id']}/attachments", {
      url: Rails.application.routes.url_helpers.person_url(
        host: community.domain,
        locale: :en,
        id: guest.username
      )
    })

    checklist = Trello.post("/cards/#{card['id']}/checklists", {
      name: 'Checklist'
    })

    Trello.post("/cards/#{card['id']}/checklist/#{checklist['id']}/checkItem", {
      name: 'Check Google Maps'
    })

    Trello.post("/cards/#{card['id']}/checklist/#{checklist['id']}/checkItem", {
      name: 'Text Kudoz one hour before pickup'
    })

    Trello.post("/cards/#{card['id']}/checklist/#{checklist['id']}/checkItem", {
      name: 'Enjoy the experience'
    })
  end

end
