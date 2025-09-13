# frozen_string_literal: true
require "json"

class Tool

  def initialize(path)
    @path = path
  end

  def create_note(content, complete_by = nil)
    note = Note.new(content, complete_by)
    save_note(note)
    nil
  end

  # (Helper) Saves note to json file
  def save_note(note)
    # Gets the json string
    file_content = File.read(@path)
    # Converts json string to ruby array or hash
    data = JSON.parse(file_content)

    data << note.to_h

    File.write(@path, JSON.pretty_generate(data))
    nil
  end

  # Fetches notes, returns a list of notes represented as strings
  def fetch_notes
    file_content = File.read(@path)
    data = JSON.parse(file_content)
    # Creates a list of 'Note' objects
    data.map {|note| Note.from_h(note)}
  end

end