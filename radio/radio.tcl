#### ++++ Author: MadaliN <madalinmen28@yahoo.com>
### +++ Website: www.Ascenture.ro
## +++ TCL name: radio
# +++ Version: 3.0
# +++ Commands:
#
#   !radio -activate/-deactivate (this command activates/deactivate the script on a specified channel. It can work on more channel at once with different radio stations)
#   !radio -ip/-port/-name/usage (with this command you have to configure the radio script)
#   !radio unique/on/peak/maxim/listeners/frequence/song (this command display specific informations about the radio server)
#
# +++ Example:
#
#   !radio -activate
#   !radio -ip 51.77.74.153
#   !radio -port 9300
#   !radio -name Albanian-Eagles
#   !radio listeners
#
# ..this is an actual radio ip/port that works with this script.
#
######
# NOTE: This script only works with shoutcast radio servers (only)
######

bind PUBM - * radio:main
bind PUBM - * radio:commands

setudef flag radio
setudef str name
setudef str ip
setudef str port

package require http

proc radio:main {nick uhost hand chan arg} {

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]
		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	set temp(announce) "$nick $temp(cmd) $chan"

	if {[info commands ascenture:$temp(cmd)] != ""} { ascenture:$temp(cmd) $nick $uhost $hand $chan $arg }
}

proc ascenture:radio {nick uhost hand chan arg} {
	global temp

	if {![matchattr $hand n]} { return }

	set ip [channel get $chan ip]
	set port [channel get $chan port]
	set type [lindex [split $arg] 0]

	switch -exact -- $type {
		unique {
			if {[llength $ip] && [llength $port]} {
				set url "http://$ip:$port/7.html"

				set token [http::config -useragent Mozilla]
				set token [http::geturl "$url"]
				set data [::http::data $token]
				::http::cleanup $token

				if {[channel get $chan name] == ""} { channel set $chan name "RADIO NAME IS NOT SET" }

				regexp -line {<HTML><meta http-equiv="Pragma" content="no-cache"></head><body>(.*),(.*),(.*),(.*),(.*),(.*),(.*)</body></html>$} $data -> unique on peak maxim listeners frequence song;

				if {$unique == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - The unique number of listeners from the servers are: \00304$unique"
			}
		}
		on { return }
		peak { return }
		maxim { return }
		listeners { return }
		frequence { return }
		song { return }
	}
	switch -exact [lindex [split $arg] 0] {
		-activate {
			channel set $chan +radio

			putserv "PRIVMSG $chan :\002$nick\002 - \00304radio TCL\003 has been succesfully \00312activated\003"
		}
		-deactivate -
		-dezactiveaza {
			channel set $chan -radio

			putserv "PRIVMSG $chan :\002$nick\002 - \00304radio TCL\003 has been succesfully \002dezactivat\002 deactivated"
		}
		-name -
		-nume {
			if {![llength [lindex [split $arg] 1]]} {
				putserv "PRIVMSG $chan :\002ERROR\002: You have to specify a 'radio name'"
				return
			} else {
				channel set $chan name [lindex [split $arg] 1]

				putserv "PRIVMSG $chan :\002SUCCESS\002: 'radio name' has been set to: \00312[lindex [split $arg] 1]"
			}
		}
		-ip {
			if {![llength [lindex [split $arg] 1]]} {
				putserv "PRIVMSG $chan :\002ERROR\002: You have to specify a 'radio ip'"
				return
			} else {
				channel set $chan ip [lindex [split $arg] 1]

				putserv "PRIVMSG $chan :\002SUCCESS\002: 'radio ip' has been set to: \00312[lindex [split $arg] 1]"
			}
		}
		-port {
			if {![llength [lindex [split $arg] 1]]} {
				putserv "PRIVMSG $chan :\002ERROR\002: You have to specify a 'radio port'"
				return
			} else {
				channel set $chan port [lindex [split $arg] 1]

				putserv "PRIVMSG $chan :\002SUCCESS\002: 'radio port' has been set to: \00312[lindex [split $arg] 1]"
			}
		}
		usage {
			putserv "PRIVMSG $chan :\002USAGE\002: !radio <\00303-name\003|\00303-ip\003|\00303-port\003|\00303-activate\003|\00303-deactivate\003>"
		}
	}
}

proc radio:commands {nick uhost hand chan arg} {

	switch -exact -- [lindex [split $arg] 1] {
		unique { radio $chan $nick unique }
		on { radio $chan $nick on }
		peak { radio $chan $nick peak }
		maxim { radio $chan $nick maxim }
		listeners { radio $chan $nick listeners }
		frequence { radio $chan $nick frecquence }
		song { radio $chan $nick song }
	}
}

proc radio {chan nick type} {

	set ip [channel get $chan ip]
	set port [channel get $chan port]

	if {[llength $ip] && [llength $port]} {
		set url "http://$ip:$port/7.html"

		set token [http::config -useragent Mozilla]
		set token [http::geturl "$url"]
		set data [::http::data $token]
		::http::cleanup $token

		if {[channel get $chan name] == ""} { channel set $chan name "RADIO NAME IS NOT SET" }

		regexp -line {<HTML><meta http-equiv="Pragma" content="no-cache"></head><body>(.*),(.*),(.*),(.*),(.*),(.*),(.*)</body></html>$} $data -> unique on peak maxim listeners frequence song;

		switch -exact -- $type {
			unique {
				if {$unique == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - The unique number of listeners from the servers are: \00304$unique"
			}
			on {
				if {$on == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - Online listeners on the server are: \00304$on"
			}
			peak {
				if {$peak == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - current peak is: \00304$peak"
			}
			maxim {
				if {$maxim == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - The maxim number of listeners that can connect to the servers is: \00304$maxim"
			}
			listeners {
				if {$listeners == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - The current listeners connected on the server are: \00304$listeners"
			}
			frequence {
				if {$frequence == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - The current frequence is: \00304$frequence "
			}
			song {
				if {$song == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - current song is: \00304$song"
			}
		}
	}
}

putlog "++ succesfully loaded \00304Radio TCL\003"
