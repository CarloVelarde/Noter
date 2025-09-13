# frozen_string_literal: true
require "securerandom"

class Note

  attr_accessor :id, :content, :created_at, :complete_by

  def initialize(content, complete_by = nil, id: nil, created_at: Time.now)
    @id = id || SecureRandom.uuid
    @content = content
    @created_at = created_at
    @complete_by = complete_by
  end

  def to_h
    {
      "id" => @id,
      "content" => @content,
      "created_at" => @created_at,
      "complete_by" => @complete_by,
    }
  end

  def self.from_h(hash)
    Note.new(
      hash["content"],
      hash["complete_by"],
      id: hash["id"],
      created_at: hash["created_at"]
    )
  end

  def to_json(*args)
    to_h.to_json(*args)
  end
end