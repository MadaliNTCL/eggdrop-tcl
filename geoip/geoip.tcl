# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         GEOIp Script v1.0.0                                       |
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
# |     +++ !top country                                                                |
# |     +++ !top city                                                                   |
# |     +++ !geoip on/off                                                               |
# |                                                                                     |
# | IMPORTANT                                                                           |
# | - .chanset #channel +geoip (dcc chat)                                               |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+

bind JOIN - * geoip
bind PUBM - * geoip:main

bind TIME - "00 14 * * *" geoip:routine
bind TIME - "00 20 * * *" geoip:routine
bind TIME - "00 23 * * *" geoip:routine

set temp(trigger) {! . `}

package require http
package require tdom

setudef flag geoip

proc geoip:main {nick uhost hand chan arg} {
	global temp

	if {[string index $arg 0] in $temp(trigger)} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]
		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	if {[info commands geoip:$temp(cmd)] != ""} { geoip:$temp(cmd) $nick $uhost $hand $chan $arg }
}

proc geoip:geoip {nick uhost hand chan arg} {

	switch -exact -- [lindex [split $arg] 0] {
		on {
			if {[matchattr $hand n]} {
				channel set $chan +geoip
				
				putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306+geoip\0032 on \00304$chan"
			}
		}
		off {
			if {[matchattr $hand n]} {
				channel set $chan -geoip
				
				putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306-geoip\0032 on \00304$chan"
			}
		}		
	}
}
	
proc geoip:top {nick uhost hand chan arg} {
	global top temp

	if {[isvoice $nick $chan] || [isop $nick $chan] && [channel get $chan geoip]} {
		switch -exact -- [lindex [split $arg] 0] {
			tara -
			country {
				switch -exact -- [lindex [split $arg] 1] {
					today { geoip:parse country today $chan $nick }
					weekly { geoip:parse country weekly $chan $nick }
					monthly { geoip:parse country monthly $chan $nick }
					anually { geoip:parse country anually $chan $nick }
					total { geoip:parse country total $chan $nick }
					default { geoip:parse country total $chan $nick }
				}
			}
			oras -
			city {
				switch -exact -- [lindex [split $arg] 1] {
					today { geoip:parse city today $chan $nick }
					weekly { geoip:parse city weekly $chan $nick }
					monthly { geoip:parse city monthly $chan $nick }
					anually { geoip:parse city anually $chan $nick }
					total { geoip:parse city total $chan $nick }
					default { geoip:parse city total $chan $nick }
				}
			}
		}
	}
}

proc geoip:parse {{one ""} {two ""} {three ""} {four ""}} {
	global top temp

	switch -exact -- $two {
		today { set temp(type) 0 }
		weekly { set temp(type 1 }
		monthly { set temp(type) 2 }
		anually { set temp(type) 3}
		total { set temp(type) 4 }
		default { set temp(type) 4 }
	}

	switch -exact -- $one {
		country {

			set temp(list) ""; set temp(tdisplay) ""

			foreach n [array names top $three,$one,*] { lappend temp(list) "[list [lindex [split $n ,] 2] [lindex [split $top($n)] $temp(type)]]" }

			set temp(list) [lsort -integer -decreasing -index 1 $temp(list)]

			set place 0

			foreach x $temp(list) {
				incr place

				set country [join [lrange $x 0 0]]
				set times [join [lrange $x 1 1]]

				if {$country != "" && $times != ""} {
					lappend temp(tdisplay) "\00312\002#$place\002 \00304$country \00310$times\003"
				}
			}

			set temp(td) [join [lrange $temp(tdisplay) 0 9]]

			if {$temp(td) == ""} { putserv "PRIVMSG $three :\002$four\002 - There are no informations yet, please try again later."; return }

			putserv "PRIVMSG $three :\002$four\002 - TOP $one: $two = $temp(td)"
		}
		city {
			set temp(list) ""
			set temp(tdisplay) ""

			foreach n [array names top $three,$one,*] {
				lappend temp(list) "[list [lindex [split $n ,] 2] [lindex [split $top($n)] 4] [lindex [split $top($n)] 5]]"
			}

			set temp(list) [lsort -integer -decreasing -index 1 $temp(list)]

			set place 0

			foreach x $temp(list) {
				incr place

				set country [join [lrange $x 0 0]]
				set times [join [lrange $x 1 1]]
				set code [join [lrange $x 2 2]]

				if {$country != "" && $times != "" && $code != ""} {
					lappend temp(tdisplay) "\00312\002#$place\002 \00304$country\003 (\00312$code\003) \00310$times\003"
				}
			}

			set temp(td) [join [lrange $temp(tdisplay) 0 9]]

			if {$temp(td) == ""} { putserv "PRIVMSG $three :\002$four\002 - There are no informations yet, please try again later."; return }

			putserv "PRIVMSG $three :\002$four\002 - TOP $one: $two = $temp(td)"
		}
	}
}

proc geoip {nick uhost hand chan} {
	global top temp ignoreit

	if {[isbotnick $nick]} { return }
	if {[string match -nocase *users* [lindex [split $uhost @] 1]]} { return }
	if {[info exists ignoreit($chan,[lindex [split $uhost @] 1])]} { return }
	if {![info exists ignoreit($chan,[lindex [split $uhost @] 1])]} { set ignoreit($chan,[lindex [split $uhost @] 1]) "[unixtime]"; geoip:save }

	set token [http::config -useragent Mozilla]
	set token [http::geturl "http://freegeoip.net/xml/[lindex [split $uhost @] 1]"]
	set data [::http::data $token]
	::http::cleanup $token

	set XML $data

	set doc [dom parse $XML]

	set root [$doc documentElement]

	set country [$root selectNodes CountryName]
	set country [$country asText]

	set code [$root selectNodes CountryCode]
	set code [$code asText]

	set city [$root selectNodes City]
	set city [$city asText]

	if {$country == "" || $code == "" || $city == ""} { return }

	if {![info exists top($chan,country,$country)]} { set top($chan,country,$country) "1 1 1 1 1 $nick [lindex [split $uhost @] 1] [unixtime]"; geoip:save } else { set top($chan,country,$country) "[expr [lindex [split $top($chan,country,$country)] 0] +1] [expr [lindex [split $top($chan,country,$country)] 1] +1] [expr [lindex [split $top($chan,country,$country)] 2] +1] [expr [lindex [split $top($chan,country,$country)] 3] +1] [expr [lindex [split $top($chan,country,$country)] 4] +1] $nick [lindex [split $uhost @] 1] [unixtime]"; geoip:save }
	if {![info exists top($chan,city,$city)]} { set top($chan,city,$city) "1 1 1 1 1 $code $nick [lindex [split $uhost @] 1] [unixtime]"; geoip:save } else { set top($chan,city,$city) "[expr [lindex [split $top($chan,city,$city)] 0] +1] [expr [lindex [split $top($chan,city,$city))] 1] +1] [expr [lindex [split $top($chan,city,$city))] 2] +1] [expr [lindex [split $top($chan,city,$city)] 3] +1] [expr [lindex [split $top($chan,city,$city)] 4] +1] $code $nick [lindex [split $uhost @] 1] [unixtime]"; geoip:save }
}

proc geoip:check {what chan} {
	global top

	switch -exact -- $what {
		tara -
		country {
			set temp(list) ""
			set temp(tdisplay) ""

			foreach n [array names top $chan,country,*] { lappend temp(list) "[list [lindex [split $n ,] 2] [lindex [split $top($n)] 4]]" }

			set temp(list) [lsort -integer -decreasing -index 1 $temp(list)]

			foreach x $temp(list) { return "[join [lrange $x 0 0]]" }
		}
		oras -
		city {
			set temp(list) ""
			set temp(tdisplay) ""

			foreach n [array names top $chan,city,*] { lappend temp(list) "[list [lindex [split $n ,] 2] [lindex [split $top($n)] 4]]" }

			set temp(list) [lsort -integer -decreasing -index 1 $temp(list)]

			foreach x $temp(list) { return "[join [lrange $x 0 0]]" }
		}
		ccountry { set nr 0; foreach n [array names top $chan,country,*] { incr nr }; return $nr }
		ccity { set nr 0; foreach n [array names top $chan,city,*] { incr nr }; return $nr }
	}
}

proc geoip:routine {min hour day month year} {

	foreach n [channels] {
		if {[channel get $n geoip]} {
			if {[geoip:check ccountry $n] == 0} { return }
			putserv "PRIVMSG $n :The most active users who visited \002$n\002 are from country \00312[geoip:check country $n]\003 and city \00304[geoip:check city $n]\003 accumulating a total of \00305[geoip:check ccountry $n]\003 countries and \00305[geoip:check ccity $n]\003 cities that have visited this channel so far."
		}
	}
}

proc geoip:save {} {
	global top ignoreit

	set nfw [open geoip w]
	puts $nfw "array set top [list [array get top]]"
	puts $nfw "array set ignoreit [list [array get ignoreit]]"
	close $nfw
}

catch {source geoip}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303GEOip\003 \]"
