class Db

    def initialize
        $sess_o = 1
    end

    $s1_exists = lambda do |inp=0|
        File.open(%Q{session-1.txt}, "w")
        meth_call = inp.downcase.split[0]
        obj = Db.new
        obj.public_send(meth_call, inp)
    end

    # Set [name][value] to database
    def set(inp)
        # Check if any db already exists
        if File.exist?("session-1.txt")
            inp = inp.split #['SET', 'A', '10']
            File.open(%Q{session-#{$sess_o}.txt}, "r") do |f|
                $ary = f.readlines
            end
                # Check if passed [name] already exists if so, rewrite it
                if $ary.map { |l| l.include?(inp[1]) }
                    $ary = $ary.reject { |l| l.include?(inp[1]) }
                    File.open(%Q{session-#{$sess_o}.txt}, "w") do |f|
                        # Rewrite the [name] and put back the rest of the data
                        f.write($ary.join)
                        f.write("\n #{inp[1]} #{inp[2].to_i} ")
                    end
                else
                    # If passed argument [name] doesn't exist, just add it to the db
                    File.open(%Q{session-#{$sess_o}.txt}, "a+") do |f|
                        f.write("\n #{inp[1]} #{inp[2].to_i} ")
                    end
                end 
        else
            # if there is no db already, create one and call set method
            File.open(%Q{session-1.txt}, "w") do |f|
                inp = inp.split
                f.write("\n #{inp[1]} #{inp[2].to_i} ")
            end
        end
    end

    def get(inp)
        if File.exists?("session-1.txt")
            inp = inp.split #['GET', 'A']
            File.open(%Q{session-#{$sess_o}.txt}, "r") do |f|
                $ar = f.read().split("\n") # [' a 10 ', ' b 20 ']
            end
            $ar = $ar.map(&:strip) # ['a 10', 'b 20']
            $ar = $ar.map(&:split) # [['a', '10'], ['b', '20']]
            $ar = $ar.flatten # ['a', '10', 'b', '20']
            # check if there is any [name] (inp[1]) = A in that case
            if $ar.include?(inp[1])
                $ar.each_with_index do |value, index| 
                    if value == inp[1]
                        puts $ar[index+1]
                    end
                end
            else
                # if not puts NULL
                puts "NULL"
            end
        else 
            $s1_exists.call(inp)
        end
    end

    def delete(inp)
        if File.exists?("session-1.txt")
            inp = inp.split #['DELETE', 'A']
            File.open(%Q{session-#{$sess_o}.txt}, "r") do |f|
                $ary = f.readlines
            end
            # check if there is any value assigned to inp[1] (name)
            if $ary.map { |l| l.include?(inp[1]) }
                $ary = $ary.reject { |l| l.include?(inp[1]) }
                File.open(%Q{session-#{$sess_o}.txt}, "w") do |f|
                    f.write($ary.join)
                end
            else
                puts "NULL"
            end
        else
            $s1_exists.call(inp)
        end
    end

    def count(inp)
        if File.exists?("session-1.txt")
            inp = inp.split #['COUNT', '10']
            # if file.read include inp[1]
            File.open(%Q{session-#{$sess_o}.txt}, "r") do |f|
                $ar_c = f.read()
            end
            $ar_c = $ar_c.split("\n").map(&:strip).map(&:split).flatten
            if $ar_c.count(inp[1]) == 0
                puts "NULL"
            else
                puts $ar_c.count(inp[1])
                # count same values
                # else retrurn 'NULL'
            end
        else
            $s1_exists.call(inp)
        end
    end

    # save the session you're in atm, delete the rest
    def commit
        if File.exists?("session-1.txt")
            $sess_o = 1
            x = Dir["**/*"].length-2
            y = Dir["**/*"].length-1
            for i in 1..x
                #$f.close()
                File.delete(%Q{./session-#{i}.txt})
            end
            File.rename("session-#{y}.txt", "session-1.txt")
            #$f.close()
        else
            puts "There are no files to commit"
        end
    end

    # create new session
    def begin_sess
        if Dir["**/*"].length-1 == 0
            $f = File.open(%Q{session-#{Dir["**/*"].length}.txt}, "w")
            $f.close()
        else
            $sess_o = Dir["**/*"].length
            $f = File.open(%Q{session-#{$sess_o}.txt}, "a+")
            $f.close()
        end
    end

    # close and delete the session you're in atm and go back to previous one
    def rollback
        if File.exists?("session-1.txt")
            if File.exist?(%Q{./session-#{Dir["**/*"].length-1}.txt})
                $sess_o = $sess_o - 1
                if $f.class == File
                    $f.close()
                    File.delete(%Q{./session-#{Dir["**/*"].length-1}.txt})
                    $f = File.open(%Q{./session-#{Dir["**/*"].length-1}.txt}, "a+")
                    $f.close()
                else
                    puts "NO TRANSACTION"
                end
            else
                puts "NO TRANSACTION"
                if $f != nil
                    $f.close()
                    File.delete(%Q{./session-#{Dir["**/*"].length-2}.txt})
                else
                    File.delete(%Q{./session-#{Dir["**/*"].length-2}.txt})
                end
            end
        else
            puts "There is no session to rollback, open some and try again!"
        end
    end

    # open session [number]
    def open_sess(inp) # OPEN SESSION 4
        inp = inp.split # ['open', 'session', '4']
        if File.exist?("session-#{inp[2]}.txt")
            if $f != nil
                $sess_o = inp[2].to_i
                $f = File.open(%Q{./session-#{inp[2]}.txt}, "a+")
                $f.close()
            else
                $sess_o = inp[2].to_i
                $f = File.open(%Q{./session-#{inp[2]}.txt}, "a+")
                $f.close()
            end
        else
            puts "There is no file number #{inp[2]} to open."
        end
    end

    # draw a graph command 
    # args: array of sessions (max 4), elements to compare (max 3), 100% - x?
    def draw_gph(ar, unit)
        if File.exists?("session-1.txt")

            $ar_values = []
            
            ar.each do |i|
                self.open_sess("OPEN SESSION #{i}")
                $ar_values << self.get("GET #{unit}")
            end

            $ar_values = $ar_values.flatten.reject do |x|
                x == nil || x.to_i == 0
            end

            $ar_values = $ar_values.map(&:to_i)

            #array block background
            g_back = []
            # left column (heigh)

            15.times do 
                g_back.push ((" " * 20).split("").unshift("*"))
                #["*"," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "]
            end

            b_bottom = ("*" * 21).split("")
            g_back.unshift b_bottom

            # drawing lambda (placing 'a', 'o', 'e' on graph)
            graph_data = lambda do |x, l, i, z=0|
                for y in 1..i 
                    g_back[y][x] = l
                end

                if z != 0
                    for m in 0..z
                        m = "+"
                        g_back[y+1][x] = m
                    end
                end
            end

            # use lambda for each value of arrya of values
            # and asign the args (x,l,i and z if requeired)
            #p $ar_values
            $ar_values.each_with_index do |v,ind|
                z = 0 
                if v % 2 == 0
                    i = v / 2
                else
                    i = v / 2 
                    z = v % 2
                end
                x = ind + 2
                case x
                when 2
                    l = "a"
                when 3
                    l = "o"
                when 4
                    l = "e"
                else 
                    l = "ERROR"
                end
                graph_data.call(x,l,i,z)
            end

            #reverse graph
            g_back = g_back.reverse

            #printing graph
            g_back.each {|x| puts x.join(" ")}

            #some info about graph
            puts ""
            puts "'aoe' = 2 units"
            puts "'+' = 1 unit"
            puts ""
            puts "Session number:#{ar[0]} | Value: #{$ar_values[0]} - a"
            puts "Session number:#{ar[1]} | Value: #{$ar_values[1]} - o"
            puts "Session number:#{ar[2]} | Value: #{$ar_values[2] == nil ? "No value" : $ar_values[2]} - e"
            puts ""
        else
            puts "There is no data and files to draw a graph from, create some and try again!"
        end
    end

    # deletes the session with numer inp[2]
    def delete_sess(inp) # "DELETE SESSION 2"
        if File.exists?("session-#{inp.split[2]}.txt")
            inp = inp.split
            if File.exist?(%Q{./session-#{inp[2]}.txt})
                $sess_o == inp[2] ? $sess_o = $sess_o - 1 : $sess_o
                File.delete(%Q{./session-#{inp[2]}.txt})
                $f = File.open(%Q{./session-#{$sess_o}.txt}, "a+")
                $f.close()
                puts "Session #{inp[2]} deleted!"
            else
                puts "NO TRANSACTION"
            end
        else
            puts "There is no session #{inp.split[2]}"
        end
    end

    # deletes array of sessions
    def delete_multiply(ar_sess)
            if File.exists?("session-1.txt")
                puts "Are you sure, you want to delete sessions #{ar_sess}, [y/n]:"
                agree = gets.chomp
                if agree == "y"
                    ar_sess.each do |sess|
                        #$f.close
                        self.delete_sess(%Q{delete session #{sess}})
                    end
                    puts "#{File.basename($f)} renamed to session-1.txt"
                    $sess_o = Dir["**/*"].length-1
                    File.rename(File.basename($f), %Q{./session-1.txt})
                end
            else
                puts "Looks like you missed few files, you can't delete them if they don't exist!"
            end
    end

    # get all values in the session
    def get_all
        if File.exists?("session-#{$sess_o}.txt")
            File.open(%Q{session-#{$sess_o}.txt}) do |f|
                ggeter = f.readlines.map(&:split)
                ggeter = ggeter.reject(&:empty?).map { |x| x.join(" = ")}
                puts ggeter
            end 
        else
            puts "There is no file or data to get values from. Creat some and try agian!"
        end
    end
end 