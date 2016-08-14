# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         Domain Name System v1.0.0                                   |
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
# |     [ USER - PUBLIC ]                                                               |
# |     +---------------+                                                               |
# |                                                                                     |
# |     ++ !dns <ip>                                                                     |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+

bind PUBM - * dns:pubm

proc dns:pubm {nick uhost hand chan arg} {

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]

		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	if {[info commands dns:pubm:$temp(cmd)] ne ""} { dns:pubm:$temp(cmd) $nick $uhost $hand $chan $arg }
}

proc dns:pubm:dns {nick host hand chan arg} {
	global temp

	set output [exec host $arg]

	set temp(display) ""

	foreach line [split $output \n] {
		if {[string match -nocase "*address" [lindex [split $line] 2]]} { lappend temp(display) "IPv4: \00304[lindex [split $line] 3]\003" }
		if {[string match -nocase "*IPv6" [lindex [split $line] 2]]} { lappend temp(display) "\037\002/\037\002 IPv6: \00304[lindex [split $line] 4]\003" }
		if {[string match -nocase "domain" [lindex [split $line] 1]]} { lappend temp(display) "\037\002/\037\002 Domain pointer: \00304[lindex $line 4]\003" }
	}

	putserv "PRIVMSG $chan :\002$nick\002 - [join $temp(display)]"

}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303Domain Name System\003 \]"
