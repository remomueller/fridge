# frozen_string_literal: true

class Tray < ApplicationRecord
  # Concerns
  include Strippable
  strip :name

  # Relationships
  has_many :cubes, -> { order(:position) }
end
