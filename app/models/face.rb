# frozen_string_literal: true

class Face < ApplicationRecord
  # Concerns
  include Strippable
  strip :text

  # Relationships
  belongs_to :cube
end
