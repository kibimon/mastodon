# == Schema Information
#
# Table name: accounts
#
#  id                      :integer          not null, primary key
#  username                :string           default(""), not null
#  domain                  :string
#  secret                  :string           default(""), not null
#  private_key             :text
#  public_key              :text             default(""), not null
#  remote_url              :string           default(""), not null
#  salmon_url              :string           default(""), not null
#  hub_url                 :string           default(""), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  note                    :text             default(""), not null
#  display_name            :string           default(""), not null
#  uri                     :string           default(""), not null
#  url                     :string
#  avatar_file_name        :string
#  avatar_content_type     :string
#  avatar_file_size        :integer
#  avatar_updated_at       :datetime
#  header_file_name        :string
#  header_content_type     :string
#  header_file_size        :integer
#  header_updated_at       :datetime
#  avatar_remote_url       :string
#  subscription_expires_at :datetime
#  silenced                :boolean          default(FALSE), not null
#  suspended               :boolean          default(FALSE), not null
#  locked                  :boolean          default(FALSE), not null
#  header_remote_url       :string           default(""), not null
#  statuses_count          :integer          default(0), not null
#  followers_count         :integer          default(0), not null
#  following_count         :integer          default(0), not null
#  last_webfingered_at     :datetime
#  inbox_url               :string           default(""), not null
#  outbox_url              :string           default(""), not null
#  shared_inbox_url        :string           default(""), not null
#  followers_url           :string           default(""), not null
#  protocol                :integer          default("ostatus"), not null
#  memorial                :boolean          default(FALSE), not null
#  moved_to_account_id     :integer
#  featured_collection_url :string
#  fields                  :jsonb
#  owner_id                :integer
#  species_id              :integer
#  type                    :string           default("ActivityMon::Trainer")
#  mon_no                  :integer          not null
#  route_regional_no       :integer          not null
#  route_national_no       :integer          not null
#  trainer_no              :integer          not null
#

class ActivityMon::Mon < Account
  belongs_to :owner, class_name: 'ActivityMon::Trainer', optional: true
  belongs_to :species, class_name: 'ActivityMon::Species', optional: true

  # Specific №s
  validates :mon_no, uniqueness: true, allow_nil: true
  validates :mon_no, presence: true, unless: :new_record?
  validates :route_regional_no, absence: true
  validates :route_national_no, absence: true
  validates :trainer_no, absence: true

  # Dex information
  delegate :regional_no,
    :national_no, to: :species, prefix: false, allow_nil: true

  # Trainer information
  delegate :username,
    :trainer_no, to: :owner, prefix: true, allow_nil: true

  def owned?
    !owner.nil?
  end

  def mon?
    true
  end

  def username=(ignored)
    nil
  end

  def username
    return "mon_#{mon_no}"
  end

  before_save :not_a_route!
  before_save :not_a_trainer!
  before_save :is_a_mon!

  private

  def is_a_mon!
    self.mon_no = nil if mon_no.nil?
  end
end