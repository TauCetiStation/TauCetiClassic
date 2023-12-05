// This doesn't instantiate right away, since we rely on other GLOBs
var/global/atom/movable/screen/escape_menu/details/escape_menu_details

/// Provides a singleton for the escape menu details screen.
/proc/give_escape_menu_details()
	if (isnull(global.escape_menu_details))
		global.escape_menu_details = new

	return global.escape_menu_details

/atom/movable/screen/escape_menu/details
	screen_loc = "EAST:-180,NORTH:-25"
	maptext_height = 100
	maptext_width = 200

/atom/movable/screen/escape_menu/details/atom_init(mapload, datum/hud/hud_owner)
	. = ..()

	update_text()
	START_PROCESSING(SSescape_menu, src)

/atom/movable/screen/escape_menu/details/Destroy()
	if (global.escape_menu_details == src)
		stack_trace("Something tried to delete the escape menu details screen")
		return QDEL_HINT_LETMELIVE

	STOP_PROCESSING(SSescape_menu, src)
	return ..()

/atom/movable/screen/escape_menu/details/process(seconds_per_tick)
	update_text()

/atom/movable/screen/escape_menu/details/proc/update_text()
	var/new_maptext = {"
		<span style='text-align: right; line-height: 0.7'>
			Round ID: [global.round_id || "Unset"]<br />
			Round Time: [worldtime2text()]<br />
			Map: [SSmapping.config?.map_name || "Loading..."]<br />
		</span>
	"}

	//		Time Dilation: [round(SStime_track.time_dilation_current,1)]%<br />
	maptext = MAPTEXT(new_maptext)
