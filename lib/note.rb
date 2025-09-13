# frozen_string_literal: true

class Note
  def initialize(content, complete_by = nil)
    @content = content
    @created_at = Time.now
    @complete_by = complete_by
  end

  # Getter for content variable
  def content
    @content
  end

  # Setter for content variable
  def content=(content)
    @content = content
  end

  # Getter for created_at variable
  def created_at
    @created_at
  end

  def created_at=(created_at)
    @created_at = created_at
  end

  # Getter for complete_by variable
  def complete_by
    @complete_by
  end

  # Setter for complete_by variable
  def complete_by=(complete_by)
    @complete_by = complete_by
  end

  def to_h
    {
      "content" => @content,
      "created_at" => @created_at,
      "complete_by" => @complete_by,
    }
  end

  def to_json(*args)
    to_h.to_json(*args)
  end

  def self.from_h(hash)
    new_note = Note.new(hash["content"], hash["complete_by"])
    new_note.created_at = hash["created_at"]
    new_note
  end
end