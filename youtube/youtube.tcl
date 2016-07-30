# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         YouTUBE Script v1.0.0                                       |
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
# |     [ OP - PUBLIC]                                                                  |
# |     +---------------+                                                               |
# |                                                                                     |
# |     +++ !youtube on                                                                 |
# |     +++ !youtube off                                                                |
# |                                                                                     |
# | IMPORTANT:                                                                          |
# |                                                                                     |
# | 500 requets per day                                                                 | 
# | You need Google Api Key                                                             |
# +-------------------------------------------------------------------------------------+

bind PUBM - * youtube
bind PUBM - * youtube:pubm

package require json
package require http
package require tls

set youtube(api) "AIzaSyDxNwsjQz_ESuj2D8TnREIKvkTarPGlyaA"

setudef flag youtube

proc youtube:pubm {nick uhost hand chan arg} {
	global temp

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]
		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	if {[info commands ytpubm:$temp(cmd)] ne ""} { ytpubm:$temp(cmd) $nick $uhost $hand $chan $arg }
}

proc ytpubm:youtube {nick uhost hand chan arg} {

	switch -exact -- [lindex [split $arg] 0] {
		on {
			if {[isop $nick $chan]} {
				channel set $chan +youtube
				
				putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306+youtube\0032 on \00304$chan"
			}
		}
		off {
			if {[isop $nick $chan]} {
				channel set $chan -youtube
				
				putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306-youtube\0032 on \00304$chan"
			}
		}		
	}
}
proc youtube {nick uhost hand chan arg} {
	global ytignore youtube

	if {![channel get $chan youtube]} { return 0 }	
	if {![string match -nocase *yout* $arg]} { return 0 }

	## ++
	set floodtime 10

	## ++ 
	if {![info exists ytignore($nick)]} {
		set ytignore($nick) [unixtime]
		utimer $floodtime [list unset -nocomplain ytignore($nick)]
	}

	## ++ 
	if {[expr [unixtime]-$ytignore($nick)]>$floodtime} { putlog "ignoram"; return 0 }

	set youtubecheck [regexp -all -nocase {(?:\/watch\?v=|youtu\.be\/)([\d\w-]{11})} $arg match youtubeid]
	
	::http::register https 443 ::tls::socket

	if {[catch {http::geturl "https://www.googleapis.com/youtube/v3/videos?[http::formatQuery id $youtubeid key $youtube(api) part snippet,contentDetails,statistics,status]"} tok]} {
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
	
	set playtime [lindex [dict get [lindex [dict get $parse items] 0] snippet] 1]
	set title [lindex [dict get [lindex [dict get $parse items] 0] snippet] 5]
	set viewCount [lindex [dict get [lindex [dict get $parse items] 0] statistics] 1]
	set likeCount [lindex [dict get [lindex [dict get $parse items] 0] statistics] 3]
	set dislikeCount [lindex [dict get [lindex [dict get $parse items] 0] statistics] 5]
	set commentCount [lindex [dict get [lindex [dict get $parse items] 0] statistics] 9]

	putserv "PRIVMSG $chan :\002\00301,00You\00300,04Tube\002\017 \00312$title\003 \037\002/\002\037 \00302Views\003: \00303[youtube:convert $viewCount]\003 \037\002/\002\037 \00302Likes\003: \00310[youtube:convert $likeCount]\003 \037\002/\002\037 \00302Dislikes\003: \00304[youtube:convert $dislikeCount]\003 \037\002/\002\037 \00302Comments\003: \00304[youtube:convert $commentCount]\003"
}

proc youtube:convert {num} { while {[regsub {^([-+]?\d+)(\d\d\d)} $num "\\1.\\2" num]} {}; return $num }

putlog "Succesfully loaded: \00303YouTUBE TCL Script."
