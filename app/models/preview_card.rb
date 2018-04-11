# frozen_string_literal: true
# == Schema Information
#
# Table name: preview_cards
#
#  id                 :integer          not null, primary key
#  url                :string           default(""), not null
#  title              :string           default(""), not null
#  description        :string           default(""), not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  type               :integer          default("link"), not null
#  html               :text             default(""), not null
#  author_name        :string           default(""), not null
#  author_url         :string           default(""), not null
#  provider_name      :string           default(""), not null
#  provider_url       :string           default(""), not null
#  width              :integer          default(0), not null
#  height             :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  embed_url          :string           default(""), not null
#

class PreviewCard < ApplicationRecord
  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze
  LIMIT = 1.megabytes

  self.inheritance_column = false

  enum type: [:link, :photo, :video, :rich]

  has_and_belongs_to_many :statuses

  has_attached_file :image, styles: { original: { geometry: '400x400>', format: 'jpg', file_geometry_parser: FastGeometryParser } }, convert_options: { all: '-quality 80 -strip' }

  include Attachmentable

  validates :url, presence: true, uniqueness: true
  validates_attachment_content_type :image, content_type: IMAGE_MIME_TYPES
  validates_attachment_size :image, less_than: LIMIT
  remotable_attachment :image, LIMIT

  before_save :extract_dimensions, if: :link?

  def save_with_optional_image!
    save!
  rescue ActiveRecord::RecordInvalid
    self.image = nil
    save!
  end

  private

  def extract_dimensions
    file = image.queued_for_write[:original]

    return if file.nil?

    width, height = FastImage.size(file.path)

    return nil if width.nil?

    self.width  = width
    self.height = height
  end
end
