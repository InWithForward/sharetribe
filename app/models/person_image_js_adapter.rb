class PersonImageJSAdapter < JSAdapter
  ASPECT_RATIO = 3/2.to_f

  def initialize(person_image)
    @id = person_image.id
    @person_id = person_image.person_id
    @ready = !person_image.image_processing && person_image.image_downloaded;
    @images = {
      thumb: person_image.image.url(:thumb),
      big: person_image.image.url(:big)
    }
    @urls = {
      remove: person_image_path(person_image.id),
      status: image_status_person_image_path(person_image)
    }
    @aspect_ratio = if person_image.correct_size? ASPECT_RATIO
        "correct-ratio"
      elsif person_image.too_narrow? ASPECT_RATIO
        "too-narrow"
      else
        "too-wide"
      end
  end

  #json style hash with camelized keys
  def to_hash
    hash = HashUtils.object_to_hash(self)
    HashUtils.camelize_keys(hash)
  end
end
