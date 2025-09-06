require 'json'
require 'optparse'

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

# ------ CLI -------

global = { "path" => "./notebook.json" }

global_parser = OptionParser.new do |o|
  o.banner = <<~HEREDOC
    Usage guide:
      noter add    [options] "NOTE TEXT"   # add a note
      noter list   [options]               # list notes

    Global options:
  HEREDOC

  o.on("-p", "--path FILE", "Path to JSON file that stores the notes (default: ./notebook.json)") { |v| global["path"] = v }
  o.on("-h", "--help", "Show this help") { puts o; exit }
end

cmd = ARGV.shift

case cmd
when "add"
  options = { "complete_by" => nil }
  add_parser = OptionParser.new do |o|
    o.banner = "Usage: noter add [-c DATE] [--path FILE] \"NOTE TEXT\""

    o.on("-c", "--complete-by DATE", "Set due date") { |v| options["complete_by"] = v }
    o.on("-p", "--path FILE", "Path to JSON file")    { |v| global["path"] = v }
    o.on("-h", "--help") { puts o; exit }
  end
  # Removes known options and leaves positional arguments (the note in this case)
  add_parser.parse!(ARGV)

  note_text = ARGV.join(" ").strip
  # Check if note was provided
  if note_text.empty?
    warn "Error: NOTE TEXT required.\n\n#{add_parser}"
    exit 1
  end

  tool = Tool.new(global["path"])
  tool.create_note(note_text, options["complete_by"])
  # Practicing ternary (if complete_by was given then print it, else print nothing)
  puts "Added: #{note_text}#{options["complete_by"] ? " (due #{options["complete_by"]})" : ""}"

when "list"
  options = {"time_created" => false}
  list_parser = OptionParser.new do |o|
    o.banner = "Usage: noter list [-t] [--path FILE]"

    o.on("-t", "--time-created", "List by time created") {options["time_created"] = true }
    o.on("-p", "--path FILE", "Path to JSON file") { |v| global["path"] = v }
    o.on("-h", "--help") { puts o; exit }
  end
  # Removes known options and leaves positional arguments (the note in this case)
  list_parser.parse!(ARGV)

  tool = Tool.new(global["path"])
  notes = tool.fetch_notes

  if notes.empty?
    puts "No notes found."
    exit 0
  end
  # Sort notes by time created if flag was set
  notes.sort_by! {|note| note.created_at} if options["time_created"]

  notes.each.with_index do |note, i|
    puts "#{i + 1}. #{note.content}. Due by #{note.complete_by ? note.complete_by : ""}"
  end
else
  puts global_parser
  exit 1
end

