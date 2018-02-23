# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         Seen Script v1.0.0                                          |
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
# |     ++ !seen on                                                                     |
# |     ++ !seen off                                                                    |
# |                                                                                     |
# |     +---------------+                                                               |
# |     [ USER - PUBLIC ]                                                               |
# |     +---------------+                                                               |
# |                                                                                     |
# |     +++ !seen <nickname>                                                            |
# |     +++ !seen top                                                                   |
# |     +++ !seen stats                                                                 |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+

bind PUBM - * seen:pub

bind JOIN - * seen:join
bind JOIN - * seen:check
bind PART - * seen:part
bind SIGN - * seen:sign
bind KICK - * seen:kick
bind SPLT - * seen:split
bind NICK - * seen:nick

setudef flag seen

set seen-path "netbots/database/seen"

if {![file exists ${seen-path}]} {
	putlog "\00405Instalam Seen Script.."

	file mkdir ${seen-path}

	set in [open ${seen-path}/seen.check w]; close $in
	set in [open ${seen-path}/seen w]; close $in
}

proc seen:pub {nick uhost hand chan arg} {
	global signore
	
	if {[lindex [split $arg] 1] eq "*!*@*"} { return }
	if {[lindex [split $arg] 1] eq ""} { return }
	if {[info exists signore($nick)]} { return }

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]		
		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	if {[info commands $temp(cmd):pubcmd] ne ""} { $temp(cmd):pubcmd $nick $uhost $hand $chan $arg }
}

proc seen:pubcmd {nick uhost hand chan arg} {
	global signore

	set floodtime 10

	set value [lindex [split $arg] 0]

	switch -exact -- [lindex [split $arg] 0] {
		on { if {![matchattr $hand n]} { return }; seen on $value $chan $nick }
		off { if {![matchattr $hand n ]} { return }; seen off $value $chan $nick }
		stats { if {![matchattr $hand n ]} { return }; seen stats $value $chan $nick }
		top { if {![matchattr $hand n ]} { return }; seen top $value $chan $nick }
		reset { if {![matchattr $hand n ]} { return }; seen reset $value $chan $hand }
		default { seen search $value $chan $nick }
	}

	if {![matchattr $hand n]} {
		if {![info exists signore($nick)]} {
			set signore($nick) [unixtime]

			utimer $floodtime [list unset -nocomplain signore($nick)]
		}
	}
}

