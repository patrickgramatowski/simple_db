# frozen_string_literal: true

require_relative '../session'

# Databse class
class Db
  def initialize
    @session = Session.new
    $sess_o = 1
  end

  def method_missing(m, *args)
    if @session.respond_to?(m)
      @session.send(m, *args)
    else
      puts "There is no such method #{m}"
    end
  end

  $s1_exists = lambda do |inp = 0|
    File.open(%(session-1.txt), 'w')
    meth_call = inp.downcase.split[0]
    obj = Db.new
    obj.public_send(meth_call, inp)
  end

  # Set [name][value] to database
  def set(inp)
    # Check if any db already exists
    if File.exist?('session-1.txt')
      inp = inp.split # ['SET', 'A', '10']
      File.open(%(session-#{$sess_o}.txt), 'r') do |f|
        $ary = f.readlines
      end
      # Check if passed [name] already exists if so, rewrite it
      if $ary.map { |l| l.include?(inp[1]) }
        $ary = $ary.reject { |l| l.include?(inp[1]) }
        File.open(%(session-#{$sess_o}.txt), 'w') do |f|
          # Rewrite the [name] and put back the rest of the data
          f.write($ary.join)
          f.write("\n #{inp[1]} #{inp[2].to_i} ")
        end
      else
        # If passed argument [name] doesn't exist, just add it to the db
        File.open(%(session-#{$sess_o}.txt), 'a+') do |f|
          f.write("\n #{inp[1]} #{inp[2].to_i} ")
        end
      end
    else
      # if there is no db already, create one and call set method
      File.open(%(session-1.txt), 'w') do |f|
        inp = inp.split
        f.write("\n #{inp[1]} #{inp[2].to_i} ")
      end
    end
  end

  def get(inp)
    if File.exist?('session-1.txt')
      inp = inp.split # ['GET', 'A']
      File.open(%(session-#{$sess_o}.txt), 'r') do |f|
        $ar = f.read.split("\n") # [' a 10 ', ' b 20 ']
      end
      $ar = $ar.map(&:strip) # ['a 10', 'b 20']
      $ar = $ar.map(&:split) # [['a', '10'], ['b', '20']]
      $ar = $ar.flatten # ['a', '10', 'b', '20']
      # check if there is any [name] (inp[1]) = A in that case
      if $ar.include?(inp[1])
        $ar.each_with_index do |value, index|
          puts $ar[index + 1] if value == inp[1]
        end
      else
        # if not puts NULL
        puts 'NULL'
      end
    else
      $s1_exists.call(inp)
    end
  end

  def delete(inp)
    if File.exist?('session-1.txt')
      inp = inp.split # ['DELETE', 'A']
      File.open(%(session-#{$sess_o}.txt), 'r') do |f|
        $ary = f.readlines
      end
      # check if there is any value assigned to inp[1] (name)
      if $ary.map { |l| l.include?(inp[1]) }
        $ary = $ary.reject { |l| l.include?(inp[1]) }
        File.open(%(session-#{$sess_o}.txt), 'w') do |f|
          f.write($ary.join)
        end
      else
        puts 'NULL'
      end
    else
      $s1_exists.call(inp)
    end
  end

  def count(inp)
    if File.exist?('session-1.txt')
      inp = inp.split # ['COUNT', '10']
      # if file.read include inp[1]
      File.open(%(session-#{$sess_o}.txt), 'r') do |f|
        $ar_c = f.read
      end
      $ar_c = $ar_c.split("\n").map(&:strip).map(&:split).flatten
      if $ar_c.count(inp[1]).zero?
        puts 'NULL'
      else
        puts $ar_c.count(inp[1])
        # count same values
        # else retrurn 'NULL'
      end
    else
      $s1_exists.call(inp)
    end
    $ar_c.count(inp[1]) || 0
  end

  # Get all values in the session
  def take_all
    if File.exist?("session-#{$sess_o}.txt")
      File.open("session-#{$sess_o}.txt") do |f|
        ggeter = f.readlines.map(&:split)
        ggeter = ggeter.reject(&:empty?).map { |x| x.join(' = ') }
        puts ggeter
      end
    else
      puts 'There is no file or data to get values from. Creat some and try agian!'
    end
  end
end
