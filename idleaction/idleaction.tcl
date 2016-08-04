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
# |     +----------------+                                                              |
# |     [ ADMIN - PUBLIC ]                                                              |
# |     +----------------+                                                              |
# |                                                                                     |
# |     ++ !idleaction <deop on/off 10>                                                 |
# |     ++ !idleaction <devoice on/off 10>                                              |
# |     ++ !idleaction <deop on oa>                                                     |
# |     ++ !idleaction <devoice on gv>                                                  |
# |     ++ !idleaction status                                                           |
# |                                                                                     |
# | IMPORTANT                                                                           |
# | - Deop/devoice time is SET in minutes                                               |
# | - 'oa' and 'gv' represent LOCAL user flags you can add any valid flag               |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+

bind PUBM - * idleaction:pubm

bind TIME - * idleaction:routine

setudef flag idledeop
setudef flag idledevoice

setudef int ideop
setudef int idevoice

setudef str idvprotect
setudef str idoprotect

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

	switch -exact -- [lindex [split $arg] 0] {
		deop {
			switch -exact -- [lindex [split $arg] 1] {
				on {
					if {![matchattr $hand n]} { return }
					
					if {[lindex [split $arg] 2] eq ""} {
						channel set $chan +idledeop
						channel set $chan ideop "120"
						channel set $chan idoprotect "o"

						putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-deop\00302 has been succesfully set \00304ON\00302, default deop time set to: \00304120 minutes\00302 and protection for \002\00304+[channel get $chan idoprotect]\002\00302 local flags"
					} else {
						channel set $chan +idledeop
						
						if {[isnumber [lindex [split $arg] 2]]} {
							channel set $chan ideop [lindex [split $arg] 2]
							
							putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-deop\00302 has been succesfully set \00304ON\003, deop time set to: \00304[lindex [split $arg] 2] minutes"
						} else {
							channel set $chan idoprotect [lindex [split $arg] 2]

							putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-deop\00302 has been succesfully set \00304ON\003, protecting users with flag/s: \00304\002+[lindex [split $arg] 2]"							
						}
					}
				}
				off {
					if {![matchattr $hand n]} { return }
					
					channel set $chan -idledeop
					channel set $chan ideop ""

					putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-deop\00302 has been succesfully set \00304OFF\003"
				}
			}
		}
		devoice {
			switch -exact -- [lindex [split $arg] 1] {
				on {
					if {![matchattr $hand n]} { return }
					
					if {[lindex [split $arg] 2] eq ""} {
						channel set $chan +idledevoice
						channel set $chan idevoice "120"
						channel set $chan idvprotect "v"

						putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-devoice\00302 has been succesfully set \00304ON\00302, default devoice time set to: \00304120 minutes\00302 and protection for \002\00304+[channel get $chan idvprotect]\002\00302 local flags"
					} else {
						channel set $chan +idledevoice
						
						if {[isnumber [lindex [split $arg] 2]]} {
							channel set $chan idevoice [lindex [split $arg] 2]
							
							putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-devoice\00302 has been succesfully set \00304ON\003, devoice time set to: \00304[lindex [split $arg] 2] minutes"
						} else {
							channel set $chan idvprotect [lindex [split $arg] 2]

							putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-devoice\00302 has been succesfully set \00304ON\003, protecting users with flag/s: \00304\002+[lindex [split $arg] 2]"							
						}
					}
				}
				off {
					if {![matchattr $hand n]} { return }
					
					channel set $chan -idledevoice
					channel set $chan idevoice ""

					putquick "PRIVMSG $chan :\002$nick\002 - \00312Idle-devoice\00302 has been succesfully set \00304OFF\003"
				}
			}
		}
		status {
			if {[channel get $chan idledevoice]} { set idvstatus "\002\00312ACTIVE\003\002" } else { set idvstatus "\00304INACTIVE\003"  }
			if {[channel get $chan idledeop]} { set idostatus "\002\00312ACTIVE\003\002" } else { set idostatus "\00304INACTIVE\003"  }
			
			putquick "PRIVMSG $chan :\002$nick\002 - \00302Idle-deop\003: $idostatus (\00303[channel get $chan ideop]\00302 minutes -- Protecting: \00304\002+[channel get $chan idoprotect]\002 local users\003) \037\002/\037\002 \00302Idle-devoice\003: $idvstatus (\00303[channel get $chan idevoice]\00302 minutes\00302 -- Protecting: \00304\002+[channel get $chan idvprotect]\002 local users\003)"
		}
	}
}

proc idleaction:routine {min hour day month year} {

	## ++ Devoice
	foreach chan [channels] {
		if {[channel get $chan idledevoice]} {
			set idevoice [channel get $chan idevoice]
			if {[channel get $chan idvprotect] ne ""} { set dvprotect [channel get $chan idvprotect] } else { set dvprotect "v"}
			
			foreach nick [chanlist $chan] { 
				if {![isbotnick $nick] && [isvoice $nick $chan] && ![matchattr $nick |$dvprotect $chan]} { if {[getchanidle $nick $chan] >= $idevoice} { pushmode $chan -v $nick } } }
		}
	}
	flushmode $chan
	
	## ++ Deop
	foreach chan [channels] {
		if {[channel get $chan idledeop]} {
			set ideop [channel get $chan ideop]
			if {[channel get $chan idoprotect] ne ""} { set doprotect [channel get $chan idoprotect] } else { set doprotect "o" }

			foreach nick [chanlist $chan] { 
				if {![isbotnick $nick] && [isop $nick $chan] && ![matchattr $nick |$doprotect $chan]} { if {[getchanidle $nick $chan] >= $ideop} { pushmode $chan -o $nick } } }
		}
	}	
	flushmode $chan
}

putlog "Succesfully loaded: \00303Idle Action TCL Script"
