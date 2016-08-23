# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         MyShows v1.0.0                                              |
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
# |                                                                                     |
# |     +++ !tv <search> [name]                                                         |
# |     +++ !tv [id]                                                                    |
# |                                                                                     |
# | Credits:                                                                            |
# |                                                                                     |
# |     +++ war10ck                                                                     |
# +-------------------------------------------------------------------------------------+

bind PUBM - * myshows

package require json
package require http
package require tls

proc myshows {nick uhost hand chan arg} {
	global temp

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]
		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	if {[info commands myshows:$temp(cmd)] ne ""} { myshows:$temp(cmd) $nick $uhost $hand $chan $arg }
}

proc myshows:tv {nick uhost hand chan arg} {

	switch -exact -- [lindex [split $arg] 0] {
		search {
			#set arg [string map [list " " "%20"] $arg]

			::http::register https 443 [list ::tls::socket -tls1 1]

			http::config -accept "application/json" -useragent "Mozilla/5.0 (X11;Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0"

			if {[catch {
					set token [http::geturl "https://api.myshows.me/v2/rpc/" \
						-timeout 10000 \
						-method POST \
						-query "\{\"jsonrpc\": \"2.0\", \"method\":\"shows.Search\", \"params\": \{\"query\": \"[join [lrange $arg 1 end]]\"\}, \"id\": 1\}" \
						-type "application/json"]
				} err]} {
				putquick "PRIVMSG $chan :Something went wrong ($err)."; return 0
			}

			set connect [http::data $token]
			set connect [json::json2dict $connect]

			set result [dict get $connect result]

			set temp(canceled) ""; set temp(running) ""; set temp(pause) ""

			foreach line $result {
				if {[string match -nocase *TBD* [dict get $line status]]} { lappend temp(pause) "\00304[dict get $line id]\003 - \00306[dict get $line titleOriginal]" }				
				if {[string match -nocase *ended* [dict get $line status]]} { lappend temp(canceled) "\00304[dict get $line id]\003 - \00306[dict get $line titleOriginal]" }
				if {[string match -nocase *returning* [dict get $line status]]} { lappend temp(running) "\00312[dict get $line id]\003 - \00303[dict get $line titleOriginal]" }
			}

			if {$temp(running) ne ""} { putquick "PRIVMSG $chan :\002Running\002: [join $temp(running) ", "]" }
			if {$temp(pause) ne ""} { putquick "PRIVMSG $chan :\002Pause\002: [join $temp(pause) ", "]" }						
			if {$temp(canceled) ne ""} { putquick "PRIVMSG $chan :\002Canceled/Ended\002: [join $temp(canceled) ", "]" }
			
			if {$temp(running) ne "" || $temp(pause) ne "" || $temp(canceled) ne ""} { putquick "PRIVMSG $chan :\002$nick\002 - You can now see informations using command \00306!tv \00304id" }
			
			if {$result eq ""} { putquick "PRIVMSG $chan :\002$nick\002 - Nothing found"; return }
		}
		default {
			if {[isnumber [lindex [split $arg] 0]]} { shows.GetById $chan [lindex [split $arg] 0]; return}

			putquick "PRIVMSG $chan :\002$nick\002 - \002USAGE\002: !tv <search/\[\$id\]> \[\$name\]"
		}
	}
}

proc shows.GetById {chan id} {

	::http::register https 443 [list ::tls::socket -tls1 1]

	http::config -accept "application/json" -useragent "Mozilla/5.0 (X11;Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0"

	if {[catch {
			set token [http::geturl "https://api.myshows.me/v2/rpc/" \
				-timeout 10000 \
				-method POST \
				-query "\{\"jsonrpc\": \"2.0\", \"method\": \"shows.GetById\", \"params\": \{\"showId\": \"$id\"\}, \"id\": 1\}" \
				-type "application/json"]
		} err]} {
		putquick "PRIVMSG $chan :Something went wrong ($err)."; return 0
	}
	set connect [http::data $token]
	set connect [json::json2dict $connect]

	set temp(episode-list) [dict get [dict get $connect result] episodes]

	putquick "PRIVMSG $chan :\00312[dict get [dict get $connect result] titleOriginal]\003 \037\002/\002\037 \00302Status: \00304[dict get [dict get $connect result] status]\003 \037\002/\002\037 \00302Total Season: \00303\002[dict get [dict get $connect result] totalSeasons]\002\003 - \00306https://en.myshows.me/view/[dict get [dict get $connect result] id]/"
	putquick "PRIVMSG $chan :\00302Premiered\003: \00303[dict get [dict get $connect result] started]\003 - \00304\002[dict get [dict get $connect result] ended]\002\003 \037\002/\002\037 \00302Rating: \00304[dict get [dict get $connect result] rating]\003 (Votes: \00304[dict get [dict get $connect result] voted]\003) \037\002/\002\037 \00302Watchers: \00304[dict get [dict get $connect result] watching]\003 \037\002/\002\037 \00302Country: \00304[dict get [dict get $connect result] country]\003"

	set temp(next5) ""; set temp(last5) ""

	foreach episode $temp(episode-list) {
		if {![string match -nocase [dict get $episode airDate] "null"]} { set airDate [expr [clock scan [string map [list "T" " " "+0000" ""] [dict get $episode airDate]]] - [unixtime]] }
		set shortName [dict get $episode shortName]
		set title [dict get $episode title]

		putlog "$airDate -- $shortName -- $title"
		if {![string match -nocase *-* $airDate]} {
			lappend temp(next5) "[list $airDate $shortName $title]"
		} else {
			lappend temp(last5) "[list $airDate $shortName $title]"
		}
	}

	set lsortnext [lsort -index 0 -integer -increasing $temp(next5)]
	set lsortlast [lsort -index 0 -integer -decreasing $temp(last5)]

	set next 0; set last 0

	foreach line $lsortnext {
		incr next

		if {$next <= "3"} { putquick "PRIVMSG $chan :\002\037\[\002\037NexT\037\002\]\037\002 \00302Name\003: \00312[lindex $line 2]\003 - \00304[lindex $line 1]\003 airs in \00303[convert:myshows [duration [lindex $line 0]]]" }
	}

	foreach line $lsortlast {
		incr last

		set airDate [string map [list "-" ""] [lindex $line 0]]
		if {$last <= "3"} { putquick "PRIVMSG $chan :\002\037\[\002\037LasT\037\002\]\037\002 \00302Name\003: \00312[lindex $line 2]\003 - \00304[lindex $line 1]\003 aired \00303[convert:myshows [duration $airDate]] ago" }
	}
}

proc convert:myshows {arg} { return [string map [list " years" "y" " year" "y" " months" "m" " month" "m" " weeks" "w" " week" "w" " days" "d" " day" "d" " hours" "h" " hour" "h" " minutes" "m" " minute" "m" " seconds" "s" " second" "s"] $arg] }

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303MyShows\003 \]"
