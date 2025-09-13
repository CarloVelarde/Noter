# frozen_string_literal: true
require 'json'
require 'optparse'

require_relative "lib/note"
require_relative "lib/tool"

# ------ CLI -------

global = { "path" => "./notebook.json" }

global_parser = OptionParser.new do |o|
  o.banner = <<~HEREDOC
    Usage guide:
      noter add    [options] "NOTE TEXT"   # add a note
      noter list   [options]               # list notes
      noter delete [options] ID            # delete a note

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

when "delete"
  delete_parser = OptionParser.new do |o|
    o.banner = "Usage: noter delete [--path FILE] ID"

    o.on("-p", "--path FILE", "Path to JSON file") {|v| global["path"] = v }
    o.on("-h", "--help") { puts o; exit }
  end

  # Removes known options and leaves positional arguments (the id in this case)
  delete_parser.parse!(ARGV)

  # Get the ID from the argument list
  id = ARGV.first
  if id.nil?
    warn "Error: NOTE ID required.\n\n#{delete_parser}"
    exit 1
  end

  tool = Tool.new(global["path"])
  if tool.delete_note(id)
    puts "Deleted note with ID: #{id}"
  else
    puts "No note found with ID: #{id}"
    exit 1
  end

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
    puts "#{i + 1}. (#{note.id}) #{note.content}. Due by- #{note.complete_by != nil ? note.complete_by : "N/A"}"
  end
else
  puts global_parser
  exit 1
end

