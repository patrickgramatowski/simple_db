# Simple Database built with Ruby 2.7
## Introduction
Simple database class built with Ruby.
### Usage
Create a instance of the Db class
<code>
db = Db.new
then you are free to use whole bunch of methods e.g.
db.set("SET A 10)" # => sets A 10
db.get("GET A") # => 10
db.count("COUNT 10") # => counts amount of values 10 in that case it'd be 1
db.delete("DELETE A") # => deletes A if we do db.get("GET A") # => NULL
db.begin_sess # creates a session (session-[number].txt file)
db.rollback # => deletes the session and opens the previous one
db.open_sess("OPEN SESSION 2") # => opens session-2.txt
db.commit # => deletes all the files beside the file we're in, changes the name of the file to session-1
db.delete_sess("DELETE SESSION 2") # => deletes session-2
db.delete_multiply([1,2,3]) # => deletes array of sessions, needs to confirm it
db.draw_gph([1,2,3], "A") # => draws a graph which includes all values of "A" (in that case) from sessions [1,2,3] and represents it as a graph
NOTE draw_gph take just an array of 3 sessions and 1 variable e.g. ("A")!
</code>

draw_gph method example
<code>
db = Db.new
db.set("SET A 10")
db.begin_sess
db.set("SET A 11")
db.begin_sess
db.set("SET A 12")

db.draw_gph([1,2,3], "A") # =>

*
*
*
*
*
*
*
*
*
*     + e
*   a o e
*   a o e
*   a o e
*   a o e
*   a o e
* * * * * * * * * * * * * * * * * * * * *

'aoe' = 2 units
'+' = 1 unit

Session number:1 | Value: 10 - a
Session number:2 | Value: 11 - o
Session number:3 | Value: 12 - e</code>
