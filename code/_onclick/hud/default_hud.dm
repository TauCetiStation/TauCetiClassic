/datum/hud/proc/default_hud(ui_color = "#ffffff", ui_alpha = 255)
	src.adding = list()
	src.other = list()
	src.hotkeybuttons = list() //These can be disabled for hotkey usersx

	var/atom/movable/screen/using

	using = new /atom/movable/screen/act_intent()
	using.icon = ui_style
	using.update_icon(mymob)
	src.adding += using
	action_intent = using

	using = new /atom/movable/screen/inventory/craft
	src.adding += using

//intent small hud objects
	using = new /atom/movable/screen/intent/help()
	using.update_icon(ui_style)
	src.adding += using
	help_intent = using

	using = new /atom/movable/screen/intent/push()
	using.update_icon(ui_style)
	src.adding += using
	push_intent = using

	using = new /atom/movable/screen/intent/grab()
	using.update_icon(ui_style)
	src.adding += using
	grab_intent = using

	using = new /atom/movable/screen/intent/harm()
	using.update_icon(ui_style)
	src.adding += using
	harm_intent = using

//end intent small hud objects

	using = new /atom/movable/screen/move_intent()
	using.icon = ui_style
	using.update_icon(mymob)
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using
	move_intent = using

	mymob.zone_sel = new /atom/movable/screen/zone_sel( null )
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.color = ui_color
	mymob.zone_sel.alpha = ui_alpha
	mymob.zone_sel.overlays.Cut()
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.get_targetzone()]")

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)
	src.hotkeybuttons += mymob.pullin

	lingchemdisplay = new /atom/movable/screen()
	lingchemdisplay.icon = 'icons/mob/screen_gen.dmi'
	lingchemdisplay.name = "chemical storage"
	lingchemdisplay.icon_state = "power_display"
	lingchemdisplay.screen_loc = ui_lingchemdisplay
	lingchemdisplay.plane = ABOVE_HUD_PLANE
	lingchemdisplay.invisibility = INVISIBILITY_ABSTRACT


	mymob.client.screen = list()

	mymob.client.screen += list(mymob.zone_sel)
	mymob.client.screen += src.adding + src.hotkeybuttons
	inventory_shown = 0
