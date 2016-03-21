class ReprocessListingImageJob < Struct.new(:listing_image_id, :style)

  include DelayedExceptionNotification

  def perform
    listing_image = ListingImage.find_by_id(listing_image_id)

    listing_image.image.reprocess_without_delay! style.to_sym
  end
end