
     
113 lines (93 sloc)  5.23 KB
# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         Weather Script v1.0.0                                       |
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
# |     +++ !w on                                                                       |
# |     +++ !w off                                                                      |
# |     +++ !w <city>                                                                   |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+

bind PUB - !w weather

package require json
package require http
package require tdom

set weather(api) "59264c8c829cbcd87204931c232b8ae5"

setudef flag weather

proc weather {nick uhost hand chan arg} {
	global weather wignore
	
	switch -exact -- [lindex [split $arg] 0] {
		on {
			if {[isop $nick $chan]} {
				channel set $chan +weather
				
				putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306+weather\0032 on \00304$chan"
			}
		}
		off {
			if {[isop $nick $chan]} {
				channel set $chan -weather
				
				putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306-weather\0032 on \00304$chan"
			}
		}		
	}
	
	if {![channel get $chan weather]} { return }
	
	## ++
	set floodtime 10

	## ++ 
	if {![info exists wignore($nick)]} {
		set wignore($nick) [unixtime]
		utimer $floodtime [list unset -nocomplain wignore($nick)]
	}

	## ++ 
	if {[expr [unixtime]-$wignore($nick)]>$floodtime} { putlog "ignoram"; return 0 }
	
	if {[catch {http::geturl http://api.openweathermap.org/data/2.5/weather?[http::formatQuery q [lindex [split $arg] 0] appid $weather(api) lang ro units metric]} tok]} {
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
	http::cleanup $tok
	set parse [::json::json2dict $data]

	set sunrise [clock format [join [dict get $parse sys sunrise]] -format "%H:%M"]
	set sunset [clock format [join [dict get $parse sys sunset]] -format "%H:%M"]
	set query [join [dict get $parse sys country]]
	set temp_C [join [dict get $parse main temp]]
	set humidity [join [dict get $parse main humidity]]
	set windspeedKmph [join [dict get $parse wind speed]]
	set cloudcover [join [dict get $parse clouds all]]
	set dt [duration [expr [unixtime] - [dict get $parse dt]]]
	set clouds [dict get [lindex [dict get $parse weather] 0] description]
	
	putserv "PRIVMSG $chan :\002$arg, $query\002 -- \00302Temperature\003: \00304$temp_C °C\003 \002\037/\037\002 \00302Humidity\003: \00304$humidity %\003 \002\037/\037\002 \00302Wind speed\003: \00304$windspeedKmph km/h\003 \002\037/\037\002 \00302Cloud cover\003: \00304$cloudcover % (\00305$clouds). \00302Astronomy\003 (Sunrise: \00304$sunrise\003 \002\037/\037\002 Sunset: \00304$sunset\003) - \00302Last update: \00304$dt"
}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303Weather\003 \]"
