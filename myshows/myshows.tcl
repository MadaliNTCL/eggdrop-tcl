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

			set temp(canceled) ""; set temp(running) ""

			foreach line $result {
				if {[string match -nocase *ended* [dict get $line status]]} { lappend temp(canceled) "\00304[dict get $line id]\003 - \00313[dict get $line titleOriginal]" }
				if {[string match -nocase *returning* [dict get $line status]]} { lappend temp(running) "\00312[dict get $line id]\003 - \00303[dict get $line titleOriginal]" }
			}

			putserv "PRIVMSG $chan :\002Running\002: [join $temp(running) ", "]"
			putserv "PRIVMSG $chan :\002Canceled/Ended\002: [join $temp(canceled) ", "]"
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

	putserv "PRIVMSG $chan :\00312[dict get [dict get $connect result] titleOriginal]\003 \037\002/\002\037 \00302Status: \00304[dict get [dict get $connect result] status]\003 \037\002/\002\037 \00302Total Season: \00303\002[dict get [dict get $connect result] totalSeasons]\002\003 - \00306https://en.myshows.me/view/[dict get [dict get $connect result] id]/"
	putserv "PRIVMSG $chan :\00302Premiered\003: \00303[dict get [dict get $connect result] started]\003 - \00304\002[dict get [dict get $connect result] ended]\002\003 \037\002/\002\037 \00302Rating: \00304[dict get [dict get $connect result] rating]\003 (Votes: \00304[dict get [dict get $connect result] voted]\003) \037\002/\002\037 \00302Watchers: \00304[dict get [dict get $connect result] watching]\003 \037\002/\002\037 \00302Country: \00304[dict get [dict get $connect result] country]\003"

	# ++ Next episode
	set nextepisode [lindex $temp(episode-list) 0]; set date [lindex [string map [list "T" " " "+0000" ""] [dict get $nextepisode airDate]] 0]
													set final [duration [expr [unixtime] - [clock scan $date]]]
													

	putserv "PRIVMSG $chan :\002#1\002 \00302next episode"
	putserv "PRIVMSG $chan :\00304[dict get $nextepisode shortName]\003 - \00312[dict get $nextepisode title]\003 airs in \002$final\002 (\00312$date\003)"

	# ++ Last 3 episodes
	set 1 [lindex $temp(episode-list) 1]; set date1 [lindex [string map [list "T" " " "+0000" ""] [dict get $1 airDate]] 0]; set final1 [duration [expr [unixtime] - [clock scan $date1]]]
	set 2 [lindex $temp(episode-list) 2]; set date2 [lindex [string map [list "T" " " "+0000" ""] [dict get $2 airDate]] 0]; set final2 [duration [expr [unixtime] - [clock scan $date2]]]
	set 3 [lindex $temp(episode-list) 3]; set date3 [lindex [string map [list "T" " " "+0000" ""] [dict get $3 airDate]] 0]; set final3 [duration [expr [unixtime] - [clock scan $date3]]]

	putserv "PRIVMSG $chan :\002#3\002 \00302last episodes"
	putserv "PRIVMSG $chan :\00304[dict get $1 shortName]\003 - \00312[dict get $1 title]\003 aired $final1 ago (\00312$date1\003)"
	putserv "PRIVMSG $chan :\00304[dict get $2 shortName]\003 - \00312[dict get $2 title]\003 aired $final2 ago (\00312$date2\003)"
	putserv "PRIVMSG $chan :\00304[dict get $3 shortName]\003 - \00312[dict get $3 title]\003 aired $final3 ago (\00312$date3\003)"
}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303MyShows\003 \]"
