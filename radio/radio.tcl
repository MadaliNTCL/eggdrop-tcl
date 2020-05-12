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
bind PUBM - * ascenture:radio

catch {bind TIME - * radio:routine}

setudef flag radio
setudef str name
setudef str ips
setudef str port
setudef str dj

set temp(cmds) "dj listeners unique peak on maxim frequence song"

package require http

proc radio:routine {min hour day month year} {
	global temp

	foreach chan [channels] {
		if {[channel get $chan radio]} {
			set ip [channel get $chan ips]
			set port [channel get $chan port]
		}
	}

	if {$ip eq ""} { return }

	if {[llength $ip] && [llength $port]} {
		set url "http://$ip:$port/7.html"

		set token [http::config -useragent Mozilla]
		set token [http::geturl "$url"]
		set data [::http::data $token]
		::http::cleanup $token

		if {[channel get $chan name] == ""} { channel set $chan name "RADIO NAME IS NOT SET" }

		regexp -line {<html><body>(.*),(.*),(.*),(.*),(.*),(.*),(.*)</body></html>$} $data -> unique on peak maxim listeners frequence song;

		if {[info exists temp(song)]} {
			if {$temp(song) ne $song} {
				foreach chan [channels] {
					if {[channel get $chan radio]} {
						putserv "PRIVMSG $chan :NEW song .. $song"

						set temp(song) $song
					}
				}
			}
		} else {
			foreach chan [channels] {
				if {[channel get $chan radio]} {
					putserv "PRIVMSG $chan :NEW song .. $song"
				}
			}
			set temp(song) $song
		}
	}
}

proc radio:main {nick uhost hand chan arg} {
	global temp

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]
		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	set temp(announce) "$nick $temp(cmd) $chan"

	if {[lsearch -nocase $temp(cmds) $temp(cmd)] ne "-1"} { command $chan $nick $temp(cmd) }
}

proc ascenture:radio {nick uhost hand chan arg} {
	global temp

	if {![matchattr $hand n]} { return }

	set ip [channel get $chan ips]
	set port [channel get $chan port]
	set type [lindex [split $arg] 1]

	switch -exact $type {
		-activate {
			channel set $chan +radio

			putserv "PRIVMSG $chan :\002$nick\002 - \00304radio TCL\003 has been succesfully \00312activated\003"
		}
		-deactivate -
		-dezactiveaza {
			channel set $chan -radio

			putserv "PRIVMSG $chan :\002$nick\002 - \00304radio TCL\003 has been succesfully \002dezactivat\002 deactivated"
		}
		-dj -
		-dj {
			if {![llength [lindex [split $arg] 2]]} {
				putserv "PRIVMSG $chan :\002ERROR\002: You have to specify a 'dj name'"
				return
			} else {
				channel set $chan dj [lindex [split $arg] 2]

				putserv "PRIVMSG $chan :\002SUCCESS\002: 'dj name' has been set to: \00312[lindex [split $arg] 2]"
			}
		}
		-name -
		-nume {
			if {![llength [lindex [split $arg] 2]]} {
				putserv "PRIVMSG $chan :\002ERROR\002: You have to specify a 'radio name'"
				return
			} else {
				channel set $chan name [lindex [split $arg] 2]

				putserv "PRIVMSG $chan :\002SUCCESS\002: 'radio name' has been set to: \00312[lindex [split $arg] 2]"
			}
		}
		-ip {
			if {![llength [lindex [split $arg] 2]]} {
				putserv "PRIVMSG $chan :\002ERROR\002: You have to specify a 'radio ip'"
				return
			} 
				channel set $chan ips [lindex [split $arg] 2]

				putserv "PRIVMSG $chan :\002SUCCESS\002: 'radio ip' has been set to: \00312[lindex [split $arg] 2]"

		}
		-port {
			if {![llength [lindex [split $arg] 2]]} {
				putserv "PRIVMSG $chan :\002ERROR\002: You have to specify a 'radio port'"
				return
			} else {
				channel set $chan port [lindex [split $arg] 2]

				putserv "PRIVMSG $chan :\002SUCCESS\002: 'radio port' has been set to: \00312[lindex [split $arg] 2]"
			}
		}
		usage {
			putserv "PRIVMSG $chan :\002USAGE\002: !radio <\00303-name\003|\00303-ip\003|\00303-port\003|\00303-activate\003|\00303-deactivate\003>"
		}
	}
}

proc command {chan nick type} {

	set ip [channel get $chan ips]
	set port [channel get $chan port]

	if {[llength $ip] && [llength $port]} {
		set url "http://$ip:$port/7.html"

		set token [http::config -useragent Mozilla]
		set token [http::geturl "$url"]
		set data [::http::data $token]
		::http::cleanup $token

		if {[channel get $chan name] == ""} { channel set $chan name "RADIO NAME IS NOT SET" }

		regexp -line {<html><body>(.*),(.*),(.*),(.*),(.*),(.*),(.*)</body></html>$} $data -> unique on peak maxim listeners frequence song;

		switch -exact -- $type {
			unici - unique {
				if {$unique == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - The unique number of listeners from the servers are: \00304$unique"
			}
			on {
				if {$on == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - Online listeners on the server are: \00304$on"
			}
			varf - peak {
				if {$peak == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - current peak is: \00304$peak"
			}
			maxim {
				if {$maxim == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - The maxim number of listeners that can connect to the servers is: \00304$maxim"
			}
			ascultatori - listeners {
				if {$listeners == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - The current listeners connected on the server are: \00304$listeners"
			}
			frecventa - frequence {
				if {$frequence == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - The current frequence is: \00304$frequence "
			}
			melodie - song {
				if {$song == ""} { putserv "PRIVMSG $chan :\002$nick\002 - '$type' couldnt be read (the website is not providing this information)"; return }

				putserv "PRIVMSG $chan :\002$nick\002 - current song is: \00304$song"
			}
			dj {

				putserv "PRIVMSG $chan :\002$nick\002 - DJ is: \00304[channel get $chan dj]"
			}
		}
	}
}

putlog "++ succesfully loaded \00304Radio TCL\003"
