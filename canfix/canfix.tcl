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
	putlog 111
	set temp(chan) $chan

	putserv "PRIVMSG C :CANFIX [lindex [split $arg] 0]"
}

proc canfix:notice {nick uhost hand text {dest ""}} {
	global temp
	putlog $text
	if {[string match -nocase "*do not have a hi*" $text]} { putserv "PRIVMSG $temp(chan) :$text" }
	if {[string match -nocase "*can issue*" $text]} { putserv "PRIVMSG $temp(chan) :$text" }
}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303Canfix\003 \]"
