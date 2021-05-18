# frozen_string_literal: true

# Class comment
class Session
  # save the session you're in at the moment, delete the rest of sessions
  def commit
    if File.exist?('session-1.txt')
      $sess_o = 1
      x = Dir['**/*'].length - 2
      y = Dir['**/*'].length - 1
      (1..x).each do |i|
        File.delete(%(./session-#{i}.txt))
      end
      File.rename("session-#{y}.txt", 'session-1.txt')
    else
      puts 'There are no files to commit'
    end
  end

  # create new session
  def begin_sess
    if (Dir['**/*'].length - 1).zero?
      $f = File.open(%(session-#{Dir['**/*'].length}.txt), 'w')
      $f.close
    else
      $sess_o = Dir['**/*'].length
      $f = File.open(%(session-#{$sess_o}.txt), 'a+')
      $f.close
    end
  end

  # close and delete the session you're in at the moment and go back to previous one
  def rollback
    if File.exist?('session-1.txt')
      if File.exist?(%(./session-#{Dir['**/*'].length - 1}.txt))
        $sess_o = $sess_o - 1
        if $f.instance_of?(File)
          $f.close
          File.delete(%(./session-#{Dir['**/*'].length - 1}.txt))
          $f = File.open(%(./session-#{Dir['**/*'].length - 1}.txt), 'a+')
          $f.close
        else
          puts 'NO TRANSACTION'
        end
      else
        puts 'NO TRANSACTION'
        if !$f.nil?
          $f.close
          File.delete(%(./session-#{Dir['**/*'].length - 2}.txt))
        else
          File.delete(%(./session-#{Dir['**/*'].length - 2}.txt))
        end
      end
    else
      puts 'There is no session to rollback, open some and try again!'
    end
  end

  # open session [number]
  # OPEN SESSION 4
  def open_sess(inp)
    inp = inp.split # ['open', 'session', '4']
    if File.exist?("session-#{inp[2]}.txt")
      if !$f.nil?
        $sess_o = inp[2].to_i
        $f = File.open(%(./session-#{inp[2]}.txt), 'a+')
        $f.close
      else
        $sess_o = inp[2].to_i
        $f = File.open(%(./session-#{inp[2]}.txt), 'a+')
        $f.close
      end
    else
      puts "There is no file number #{inp[2]} to open."
    end
  end

  # deletes the session with no. inp[2]
  # "DELETE SESSION 2"
  def delete_sess(inp)
    if File.exist?("session-#{inp.split[2]}.txt")
      inp = inp.split
      if File.exist?(%(./session-#{inp[2]}.txt))
        $sess_o == inp[2] ? $sess_o = $sess_o - 1 : $sess_o
        File.delete(%(./session-#{inp[2]}.txt))
        $f = File.open(%(./session-#{$sess_o}.txt), 'a+')
        $f.close
        puts "Session #{inp[2]} deleted!"
      else
        puts 'NO TRANSACTION'
      end
    else
      puts "There is no session #{inp.split[2]}"
    end
  end

  # deletes array of sessions
  def delete_multiply(ar_sess)
    if File.exist?('session-1.txt')
      puts "Are you sure, you want to delete sessions #{ar_sess}, [y/n]:"
      agree = gets.chomp
      if agree == 'y'
        ar_sess.each do |sess|
          delete_sess(%(delete session #{sess}))
        end
        puts "#{File.basename($f)} renamed to session-1.txt"
        $sess_o = Dir['**/*'].length - 1
        File.rename(File.basename($f), './session-1.txt')
      end
    else
      puts %(Looks like you missed few files, you can't delete them if they don't exist!)
    end
  end
end
