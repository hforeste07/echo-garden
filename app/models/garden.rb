# == Schema Information
#
# Table name: gardens
#
#  id         :bigint           not null, primary key
#  columns    :integer
#  favorite   :boolean          default(FALSE), not null
#  name       :string
#  rows       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_gardens_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
# app/models/garden.rb
class Garden < ApplicationRecord
  belongs_to :user
  has_many :garden_plots, dependent: :destroy

  after_create :generate_plots
  after_create :set_default_favorite, if: -> { user.gardens.count == 1 }

  def generate_plots
    rows.times do |r|
      columns.times do |c|
        garden_plots.create!(row: r, column: c)
      end
    end
  end

  def set_default_favorite
    update(favorite: true)
  end

  def mark_as_favorite
    # Make this the only favorite for the user
    user.gardens.update_all(favorite: false)
    update(favorite: true)
  end
end
