# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         Canfix v1.0                                                 |
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
# |     [ Admin - PUBLIC   ]                                                            |
# |     +---------------+                                                               |
# |                                                                                     |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+

bind PUB - !canfix canfix
bind notc - * canfix:notice

proc canfix {nick uhost hand chan arg} {
	global temp

	set temp(chan) $chan
	set temp(list) ""

	putserv "PRIVMSG C :CANFIX [lindex [split $arg] 0]"
	
	set temp(display) [utimer 15 [list putserv "PRIVMSG $temp(chan) ::: Accounts who can issue fixes in channel $temp(chan): [join $temp(list) "\002,\002 "]"]]
}

proc canfix:notice {nick uhost hand text {dest ""}} {
	global temp

	set who [lindex [split $text] 0]

        killutimer $temp(display)

	if {[string match -nocase "*do not have a hi*" $text]} { putserv "PRIVMSG $temp(chan) :$text"; return }

	if {[string match -nocase "*--*" $text]} { lappend temp(list) "\00303$who\003" }
	
	set temp(display) [utimer 10 [list putserv "PRIVMSG $temp(chan) ::: Accounts who can issue fixes in channel $temp(chan): [join $temp(list) "\002,\002 "]"]]
}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303Canfix\003 \]"
