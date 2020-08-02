class Question < ApplicationRecord
  belongs_to :trivium
  has_many :choice1
  has_many :choice2
  has_many :choice3
  has_many :choice4
end
