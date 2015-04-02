# == Schema Information
#
# Table name: experiences
#
#  id                 :integer          not null, primary key
#  person_id          :string(255)      not null
#  title              :string(255)
#  body               :text
#  video              :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#

class Experience < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :person

  has_attached_file :image, styles: { small: "310x220>", original: "600x800>"}

  def has_media?
    video.present? || image.present?
  end
end
