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
# |     +++ !weather on                                                                 |
# |     +++ !weather off                                                                |
# |                                                                                     |
# | IMPORTANT:                                                                          |
# |                                                                                     |
# | 500 requets per day                                                                 |
# | You need www.worldweatheronline.com Api Key                                         |
# +-------------------------------------------------------------------------------------+

bind PUB - !w weather

package require json
package require http
package require tdom

set weather(api) "5b7f8d8a2bf54ac1865153523162007"

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
	
	if {[catch {http::geturl http://api.worldweatheronline.com/premium/v1/weather.ashx?[http::formatQuery key $weather(api) q [lindex [split $arg] 0] date_format unix format xml]} tok]} {
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
	set XML $data

	set doc [dom parse $XML]
	set root [$doc documentElement]

	## ++ Astronomy
	set sunrise [$root selectNodes weather/astronomy/sunrise]; set sunrise [lindex $sunrise 0]; set sunrise [$sunrise asText]
	set sunset [$root selectNodes weather/astronomy/sunset]; set sunset [lindex $sunset 0]; set sunset [$sunset asText]
	
	set query [$root selectNodes request/query]; set query [$query asText]
	set temp_C [$root selectNodes current_condition/temp_C]; set temp_C [$temp_C asText]
	set FeelsLikeC [$root selectNodes current_condition/FeelsLikeC]; set FeelsLikeC [$FeelsLikeC asText]
	set humidity [$root selectNodes current_condition/humidity]; set humidity [$humidity asText]
	set winddir16Point [$root selectNodes current_condition/winddir16Point]; set winddir16Point [$winddir16Point asText]
	set windspeedKmph [$root selectNodes weather/hourly/windspeedKmph]; set windspeedKmph [lindex [split $windspeedKmph] 0]; set windspeedKmph [$windspeedKmph asText]
	set cloudcover [$root selectNodes weather/hourly/cloudcover]; set cloudcover [lindex [split $cloudcover] 0]; set cloudcover [$cloudcover asText]

	putserv "PRIVMSG $chan :\002$query\002 -- \00302Temperaturã\003: \00304$temp_C °C\003 (\00305Se simt ca: \00304$FeelsLikeC °C\003) \002\037/\037\002 \00302Umiditate\003: \00304$humidity %\003 \002\037/\037\002 \00302Vânt\003: \00304$winddir16Point\003 @ \00304$windspeedKmph km/h\003 \002\037/\037\002 \00302Acoperire nori\003: \00304$cloudcover %. \00302Astronomie\003 (Rasarit: \00304$sunrise\003 \002\037/\037\002 Apus: \00304$sunset\003)"

	$root delete
}

putlog "Succesfully loaded: \00303Weather TCL Script"
