# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         Chan Age v1.0.0                                             |
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
# |     ++ !chanage <channel>                                                           |
# |                                                                                     |
# | IMPORTANT                                                                           |
# | - Has no ON OFF command                                                             |
# | - Works only for OP or VOICEd users                                                 |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+

bind PUBM - * chanage:pubm

proc chanage:pubm {nick uhost hand chan arg} {

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]
		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	if {[info commands $temp(cmd):cacmd] ne ""} { $temp(cmd):cacmd $nick $uhost $hand $chan $arg }
}

proc chanage:cacmd {nick uhost hand chan arg} {
	global chaninfo
	
	set target [lindex [split $arg] 0]

	if {[isop $nick $chan] || [isvoice $nick $chan]} {
		if {$target eq ""} {
			set chaninfo(channel) "$chan"
			set chaninfo(home)    "$chan"
			
			bind RAW - "329" reply:pub:mode
			bind RAW - "403" reply:pub:nochan
			
			putquick "MODE $chan"
		} else {
			if {![validchan $target]} { putserv "PRIVMSG $chan :\00304$target\003 is not a validchan"; return }
			
			set chaninfo(channel) "$target"
			set chaninfo(home) "$chan"
			
			bind RAW - "329" reply:pub:mode
			bind RAW - "403" reply:pub:nochan
			
			putquick "MODE $target"
		}
	}
}

proc reply:pub:nochan {from key args} {
	global chaninfo

	putquick "PRIVMSG $chaninfo(home) :No such channel $chaninfo(channel)"

	unbind RAW - "329" reply:pub:mode
	unbind RAW - "403" reply:pub:nochan

	unset chaninfo(channel)
	unset chaninfo(home)
}

proc reply:pub:mode {from key args} {
	global chaninfo

	set creation [lindex [join $args] end]
	set c [clock format $creation -format "%d.%m.%Y/%R-%p"]
	
	putquick "PRIVMSG $chaninfo(home) :\00302The channel (\00304$chaninfo(channel)\003) \00302was created on: \00304$c (\00312[duration [expr [clock seconds]-$creation]] \00302ago\003)"

	unbind RAW - "329" reply:pub:mode
	unbind RAW - "403" reply:pub:nochan

	unset chaninfo(channel)
	unset chaninfo(home)
}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303ChanAGE\003 \]"
