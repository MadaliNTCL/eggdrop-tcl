# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         Channel Commands v1.0.0                                     |
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
# |     [ ADMIN - PUBLIC]                                                               |
# |     +---------------+                                                               |
# |                                                                                     |
# |     +++ !chancmds add <command> <PRIVMSG/CHAN/NOTICE> <TEXT>                        |
# |     +++ !chancmds del <command>                                                     |
# |     +++ !chancmds list                                                              |
# |                                                                                     |
# | IMPORTANT                                                                           |
# | - You can also use $nick and $chan in texts                                         |
# | - To add a channel greet use !chancmds add greet text it will be added as command   |
# | but will work as GREET                                                              |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+

bind PUBM - * chancmds:pubm

bind JOIN - * notice:chan

set chancmds-path "netbots/database/chancmds"

if {![file exists ${chancmds-path}]} { file mkdir ${chancmds-path} }

proc chancmds:pubm {nick uhost hand chan arg} {
	global temp cmds

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]

		set arg [join [lrange [split $arg] 1 end]]

		if {[llength $temp(cmd)] && [info exists cmds($temp(cmd),$chan)] && ($temp(cmd) ne "greet")} {
			set type [lindex [split $cmds($temp(cmd),$chan)] 0]
			set type [string map [list "$temp(cmd)" ""] $type]

			switch -exact -nocase $type {
				PRIVMSG {
					foreach n [split $cmds($temp(cmd),$chan) |] {
						set n [string map [list "privmsg" "" "greet" ""] $n]

						putserv "PRIVMSG $nick :[join [subst -noc $n]]"
					}
					return "$type $chan"
				}
				NOTICE {
					foreach n [split $cmds($temp(cmd),$chan) |] {
						set n [string map [list "notice" "" "greet" ""] $n]

						putserv "NOTICE $nick :[join [subst -noc $n]]"
					}
					return "$type $chan"
				}
				CHAN {
					foreach n [split $cmds($temp(cmd),$chan) |] {
						set n [string map [list "chan" "" "greet" ""] $n]

						putserv "PRIVMSG $chan :[join [subst -noc $n]]"
					}
					return "$type $chan"
				}
			}
		}
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	if {[info commands chancmds:$temp(cmd)] ne ""} { chancmds:$temp(cmd) $nick $uhost $hand $chan $arg }
}

proc chancmds:chancmds {nick host hand chan text} {
	global cmds

	switch -nocase -- [lindex [split $text] 0] {
		add {
			if {![matchattr $hand n]} { return }
			if {![regexp {^(privmsg|notice|chan)$} [lindex [split $text] 2]]} { putserv "PRIVMSG $chan :\002$nick\002 - \00302available types are \00303privmsg\003|\00303notice\003|\00303chan\00302 you typed \00304[lindex [split $text] 2]\00302 do you see the problem?"; return }

			set cmds([lindex [split $text] 1],$chan) "[lindex [split $text] 2] [join [lrange $text 3 end]]"
			chancmds:save

			putserv "PRIVMSG $chan :\002$nick\002 - \00302Added command \00303[lindex [split $text] 1]\003 with text \00312[join [lrange $text 3 end]]\00302 via \00304[join [lindex [split $text] 2]]"
		}
		del {
			if {![matchattr $hand n]} { return }
			if {![info exists cmds([lindex [split $text] 1],$chan)]} { putserv "PRIVMSG $chan :\002$nick\002 - \00304[lindex [split $text] 2]\003 error"; return }

			unset cmds([lindex [split $text] 1],$chan)
			chancmds:save

			putserv "PRIVMSG $chan :\002$nick\002 - \00302Succesfully deleted \00304[lindex [split $text] 1]\00302 command"
			return
		}
		list {
			if {![matchattr $hand n]} { return }

			set temp(list) ""
			set ok 0

			foreach n [array names cmds] {
				if {[string match -nocase [lindex [split $n ,] 1] $chan]} {
					if {[lindex [split $n ,] 0] ne "greet"} {
					set ok 1
						lappend temp(list) "\00304[lindex [split $n ,] 0]\003"
					}
				}
			}

			if {$temp(list) ne ""} {
				putserv "PRIVMSG $chan :\002$nick\002 - \00302Available commands for \00312$chan\00302 are\003: [join $temp(list) "\002,\002 "]"
			}
			if {!$ok} {
				putserv "PRIVMSG $chan :\002$nick\002 - \00302Database for \00312$chan\00302 \002empty"
			}
		}
	}
}

proc chancmds:save {} {
	global cmds chancmds-path

	set nfw [open ${chancmds-path}/chancmds w]
	puts $nfw "array set cmds [list [array get cmds]]"
	close $nfw
}

proc notice:chan {nick uhost hand chan} {
	global cmds

	if {[info exists cmds(greet,$chan)]} {
		foreach n [split $cmds(greet,$chan) |] {
			set n [string map [list "notice" ""] $n]
			putserv "NOTICE $nick :[join [subst -noc $n]]"
		}
	}
}

catch {source ${chancmds-path}/chancmds}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303Channel Commands\003 \]"
