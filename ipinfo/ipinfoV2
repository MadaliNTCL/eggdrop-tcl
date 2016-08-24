# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         IP Info v2.0.0                                              |
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
# |     +++ !ip on                                                                      |
# |     +++ !ip off                                                                     |
# |     +++ !ip 192.12.4.12                                                             |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+

bind PUBM - * ip:main

set temp(trigger) {! . `}

package require http
package require tdom

setudef flag ip

proc ip:main {nick uhost hand chan arg} {
	global temp

	if {[string index $arg 0] in $temp(trigger)} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]
		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	if {[info commands command:$temp(cmd)] ne ""} { command:$temp(cmd) $nick $uhost $hand $chan $arg }
}

proc command:ip {nick uhost hand chan arg} {
	global top temp

	set ip [lindex [split $arg] 0]

	switch -exact -- [lindex [split $arg] 0] {
		on {
			if {[matchattr $hand n]} {
				channel set $chan +ip

				putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306+ip\0032 on \00304$chan"
			}
		}
		off {
			if {[matchattr $hand n]} {
				channel set $chan -ip

				putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306-ip\0032 on \00304$chan"
			}
		}
		default {
			if {![channel get $chan ip]} { return }
			
			if {![regexp {^(?:(?:[01]?\d?\d|2[0-4]\d|25[0-5])(\.|$)){4}$} $ip]} { putserv "PRIVMSG $chan :$nick NO/Invalid IP pattern. USAGE: !ip 123.4.56.7"; return }

			if {[catch {http::geturl "http://ip-api.com/json/$ip"} tok]} {
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

			set connect [http::data $tok]
			set connect [json::json2dict $connect]
			
			set code [dict get $connect countryCode]

			set country [dict get $connect country]

			set regionname [dict get $connect region]

			set city [dict get $connect city]

			set org [dict get $connect org]

			putserv "PRIVMSG $chan :\00302Informations about \00304$arg\00302: Country Code - \00312$code\00302 \037\002/\002\037\00302 Country Name - \00303$country\003 \037\002/\002\037\00302 Region Name - \00310$regionname\003 \037\002/\002\037\00302 City - \00312$city\003 \037\002/\002\037\00302 Organization - \00306$org\003"
		}
	}
}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303IPinfo\003 \]"