proc seen {cmd value chan nick} {
	global seen-path

	switch -exact -- $cmd {
		"on" {
			channel set $chan +seen

			putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306+seen\00302 on \00304$chan"
		}
		"off" {
			channel set $chan -seen

			putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306-seen\00302 on \00304$chan"
		}
		"reset" {
			if {![channel get $chan seen]} { return }
			
			set a [open ${seen-path}/seen w]; close $a
			set b [open ${seen-path}/seen.check w]; close $b

			putserv "NOTICE $nick :Am sters cu succes baza de date"
		}
		"top" {
			if {![channel get $chan seen]} { return }

			set temp(display) ""; set temp(say) ""; set temp(announce) ""
			array set times "";

			set in [open "netbots/database/seen/seen.check" r]

			while {[gets $in line] != -1} {
				if {[lindex [split $line] 0] ne ""} {
					incr times([lindex [split $line] 0]) [lindex [split $line] 4]
				}
			}
			close $in


			foreach n [array names times] { lappend temp(display) "$n $times($n)" }

			set temp(say) [lsort -decreasing -index 1 $temp(display)]
			set place 0

			foreach x $temp(say) {
				incr place

				lappend temp(announce) "\00310#$place: \00302[lindex [split $x] 0] \00304[lindex [split $x] 1]"
			}

			set top [join [lrange $temp(announce) 0 9]]

			putserv "PRIVMSG $chan :** \00312Top 10 \00304\002Most Wanted\002\003 ** [join $temp(announce) "\002,\002 "]"
		}
		"stats" {
			if {![channel get $chan seen]} { return }

			set temp(chans) ""
			set temp(users) ""

			set in [open "netbots/database/seen/seen" r]

			while {[gets $in line] != -1} {
				lappend temp(chans) [lindex [split $line] 1]
				lappend temp(users) [lindex [split $line] 2]
			}

			close $in

			set chans [llength [lsort -unique $temp(chans)]]
			set users [llength [lsort -unique $temp(users)]]

			putserv "PRIVMSG $chan :** Seen Statistics ** \00302Channels monitored: \00304\002$chans\002\003 -- \00302Users seen: \00304\002$users\002\003"
		
			set temp(chans) ""
			set temp(users) ""

		}
		"hostname" {
			set temp(list) ""

			set in [open "netbots/database/seen/seen" r]

			while {[gets $in line] != -1} {
				if {[string match -nocase [lindex [split $line] 1] $chan]} {
					set host [lindex [split $line] 3]
					if {[string match -nocase [lindex [split $host @] 1] [lindex [split $value @] 1]]} {
						set found 1

						set host [string trim [lindex [split $line] 3] "*!~"]
						set date [clock format [lindex [split $line] 4] -format "%d.%m.%Y / %R-%p"]
						set output [duration [expr [unixtime] - [lindex [split $line] 4]]]
						set reason [lrange [split $line] 6 end]

						lappend temp(list) [lindex [split $line] 2]

						if {[lindex [split $line] 5] eq "0"} {
							set staymsg "I dont know how much he stayed."
						} else { set staymsg "after he stayed \00303[duration [lindex [split $line] 5]]\003 on $chan."}

						if {[lindex [split $line] 0] eq "PART"} {
							set reply "\00312[lindex [split $line] 2]\003 (\00304\00304$host\003\003) left \00302$chan\003 about \00306$output\003 (\00307$date\003) stating: \037\037$reason\037\037, $staymsg"
						}
						if {[lindex [split $line] 0] eq "SIGN"} {
							set reply "\00312[lindex [split $line] 2]\003 (\00304$host\003) left IRC about \00306$output\003 (\00307$date\003) stating: \037$reason\037, $staymsg"
						}
						if {[lindex [split $line] 0] eq "JOIN"} {
							if {[onchan $value $chan]} { set nowon "$value is stil here."} else { set nowon "I dont see $value on $chan" }
							set reply "\00312[lindex [split $line] 2]\003 (\00304$host\003) joined $chan about \00306$output\003 (\00307$date\003). $nowon"
						}
						if {[lindex [split $line] 0] eq "SPLIT"} {
							set reply "\00312[lindex [split $line] 2]\003 (\00304$host\003) left in *.net *.split about \00306$output\003 (\00307$date\003), $staymsg"
						}
						if {[lindex [split $line] 0] eq "KICK"} {
							set reply "\00312[lindex [split $line] 2]\003 (\00304$host\003) was kicked on $chan about \00306$output\003 (\00307$date\003) with the reason (\037$reason\037), $staymsg"
						}
						if {[lindex [split $line] 0] eq "NICKCHANGE"} {
							if {[onchan $value $chan]} { set nowon "\00312$value\003 is stil here." } else { set nowon "I dont see $value on $chan" }
							set reply "\00312[lindex [split $line] 2]\003 (\00304$host\003) changed his NICK in \00304[lindex [split $line] 6]\003 about \00306$output\003 (\00307$date\003). $nowon"
						}
					}
				}
			}

			if {[info exists reply]} {  putserv "NOTICE $nick :$reply" }
			if {![info exists found]} { putquick "NOTICE $nick :I dont remember $value." }

			close $in
		}
		"default" {
			if {![channel get $chan seen]} { return }
			if {[onchan $value $chan]} { putserv "PRIVMSG $chan :$value is already on $chan"; return}

			unset -nocomplain found

			set in [open "netbots/database/seen/seen" r]

			while {[gets $in line] != -1} {
				if {[string match -nocase [lindex [split $line] 1] $chan]} {
					if {[string match -nocase [lindex [split $line] 2] $value]} {
						set found 1

						set host [string trim [lindex [split $line] 3] "*!~"]
						set date [clock format [lindex [split $line] 4] -format "%d.%m.%Y / %R-%p"]
						set output [duration [expr [unixtime] - [lindex [split $line] 4]]]
						set reason [lrange [split $line] 6 end]

						if {[lindex [split $line] 5] eq "0"} {
							set staymsg "I dont know how much he stayed."
						} else { set staymsg "after he stayed \00303[duration [lindex [split $line] 5]]\003 on $chan."}

						if {[lindex [split $line] 0] eq "PART"} {
							set reply "\00312[lindex [split $line] 2]\003 (\00304\00304$host\003\003) left \00302$chan\003 about \00306$output\003 (\00307$date\003) stating: \037\037$reason\037\037, $staymsg"
						}
						if {[lindex [split $line] 0] eq "SIGN"} {
							set reply "\00312[lindex [split $line] 2]\003 (\00304$host\003) left IRC about \00306$output\003 (\00307$date\003) stating: \037$reason\037, $staymsg"
						}
						if {[lindex [split $line] 0] eq "JOIN"} {
							if {[onchan $value $chan]} { set nowon "$value is stil here."} else { set nowon "I dont see $value on $chan" }
							set reply "\00312[lindex [split $line] 2]\003 (\00304$host\003) joined $chan about \00306$output\003 (\00307$date\003). $nowon"
						}
						if {[lindex [split $line] 0] eq "SPLIT"} {
							set reply "\00312[lindex [split $line] 2]\003 (\00304$host\003) left in *.net *.split about \00306$output\003 (\00307$date\003), $staymsg"
						}
						if {[lindex [split $line] 0] eq "KICK"} {
							set reply "\00312[lindex [split $line] 2]\003 (\00304$host\003) was kicked on $chan about \00306$output\003 (\00307$date\003) with the reason (\037$reason\037), $staymsg"
						}
						if {[lindex [split $line] 0] eq "NICKCHANGE"} {
							if {[onchan $value $chan]} { set nowon "\00312$value\003 is stil here." } else { set nowon "I dont see $value on $chan" }
							set reply "\00312[lindex [split $line] 2]\003 (\00304$host\003) changed his NICK in \00304[lindex [split $line] 6]\003 about \00306$output\003 (\00307$date\003). $nowon"
						}
					}
				}
			}

			if {[info exists reply]} {  putserv "NOTICE $nick :$reply" }
			if {![info exists found]} { seen hostname $value $chan $nick; return }

			close $in

			set a [open "netbots/database/seen/seen.check" r]
			set b [open "netbots/database/seen/seen.qcheck" w]

			unset -nocomplain checked
			
			while {[gets $a line] != -1} {
				if {[string match -nocase [lindex [split $line] 1] $chan]} {
					if {[string match -nocase [lindex [split $line] 0] $value]} {
						set checked 1

						set target [lindex [split $line] 0]
						set date [unixtime]
						set nick [lindex [split $line] 3]
						set times [lindex [split $line] 4]

						puts $b "$value $chan $date $nick [expr $times + 1] 0"
					} else { puts $b $line }
				}
			}

			if {![info exists checked]} { puts $b "$value $chan [unixtime] $nick 1 0" }

			close $a; close $b

			file rename -force netbots/database/seen/seen.qcheck netbots/database/seen/seen.check
		}
	}
}

