#! /usr/bin/env ruby

require 'optparse'
require 'ostruct'
require_relative 'tail_logic'

class TailCLI
  VERSION = '1.0.0'

  attr_reader :parser, :options, :file

  def initialize
    @options = OpenStruct.new(
      follow: false,
      num_lines: 10,
      bytes: false
    )

    configure_parser
  end

  def parse(args)
    parser.parse!(args)
  end

  def run(args)
    @file = args.pop
    tail = TailLogic.new(file)
    puts tail.read(options[:num_lines], options[:bytes])

    if options[:follow]
      while true
        if tail.file_changed?
          puts tail.read_all
        end
        sleep(1)
      end
    end
  end

  private
  def configure_parser
    @parser = OptionParser.new

    parser.banner = 'Usage: ./tail.rb [options] FILENAME'

    parser.separator ""
    parser.separator "Specific options:"

    # Additional options
    follow_file_option
    lines_number_option
    bytes_option

    parser.separator ""
    parser.separator "Common Options"

    parser.on_tail('-h', '--help', "Show this message") do
      puts parser
      exit
    end

    parser.on("--version", "Show version" ) do |opt|
      puts Tail::VERSION
      exit
    end
  end

  def follow_file_option
    parser.on('-f', '--follow', TrueClass, 'output appended data as the file grows') do |f|
      options.follow = f
    end
  end

  def lines_number_option
    parser.on('-nNUMBER', '--number=NUMBER', Integer, 'specify number of lines to read') do |n|
      options.num_lines = n
    end
  end

  def bytes_option
    parser.on('-b', '--bytes', TrueClass, 'reads the specified number of bytes instead of lines') do |b|
      options.bytes = b
    end
  end

end

cli = TailCLI.new
cli.parse(ARGV)
cli.run(ARGV)
