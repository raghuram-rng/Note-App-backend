class Note < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  belongs_to :user
  # include PgSearch::Model
  # pg_search_scope :search_by_title, against: :title
  # pg_search_scope :search_by_content, against: :content
end
