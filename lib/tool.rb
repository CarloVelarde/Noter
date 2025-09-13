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

  def delete_note(id)
    notes = fetch_notes
    size_before_delete = notes.size
    notes.reject! { |note| note.id == id }

    # Check if note was actually deleted
    deleted = notes.size < size_before_delete

    # If deleted, update json file with deleted note
    if deleted
      # convert back to hashes before saving
      data = notes.map {|note| note.to_h}
      File.write(@path, JSON.pretty_generate(data))
    end

    deleted
  end

  # Fetches notes from json file and returns an array of Note objects
  def fetch_notes
    data = load_data
    # Creates a list of 'Note' objects
    data.map {|note| Note.from_h(note)}
  end

  # (Helper) Returns the raw Ruby Array of Hashes from the json file
  def load_data
    # Create notebook if it does not exist
    File.write(@path, "[]") unless File.exist?(@path)
    raw = File.read(@path)
    # If file is empty, return empty array, else return array with values
    raw.empty? ? [] : JSON.parse(raw)
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

end