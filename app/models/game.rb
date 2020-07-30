class Game < ApplicationRecord
  belongs_to :started_by, :class_name => 'Player', optional: true
  belongs_to :winner, :class_name => 'Player', optional: true
  has_and_belongs_to_many :players
  has_and_belongs_to_many :questions

end
