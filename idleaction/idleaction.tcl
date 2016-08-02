# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         Idle Action v1.0.0                                          |
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
# |     ++ !idleaction <deop/devoice> <on/off/time>                                     |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+

bind PUBM - * idleaction:pubm

bind TIME - * idleaction:routine

setudef flag idledeop
setudef flag idledevoice

setudef int ideop
setudef int idevoice

proc idleaction:pubm {nick uhost hand chan arg} {

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]
		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	if {[info commands $temp(cmd):icpubcmd] ne ""} { $temp(cmd):icpubcmd $nick $uhost $hand $chan $arg }
}

proc idleaction:icpubcmd {nick uhost hand chan arg} {

	putlog "[lindex [split $arg] 0] -- [lindex [split $arg] 1] -- [lindex [split $arg] 2] -- [lindex [split $arg] 3]"
	switch -exact -- [lindex [split $arg] 0] {
		deop {
			switch -exact -- [lindex [split $arg] 1] {
				on {
					if {[lindex [split $arg] 2] eq ""} {
						channel set $chan +idledeop
						channel set $chan ideop "120"

						putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-deop\00302 has been succesfully set \00304ON\003, default deop time set to: \00304120 minutes"
					} else {
						if {[lindex [split $arg] 2] eq ""} {
							channel set $chan +idledeop
							channel set $chan ideop "[lindex [split $arg] 2]"

							putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-deop\00302 has been succesfully set \00304ON\003, default deop time set to: \00304[lindex [split $arg] 2] minutes"
						}
					}
				}
				off {
					if {[lindex [split $arg] 2] eq ""} {
						channel set $chan -idledeop
						channel set $chan ideop ""

						putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-deop\00302 has been succesfully set \00304OFF\003"
					}
				}
			}
		}
		devoice {
			switch -exact -- [lindex [split $arg] 1] {
				on {
					if {[lindex [split $arg] 2] eq ""} {
						channel set $chan +idledevoice
						channel set $chan idevoice "120"

						putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-devoice\00302 has been succesfully set \00304ON\003, default devoice time set to: \00304120 minutes"
					} else {
						putlog aiciii
						channel set $chan +idledevoice
						channel set $chan idevoice [lindex [split $arg] 2]

						putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-devoice\00302 has been succesfully set \00304ON\003, devoice time set to: \00304[lindex [split $arg] 2] minutes"
					}
				}
				off {
					channel set $chan -idledevoice
					channel set $chan idevoice ""

					putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-devoice\00302 has been succesfully set \00304OFF\003"
				}
			}
		}
	}
}

proc idleaction:routine {min hour day month year} {

	## ++ Devoice
	foreach chan [channels] {
		if {[channel get $chan idledevoice]} {
			set idevoice [channel get $chan idevoice]

			foreach nick [chanlist $chan] { 
				if {![isbotnick $nic] && [isvoice $nick $chan]} { if {[getchanidle $nick $chan] >= $idevoice} { pushmode $chan -v $nick } } }
		}
	}
	flushmode $chan
	
	## ++ Deop
	foreach chan [channels] {
		if {[channel get $chan idledeop]} {
			set ideop [channel get $chan ideop]

			foreach nick [chanlist $chan] { 
				if {![isbotnick $nic] && [isvoice $nick $chan]} { if {[getchanidle $nick $chan] >= $ideop} { pushmode $chan -o $nick } } }
		}
	}	
	flushmode $chan
}

putlog "Succesfully loaded: \00303Idle Action TCL Script"
