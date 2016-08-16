# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         iMDB v1.0.0                                                 |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# | *** Website             @  http://www.EggdropTCL.com                                |
# | *** GitHub              @  http://github.com/MadaliNTCL/eggdrop-tcl                 |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+
# | *** IRC Support:                                                                    |
# |                    #EggdropTCL     @ QuakeNET                                       |
# |                    #EggdropTCL     @ UnderNET                                       |
# |                    #EggdropTCL     @ EfNET                                          |
# |                                                                                     |
# | *** Contact:                                                                        |
# |                    Yahoo Messenger/Mail: madalinmen28@yahoo.com                     |
# |                    Google Mail         : madalinmen28@gmail.com                     |
# |                    Skype Messenger     : madalinmen28                               |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+
# + *** Commands ***                                                                    |
# |     +---------------+                                                               |
# |     [ OP - PUBLIC   ]                                                               |
# |     +---------------+                                                               |
# |                                                                                     |
# |     +++ !imdb <on/off>                                                              |
# +-------------------------------------------------------------------------------------+

bind PUBM - * imdb

package require json
package require http
package require tdom

setudef flag imdb

proc imdb {nick uhost hand chan arg} {
	global imdb iignore
	
	switch -exact -- [lindex [split $arg] 0] {
		on {
			if {[isop $nick $chan]} {
				channel set $chan +imdb
				
				putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306+imdb\0032 on \00304$chan"
			}
		}
		off {
			if {[isop $nick $chan]} {
				channel set $chan -imdb
				
				putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306-imdb\0032 on \00304$chan"
			}
		}		
	}
	
	if {![string match *imdb* $arg]} { return 0 }
	if {![channel get $chan imdb]} { return }
	
	## ++
	set floodtime 10

	## ++ 
	if {![info exists iignore($nick)]} {
		set iignore($nick) [unixtime]
		utimer $floodtime [list unset -nocomplain iignore($nick)]
	}

	## ++ 
	if {[expr [unixtime]-$iignore($nick)]>$floodtime} { putlog "ignoram"; return 0 }
	
	regexp -all -nocase {(tt[0-9]{7})} $arg match imdbid
	putlog $imdbid
	if {[catch {http::geturl http://www.omdbapi.com/?[http::formatQuery i $imdbid]} tok]} {
		putlog "Socket error: $tok"
		return 0
	}
	if {[http::status $tok] ne "ok"} {
		set status [http::status $tok]
		
		putlog "TCP error: $status"
		return 0
	}
	if {[http::ncode $tok] != 200} {
		set code [http::code $tok]
		http::cleanup $tok

		putlog "HTTP Error: $code"
		return 0
	}

	set data [http::data $tok]

	set parse [::json::json2dict $data]

	set year [dict get $parse Year]
	set title [dict get $parse Title]
	set runtime [dict get $parse Runtime]
	set genre [dict get $parse Genre]
	set rating [dict get $parse imdbRating]
	set votes [dict get $parse imdbVotes]
	set plot [dict get $parse Plot]
	set awards [dict get $parse Awards]

	putserv "PRIVMSG $chan :\0031,8\002iMDB\002\003 - \00312$title\003 \037\[\037$runtime ($year)\037\]\037 \037\002/\002\037 \00306$genre\003 \037\002/\002\037 \002$rating\002 (\00302Votes\003: \00304$votes\003) \037\002/\002\037 Plot: \00310$plot\003 \037\002/\002\037 \00302Awards\003: \00304$awards"
}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303iMDB\003 \]"
