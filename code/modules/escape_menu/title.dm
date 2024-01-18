// This doesn't instantiate right away
var/global/atom/movable/screen/escape_menu/title/escape_menu_title

/// Provides a singleton for the escape menu details screen.
/proc/give_escape_menu_title()
	if (isnull(global.escape_menu_title))
		global.escape_menu_title = new

	return global.escape_menu_title

/atom/movable/screen/escape_menu/title
	screen_loc = "NORTH:-100,WEST:32"
	maptext_height = 100
	maptext_width = 500

/atom/movable/screen/escape_menu/title/atom_init(mapload, datum/hud/hud_owner)
	. = ..()
	update_text()

/atom/movable/screen/escape_menu/title/Destroy()
	if (global.escape_menu_title == src)
		stack_trace("Something tried to delete the escape menu details screen")
		return QDEL_HINT_LETMELIVE

	return ..()

/atom/movable/screen/escape_menu/title/proc/update_text()
	var/subtitle_text = MAPTEXT("<span style='font-size: 8px'>Ещё один день на...</span>")
	var/title_text = {"
		<span style='font-weight: bolder; font-size: 24px'>
			[station_name_ru()]
		</span>
	"}
	maptext = "<font align='top'>" + subtitle_text + title_text + "</font>"
