/atom
	var/image/demo_last_appearance
/atom/movable
	var/atom/demo_last_loc

/mob/Login()
	. = ..()
	SSdemo.write_event_line("setmob [client.ckey] \ref[src]")

/client/New()
	SSdemo.write_event_line("login [ckey]")
	. = ..()

/client/Del()
	. = ..()
	SSdemo.write_event_line("logout [ckey]")

/turf/set_dir()
	. = ..()
	SSdemo.mark_turf(src)

/atom/movable/set_dir()
	. = ..()
	SSdemo.mark_dirty(src)
