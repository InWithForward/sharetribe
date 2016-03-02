class PersonImagesController < ApplicationController

  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token, :only => [:destroy]

  before_filter :fetch_image, :only => [:destroy]

  def destroy
    @person_image_id = @person_image.id.to_s
    if @person_image.destroy
      render nothing: true, status: 204
    else
      render json: {:errors => person_image.errors.full_messages}, status: 400
    end
  end

  # Add new person image to existing person
  # Create image from given url
  def add_from_url
    url = escape_s3_url(params[:path], params[:filename])

    if !url.present?
      render json: {:errors => "No image URL provided"}, status: 400, content_type: 'text/plain'
    end

    add_image(params[:person_id], {}, url)
  end

  # Add new person image to existing person
  # Create image from uploaded file
  def add_from_file
    add_image(params[:person_id], params[:person_image], nil)
  end

  # Return image status and thumbnail url
  def image_status
    person_image = PersonImage.find_by_id(params[:id])

    if !person_image
      render nothing: true, status: 404
    else
      render json: PersonImageJSAdapter.new(person_image).to_json, status: 200
    end
  end

  private

  # Given path which includes placeholder `${filename}` and
  # the `filename` and get back working URL
  def escape_s3_url(path, filename)
    escaped_filename = AWS::Core::UriEscape.escape(filename)
    path.sub("${filename}", escaped_filename)
  end

  def add_image(person_id, params, url)
    person_image_params = params.merge(person_id: person_id)

    new_image(person_image_params, url)
  end

  # Create a new image object
  def new_image(params, url)
    person_image = PersonImage.new(params)

    person_image.image_downloaded = if url.present? then false else true end

    if person_image.save
      unless person_image.image_downloaded
        person_image.delay.download_from_url(url)
      end
      render json: PersonImageJSAdapter.new(person_image).to_json, status: 202, content_type: 'text/plain' # Browsers without XHR fileupload support do not support other dataTypes than text
    else
      render json: {:errors => person_image.errors.full_messages}, status: 400, content_type: 'text/plain'
    end
  end

  def fetch_image
    @person_image = PersonImage.find_by_id(params[:id])
  end
end
