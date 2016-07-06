<html>
<title>chancontrol.tcl help file - PLEASE, keep in mind, this is a work in progess</title>
<h2>Index</h2>
<ul>
<li><a href="#description">Description</a>
<li><a href="#commands">Commands</a>
<li><a href="#contact">Contact</a>
</ul>
<br>
<br>

<a name="description"><h2>Description</h2></a>
This bot has protection scripts enabled by default when oped in a channel. <br>
If you want some specific users "protected" from those, add them +f with .chattr<br>
<b>All commands</b> in this help file are assumed to have "." as a trigger. For example .op .kick .rehash.<br>
To see the trigger on the bot check the config file<br></h4>
<br>
<br>
<a name="commands"><h2>Commands</h2></a>
<table "id="t01"> 
<caption><h3>DCC/telnet commands (you need a handle(user) on the bot)</h3></caption>
  <tr>
    <th><b>.command</b></th>
    <th><b>Description</b></th>
  </tr>
  <tr>
    <td>.keepalive</td>
    <td>Send a blank line to the bot to help you keep the connection in DCC<br>Really useful when your home connection sucks</td>
  </tr>
  <tr>
    <td>.help</td>
    <td>To be completed<br>help system, with examples</td>
  </tr>
  <tr>
    <td>.ops <text></td>
    <td>Sends a notice to the backchannel, to alert everyone in there that someone<br> somewhere needs your help, and why (if specified)</td>
  </tr>
</table>
<br>
<br>
<table "id="t01"> 
<caption><h3>Available to everyone (NO flags needed)</h3></caption>
  <tr>
    <th><b>.command</b></th>
    <th><b>Description</b></th>
  </tr>
  <tr>
    <td>.version</td>
    <td>Get the version infos and link to this script via /notice</td>
  </tr>
  <tr>
    <td>.bot</td>
    <td>Receive a list of commands available to you via /notice</td>
  </tr>
  <tr>
    <td>.whois &lt;nickname&gt;</td>
    <td>see "who is" someone, their flags and infos.</td>
  </tr>
</table>
<br>
<br>
<table "id="t01">
<caption><h3>Channel Voices (+v)</h3></caption>
  <tr>
    <th><b>.command</b></th>
    <th><b>Description</b></th>
  </tr>
  <tr>
    <td>.voice [nick]</td>
    <td>voice (+v) a user, or yourself if no nick is specified</td>
  </tr>
  <tr>
    <td>.devoice [nick]</td>
    <td>devoice (-v) a user, or yourself if no nick is specified</td>
  </tr>
</table>
<br>
<br>
<table "id="t01">
<caption><h3>Channel ops (+o)</h3></caption>
  <tr>
    <th><b>.command</b></th>
    <th><b>Description</b></th>
  </tr>
  <tr>
    <td>.op [nick]</td>
    <td>op (+o) a user, or yourself if no nick is specified</td>
  </tr>
  <tr>
    <td>.deop [nick]</td>
    <td>deop (-o) a user, or yourself if no nick is specified</td>
  </tr>
  <tr>
    <td>.kick &lt;nick&gt; [reason]</td>
    <td>kick a user from the channel, default reason is used if not specified</td>
  </tr>
  <tr>
    <td>.ban &lt;nick|host&gt;</td>
    <td>ban a user from the channel without kicking him. (mute)</td>
  </tr>
  <tr>
    <td>.unban &lt;nick|host&gt;</td>
    <td>unban a user from the channel without kicking him. (mute)</td>
  </tr>
  <tr>
    <td>.kban &lt;nick|host&gt;</td>
    <td>kick and ban a user from the channel, default reason is used if not specified</td>
  </tr>
  <tr>
    <td>.perm &lt;nick|host&gt; &lt;reason&gt; </td>
    <td>add a nick|host to the bot's blacklist, you NEED to specify a reason<br>and the user needs to be in the channel.</td>
  </tr>
  <tr>
    <td>.unperm &lt;host&gt; &lt;reason&gt; </td>
    <td>Remove a host from the bot's blacklist and channel. </td>
  </tr>
  <tr>
    <td>.bans</td>
    <td>List all bans on the channel. Sent via /notice</td>
  </tr>
  <tr>
    <td>.invite &lt;nick&gt;</td>
    <td>Makes the bot send an /invite to the specified nick</td>
  </tr>
  <tr>
    <td>.topic &lt;newtopic&gt;</td>
    <td>Change the channel's topic</td>
  </tr>
