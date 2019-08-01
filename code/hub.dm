/world

	hub = "Exadv1.spacestation13"
	hub_password = "kMZy3U5jJHSiBQjr"
	name = "Tau Ceti Station"
/* This is for any host that would like their server to appear on the main SS13 hub.
To use it, simply replace the password above, with the password found below, and it should work.
If not, let us know on the main tgstation IRC channel of irc.rizon.net #tgstation13 we can help you there.

	hub = "Exadv1.spacestation13"
	hub_password = "kMZy3U5jJHSiBQjr"
	name = "Space Station 13"
*/

var/hub_visibility = TRUE

/world/proc/update_hub_visibility(new_visibility)
	if(new_visibility == hub_visibility)
		return
	hub_visibility = new_visibility
	if(hub_visibility)
		hub_password = "kMZy3U5jJHSiBQjr"
	else
		hub_password = "SORRYNOPASSWORD"
