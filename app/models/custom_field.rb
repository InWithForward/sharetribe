# == Schema Information
#
# Table name: custom_fields
#
#  id                     :integer          not null, primary key
#  type                   :string(255)
#  sort_priority          :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  community_id           :integer
#  required               :boolean          default(TRUE)
#  min                    :float
#  max                    :float
#  allow_decimals         :boolean          default(FALSE)
#  for                    :string(255)      default("Listing"), not null
#  visible                :boolean          default(TRUE), not null
#  key                    :string(255)
#  display_on_transaction :boolean          default(FALSE)
#  editable               :boolean          default(TRUE), not null
#
# Indexes
#
#  index_custom_fields_on_community_id  (community_id)
#

class CustomField < ActiveRecord::Base
  include SortableByPriority # use `sort_priority()` for sorting

  attr_accessible(
    :type,
    :name_attributes,
    :category_attributes,
    :role_attributes,
    :option_attributes,
    :sort_priority,
    :required,
    :min,
    :max,
    :for,
    :visible,
    :key,
    :display_on_transaction,
    :editable
  )

  has_many :names, :class_name => "CustomFieldName", :dependent => :destroy

  has_many :category_custom_fields, :dependent => :destroy
  has_many :categories, :through => :category_custom_fields

  has_many :role_custom_fields, :dependent => :destroy
  has_many :roles, :through => :role_custom_fields

  has_many :answers, :class_name => "CustomFieldValue", :dependent => :destroy

  has_many :options, :class_name => "CustomFieldOption"

  belongs_to :community

  VALID_TYPES = ["TextField", "NumericField", "DropdownField", "CheckboxField","DateField", "TextAreaField", 'VideoField']

  validates_length_of :names, :minimum => 1
  validates_length_of :category_custom_fields, :minimum => 1, if: :for_listing?
  validates_presence_of :community

  def self.for_roles(roles)
    includes(:role_custom_fields).
      where(role_custom_fields: { role_id: roles.map(&:id) })
  end

  def name_attributes=(attributes)
    build_attrs = attributes.map { |locale, value| {locale: locale, value: value[:value], hint: value[:hint] } }
    build_attrs.each do |name|
      if existing_name = names.find_by_locale(name[:locale])
        existing_name.update_attribute(:value, name[:value])
        existing_name.update_attribute(:hint, name[:hint])
      else
        names.build(name)
      end
    end
  end

  def category_attributes=(attributes)
    category_custom_fields.clear
    attributes.each { |category| category_custom_fields.build(category) }
  end

  def role_attributes=(attributes)
    role_custom_fields.clear
    attributes.each { |role| role_custom_fields.build(role) }
  end

  def name(locale="en")
    TranslationCache.new(self, :names).translate(locale, :value)
  end

  def hint(locale="en")
    TranslationCache.new(self, :names).translate(locale, :hint)
  end

  def can_filter?
    # Default to false
    false
  end

  def with(expected_type, &block)
    with_type do |own_type|
      if own_type == expected_type
        block.call
      end
    end
  end

  def with_type(&block)
    throw "Implement this in the subclass"
  end

  def for_listing?
    self.for == Listing.to_s
  end

  def for_person?
    self.for == Person.to_s
  end

end