</table>
<br>
<br>
<table "id="t01">
<caption><h3>Channel managers (+m)</h3></caption>
  <tr>
    <th><b>.command</b></th>
    <th><b>Description</b></th>
  </tr>
  <tr>
    <td>.adduser &lt;handle&gt; &lt;nick!user@host&gt;</td>
    <td>Change the channel's topic</td>
  </tr>
  <tr>
    <td>.deluser &lt;handle&gt;</td>
    <td>removes a user from the bot (cannot remove users with same or higher level)</td>
  </tr>
  <tr>
    <td>.chattr &lt;handle&gt; &lt;+|-flag</td>
    <td>Change a user's flags on the channel.</td>
  </tr>
  <tr>
    <td>.mode &lt;+|-mode&gt;</td>
    <td>Change channel modes</td>
  </tr>
  <tr>
    <td>.say &lt;message&gt;</td>
    <td>make the bot say something in the channel</td>
  </tr>
  <tr>
    <td>.act &lt;message&gt;</td>
    <td>make the bot do an action (/describe) in the channel</td>
  </tr>
  <tr>
    <td>.away &lt;newtopic&gt;</td>
    <td>Change the channel's topic</td>
  </tr>
  <tr>
    <td>.back</td>
    <td>removes the bot's away message</td>
  </tr>
</table>
<br>
<br>
<table "id="t01">
<caption><h3>Bot global managers (+n)<br>Only the owner of the bot should have this flag</h3></caption>
  <tr>
    <td>.rehash</td>
    <td>rehash the bot and reload scripts.</td>
  </tr>
  <tr>
    <td>.restart</td>
    <td>kill and restart the bot completely</td>
  </tr>
  <tr>
    <td>.jump &lt;server.name.to.jump.at&gt;</td>
    <td>make the bot jump on another server<br>This can be used to move the bot on a different network</td>
  </tr>
  <tr>
    <td>.info &lt;text|none&gt;</td>
    <td>set your INFO on the eggdrop, or use <b>none</b> to remove it</td>
  </tr>
  <tr>
    <td>.save</td>
    <td>force the bot to save it's userlist and channel settings</td>
  </tr>
  <tr>
    <td>.global &lt;text&gt;</td>
    <td>make the bot sent a message to all the channels he is parked in.<br>useful for maintenance, but it's spammy..</td>
  </tr>
</table>
<br>
<br>
<a name="installation"><h2>Installation</h2></a>
To install this script you have to copy it to your /scripts/ directory and add <b>source scripts/chancontrol.tcl</b> to the bottom of your eggdrop.conf:<p>
It is recommended not to have too many scripts running on the same bots. Try to use a bot for a task, and another for a different task<p>
For example, Bot1 manages the channel's userlist and day to day operations, Bot2 is for games, Bot3 is for public triggers<p>
Then you can learn how to link them into a botnet to be more effective. Having a bot or 2 on a separate server is also a good idea<p>
<br>
<br>
<a name="contact"><h2>Contact</h2></a>
You can contact me via E-Mail at <a href="mailto:seblemery@gmail.com">seblemery[remove]@[remove]gmail.com</a><br>or catch me on irc usually around 18-24 GMT-5 in #eggdrop or #Sebastien. (Undernet)
<br>
<br>
<a name="disclaimer"><h2>DISCLAIMER</h2></a>
chancontrol.tcl is provided 'as is' and without warranty of any kind.
<br>
<br>
<hr align="CENTER" width="50%">
<center><font size="-1">&copy;2016 by Sebastien@UnderNET, 6/16/2016. <A href="#contact">CONTACT</A></font></center>
<hr align="CENTER" width="80%">
</td></tr>
</body>
</html>
</b>