proc seen:join {nick uhost hand chan} {

	if {[isbotnick $nick]} { return }

	set in [open "netbots/database/seen/seen" r]
	set out [open "netbots/database/seen/qseen" w]

	unset -nocomplain found

	while {[gets $in line] != -1} {
		if {[string match -nocase [lindex [split $line] 2] $nick]} {
			set found 1

			puts $out "JOIN $chan $nick $uhost [unixtime] 0"
		} else { puts $out $line }
	}

	if {![info exists found]} { puts $out "JOIN $chan $nick $uhost [unixtime] 0" }

	file rename -force netbots/database/seen/qseen netbots/database/seen/seen

	close $in; close $out
}

proc seen:part {nick uhost hand chan reason} {

	if {[isbotnick $nick]} { return }
	if {$reason eq ""} { set reason "No Reason"}

	set in [open "netbots/database/seen/seen" r]
	set out [open "netbots/database/seen/qseen" w]

	unset -nocomplain found

	while {[gets $in line] != -1} {
		if {[string match -nocase [lindex [split $line] 2] $nick]} {
			set found 1

			set jointime [lindex [split $line] 4]

			puts $out "PART $chan $nick $uhost [unixtime] [expr [unixtime] - $jointime] $reason"
		} else { puts $out $line }
	}

	if {![info exists found]} { puts $out "PART $chan $nick $uhost [unixtime] 0 $reason" }

	file rename -force netbots/database/seen/qseen netbots/database/seen/seen

	close $in; close $out
}

proc seen:sign {nick uhost hand chan reason} {

	if {[isbotnick $nick]} { return }
	if {$reason eq ""} { set reason "No Reason"}

	set in [open "netbots/database/seen/seen" r]
	set out [open "netbots/database/seen/qseen" w]

	unset -nocomplain found

	while {[gets $in line] != -1} {
		if {[string match -nocase [lindex [split $line] 2] $nick]} {
			set found 1

			set jointime [lindex [split $line] 4]

			puts $out "SIGN $chan $nick $uhost [unixtime] [expr [unixtime] - $jointime] $reason"
		} else { puts $out $line }
	}

	if {![info exists found]} { puts $out "SIGN $chan $nick $uhost [unixtime] 0 $reason" }

	file rename -force netbots/database/seen/qseen netbots/database/seen/seen

	close $in; close $out
}

