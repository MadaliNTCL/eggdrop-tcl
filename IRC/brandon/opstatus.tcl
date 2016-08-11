# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         Op Status v1.0.0                                            |
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
# |     ++ .ostatus                                                                     |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+

bind PUBM - * opstatus:pubm

setudef flag opstatus

proc opstatus:pubm {nick uhost hand chan arg} {

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]

		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	if {[info commands os:pubm:$temp(cmd)] ne ""} { os:pubm:$temp(cmd) $nick $uhost $hand $chan $arg }
}

proc os:pubm:opstatus {nick uhost hand chan arg} {

	switch -exact -- [lindex [split $arg] 0] {
		on {
			if {![matchattr $hand n]} { return }
			
			channel set $chan +opstatus

			putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306+opstatus\0032 on \00304$chan"
		}
		off {
			if {![matchattr $hand n]} { return }
			
			channel set $chan -opstatus

			putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306-opstatus\0032 on \00304$chan"
		}
		default {
			if {![matchattr $hand n]} { return }
			if {![channel get $chan opstatus]} { return }
			
			set temp(list) ""

			foreach user [userlist -|o $chan] {
				if {![onchan $user $chan]} {
					lappend temp(list) "\00304$user"
				}
			}

			if {$temp(list) eq ""} { putserv "PRIVMSG $chan :\002$nick\002 - List \002empty\002 everyone on duty"; return }

			putserv "PRIVMSG $chan :\002$nick\002 - Users not onchan: [join $temp(list) ", "]"
		}
	}
}

putlog "++ \[ - \00304PUBLIC\003 - \00303!opstatus\003 \] - succesfully loaded"
