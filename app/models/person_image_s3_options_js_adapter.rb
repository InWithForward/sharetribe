class PersonImageS3OptionsJSAdapter < JSAdapter

  def initialize(person)
    s3uploader = S3Uploader.new

    if ApplicationHelper.use_upload_s3?
      @s3_upload_path = s3uploader.url
      @s3_fields = s3uploader.fields
    end

    @save_from_file = person.new_record? ? add_from_file_person_images_path : add_from_file_person_person_images_path(person.id)
    @save_from_url = person.new_record? ? add_from_url_person_images_path : add_from_url_person_person_images_path(person.id)
    @max_image_filesize = APP_CONFIG.max_image_filesize
    @original_image_width = APP_CONFIG.original_image_width
    @original_image_height = APP_CONFIG.original_image_height
    @namespace = 'person_image'
  end

  def to_hash
    HashUtils.camelize_keys(HashUtils.object_to_hash(self), false)
  end
end