proc seen:kick {nick uhost hand chan kicked reason} {

	if {[isbotnick $nick]} { return }
	if {$reason eq ""} { set reason "No Reason"}

	set kickhost [getchanhost $kicked $chan]

	set in [open "netbots/database/seen/seen" r]
	set out [open "netbots/database/seen/qseen" w]

	unset -nocomplain found

	while {[gets $in line] != -1} {
		if {[string match -nocase [lindex [split $line] 2] $nick]} {
			set found 1

			set jointime [lindex [split $line] 4]

			puts $out "KICK $chan $kicked $kickhost [unixtime] 0 $reason"
		} else { puts $out $line }
	}

	if {![info exists found]} { puts $out "KICK $chan $kicked $kickhost [unixtime] 0 $reason" }

	file rename -force netbots/database/seen/qseen netbots/database/seen/seen

	close $in; close $out
}

proc seen:split {nick uhost hand chan} {

	if {[isbotnick $nick]} { return }

	set in [open "netbots/database/seen/seen" r]
	set out [open "netbots/database/seen/qseen" w]

	unset -nocomplain found

	while {[gets $in line] != -1} {
		if {[string match -nocase [lindex [split $line] 2] $nick]} {
			set found 1

			set jointime [lindex [split $line] 4]

			puts $out "SPLIT $chan $nick $uhost [unixtime] [expr [unixtime] - $jointime]"
		} else { puts $out $line }
	}

	if {![info exists found]} { puts $out "SPLIT $chan $nick $uhost [unixtime] 0" }

	file rename -force netbots/database/seen/qseen netbots/database/seen/seen

	close $in; close $out
}

proc seen:nick {nick uhost hand chan newnick} {

	if {[isbotnick $nick]} { return }

	set in [open "netbots/database/seen/seen" r]
	set out [open "netbots/database/seen/qseen" w]

	unset -nocomplain found

	while {[gets $in line] != -1} {
		if {[string match -nocase [lindex [split $line] 2] $nick]} {
			set found 1

			set jointime [lindex [split $line] 4]

			puts $out "NICKCHANGE $chan $nick $uhost [unixtime] 0 $newnick"
		} else { puts $out $line }
	}

	if {![info exists found]} { puts $out "NICKCHANGE $chan $nick $uhost [unixtime] 0 $newnick" }

	file rename -force netbots/database/seen/qseen netbots/database/seen/seen

	close $in; close $out
}

proc seen:check {nick uhost hand chan} {

	if {[isbotnick $nick]} { return }

	## ++ Checking ...
	set a [open "netbots/database/seen/seen.check" r]
	set b [open "netbots/database/seen/seen.qcheck" w]

	while {[gets $a line] != -1} {
		## ++ nickname check
		if {[string match -nocase [lindex [split $line] 0] $nick] && [string match -nocase [lindex [split $line] 1] $chan] && [lindex [split $line] 5] eq "0"} {
			set target [lindex [split $line] 0]
			set chan [lindex [split $line] 1]
			set date [clock format [lindex [split $line] 2] -format "%d.%m.%Y / %R-%p"]
			set nick [lindex [split $line] 3]
			set times [lindex [split $line] 4]
			set seened [lindex [split $line] 5]

			putserv "NOTICE [lindex [split $line] 0] :\00304$nick\003 looked for you with \00303!seen\003 on \00312$chan\003 about \00306[duration [expr [unixtime] - [lindex [split $line] 2]]]\003 ago (\00307$date\003). You have been searched so far \00304\002$times\003\002 times."

			puts $b "$target $chan [lindex [split $line] 2] $nick $times 1"
		} else { puts $b $line }
	}

	close $a; close $b
	file rename -force netbots/database/seen/seen.qcheck netbots/database/seen/seen.check
}

proc seen:parse {nick chan} {
	global temp

	set a [open "netbots/database/seen/seen" r]

	set temp(return) ""
	while {[gets $a line] != -1} {
		if {[string match -nocase [lindex [split $line] 2] $nick] && [string match -nocase [lindex [split $line] 1] $chan]} {
			set temp(return) "\00304[duration [expr [unixtime] - [lindex [split $line] 4]]]\003 (\00312[clock format [lindex [split $line] 4] -format "%d.%m.%Y / %R-%p"]\003)"
		}
	}
	close $a

	return $::temp(return)
}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303Seen\003 \]"
