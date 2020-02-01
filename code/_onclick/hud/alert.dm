//A system to manage and display alerts on screen without needing you to do it yourself

//PUBLIC -  call these wherever you want


/mob/proc/throw_alert(category, type, severity, obj/new_master, override = FALSE)

/* Proc to create or update an alert. Returns the alert if the alert is new or updated, 0 if it was thrown already
 category is a text string. Each mob may only have one alert per category; the previous one will be replaced
 path is a type path of the actual alert type to throw
 severity is an optional number that will be placed at the end of the icon_state for this alert
 For example, high pressure's icon_state is "highpressure" and can be serverity 1 or 2 to get "highpressure1" or "highpressure2"
 new_master is optional and sets the alert's icon state to "template" in the ui_style icons with the master as an overlay.
 Clicks are forwarded to master
 Override makes it so the alert is not replaced until cleared by a clear_alert with clear_override, and it's used for hallucinations.
 */

	if(!category || QDELETED(src))
		return

	var/obj/screen/alert/thealert
	if(alerts[category])
		thealert = alerts[category]
		if(thealert.override_alerts)
			return 0
		if(new_master && new_master != thealert.master)
			WARNING("[src] threw alert [category] with new_master [new_master] while already having that alert with master [thealert.master]")

			clear_alert(category)
			return .()
		else if(thealert.type != type)
			clear_alert(category)
			return .()
		else if(!severity || severity == thealert.severity)
			if(thealert.timeout)
				clear_alert(category)
				return .()
			else //no need to update
				return 0
	else
		thealert = new type()
		thealert.override_alerts = override
		if(override)
			thealert.timeout = null
	thealert.mob_viewer = src

	if(new_master)
		var/old_layer = new_master.layer
		var/old_plane = new_master.plane
		new_master.layer = FLOAT_LAYER
		new_master.plane = FLOAT_PLANE
		thealert.add_overlay(new_master)
		new_master.layer = old_layer
		new_master.plane = old_plane
		thealert.icon_state = "template" // We'll set the icon to the client's ui pref in reorganize_alerts()
		thealert.master = new_master
	else
		thealert.icon_state = "[initial(thealert.icon_state)][severity]"
		thealert.severity = severity

	alerts[category] = thealert
	if(client && hud_used)
		hud_used.reorganize_alerts()
	thealert.transform = matrix(32, 6, MATRIX_TRANSLATE)
	animate(thealert, transform = matrix(), time = 2.5, easing = CUBIC_EASING)

	if(thealert.timeout)
		addtimer(CALLBACK(src, .proc/alert_timeout, thealert, category), thealert.timeout)
		thealert.timeout = world.time + thealert.timeout - world.tick_lag
	return thealert

/mob/proc/alert_timeout(obj/screen/alert/alert, category)
	if(alert.timeout && alerts[category] == alert && world.time >= alert.timeout)
		clear_alert(category)

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/obj/screen/alert/alert = alerts[category]
	if(!alert)
		return 0
	if(alert.override_alerts && !clear_override)
		return 0

	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert
	qdel(alert)

/obj/screen/alert
	icon = 'icons/mob/screen_alert.dmi'
	icon_state = "default"
	name = "Alert"
	desc = "Something seems to have gone wrong with this alert, so report this bug please"
	mouse_opacity = MOUSE_OPACITY_ICON

	var/timeout = 0 //If set to a number, this alert will clear itself after that many deciseconds
	var/severity = 0
	var/alerttooltipstyle = ""
	var/override_alerts = FALSE //If it is overriding other alerts of the same type
	var/mob/mob_viewer //the mob viewing this alert

/obj/screen/alert/Destroy()
	. = ..()
	severity = 0
	mob_viewer = null
	screen_loc = ""


/obj/screen/alert/MouseEntered(location, control, params)
	if(!QDELETED(src))
		openToolTip(usr, src, params, title = name, content = desc, theme = alerttooltipstyle)

/obj/screen/alert/MouseExited()
	closeToolTip(usr)

//Gas alerts
/obj/screen/alert/oxy
	name = "Choking"
	desc = "You're not getting enough oxygen. Find some good air before you pass out! \
			The box in your backpack has an oxygen tank and gas mask in it."
	icon_state = "oxy"

/obj/screen/alert/tox_in_air
	name = "Toxic Gas"
	desc = "There's highly flammable, toxic plasma in the air and you're breathing it in. Find some fresh air. \
			The box in your backpack has an oxygen tank and gas mask in it."
	icon_state = "tox_in_air"
//End gas alerts


/obj/screen/alert/hot
	name = "Too Hot"
	desc = "You're flaming hot! Get somewhere cooler and take off any insulating clothing like a fire suit."
	icon_state = "hot"

/obj/screen/alert/cold
	name = "Too Cold"
	desc = "You're freezing cold! Get somewhere warmer and take off any insulating clothing like a space suit."
	icon_state = "cold"

/obj/screen/alert/lowpressure
	name = "Low Pressure"
	desc = "The air around you is hazardously thin. A space suit would protect you."
	icon_state = "lowpressure"

/obj/screen/alert/highpressure
	name = "High Pressure"
	desc = "The air around you is hazardously thick. A fire suit would protect you."
	icon_state = "highpressure"

/obj/screen/alert/blind
	name = "Blind"
	desc = "For whatever reason, you can't see. This may be caused by a genetic defect, eye trauma, being unconscious, \
			or something covering your eyes."
	icon_state = "blind"

/obj/screen/alert/high
	name = "High"
	desc = "Woah man, you're tripping balls! Careful you don't get addicted to this... if you aren't already."
	icon_state = "high"

/obj/screen/alert/drunk //Not implemented
	name = "Drunk"
	desc = "All that alcohol you've been drinking is impairing your speech, motor skills, and mental cognition. Make sure to act like it."
	icon_state = "drunk"

/obj/screen/alert/embeddedobject
	name = "Embedded Object"
	desc = "Something got lodged into your flesh and is causing major bleeding. It might fall out with time, but surgery is the safest way. \
			If you're feeling frisky, click yourself in help intent to pull the object out."
	icon_state = "embeddedobject"

/obj/screen/alert/weightless
	name = "Weightless"
	desc = "Gravity has ceased affecting you, and you're floating around aimlessly. You'll need something large and heavy, like a \
			wall or lattice strucure, to push yourself off of if you want to move. A jetpack would enable free range of motion. A pair of \
			magboots would let you walk around normally on the floor. Barring those, you can throw things, use a fire extuingisher, \
			or shoot a gun to move around via Newton's 3rd Law of motion."
	icon_state = "weightless"

//ALIENS

/obj/screen/alert/alien_tox
	name = "Plasma"
	desc = "There's flammable plasma in the air. If it lights up, you'll be toast."
	icon_state = "alien_tox"
	alerttooltipstyle = "alien"

/obj/screen/alert/alien_fire
// This alert is temporarily gonna be thrown for all hot air but one day it will be used for literally being on fire
	name = "Burning"
	desc = "It's too hot! Flee to space or at least away from the flames. Standing on weeds will heal you up."
	icon_state = "alien_fire"
	alerttooltipstyle = "alien"

/obj/screen/alert/regen_stasis
	name = "Regenerative Stasis"
	desc = "You has entered in statis. Just wait a little bit."
	icon_state = "regen_stasis"

//IANS
/obj/screen/alert/ian_oxy
	name = "Choking"
	desc = "You're not getting enough oxygen."
	icon_state = "ian_oxy"

/obj/screen/alert/ian_tox
	name = "Gas"
	desc = "There's gas in the air and you're breathing it in."
	icon_state = "ian_tox"

/obj/screen/alert/ian_hot
	name = "Too Hot"
	desc = "You're flaming hot!"
	icon_state = "ian_hot"

/obj/screen/alert/ian_cold
	name = "Too Cold"
	desc = "You're freezing cold!"
	icon_state = "ian_cold"

//SILICONS

/obj/screen/alert/nocell
	name = "Missing Power Cell"
	desc = "Unit has no power cell. No modules available until a power cell is reinstalled. Robotics may provide assistance."
	icon_state = "nocell"

/obj/screen/alert/emptycell
	name = "Out of Power"
	desc = "Unit's power cell has no charge remaining. No modules available until power cell is recharged. \
			Reharging stations are available in robotics, the dormitory's bathrooms. and the AI satelite."
	icon_state = "emptycell"

/obj/screen/alert/lowcell
	name = "Low Charge"
	desc = "Unit's power cell is running low. Reharging stations are available in robotics, the dormitory's bathrooms. and the AI satelite."
	icon_state = "lowcell"

//Need to cover all use cases - emag, illegal upgrade module, malf AI hack, traitor cyborg
/obj/screen/alert/hacked
	name = "Hacked"
	desc = "Hazardous non-standard equipment detected. Please ensure any usage of this equipment is in line with unit's laws, if any."
	icon_state = "hacked"

/obj/screen/alert/locked
	name = "Locked Down"
	desc = "Unit has remotely locked down. Usage of a Robotics Control Computer like the one in the Research Director's \
			office by your AI master or any qualified human may resolve this matter. Robotics my provide further assistance if necessary."
	icon_state = "locked"

/obj/screen/alert/newlaw
	name = "Law Update"
	desc = "Laws have potentially been uploaded to or removed from this unit. Please be aware of any changes \
			so as to remain in compliance with the most up-to-date laws."
	icon_state = "newlaw"
	timeout = 300

//OBJECT-BASED

/obj/screen/alert/buckled
	name = "Buckled"
	desc = "You've been buckled to something and can't move. Click the alert to unbuckle unless you're handcuffed."
	icon_state = "buckled"

/obj/screen/alert/brake
	name = "Brake is on"
	desc = "Wheelchair's brake is on right now, so you can't move."
	icon_state = "brake"

/obj/screen/alert/handcuffed // Not used right now.
	name = "Handcuffed"
	desc = "You're handcuffed and can't act. If anyone drags you, you won't be able to move. Click the alert to free yourself."

// PRIVATE = only edit, use, or override these if you're editing the system as a whole

// Re-render all alerts - also called in /datum/hud/show_hud() because it's needed there
/datum/hud/proc/reorganize_alerts()
	var/list/alerts = mymob.alerts
	if(!hud_shown)
		for(var/i = 1, i <= alerts.len, i++)
			mymob.client.screen -= alerts[alerts[i]]
		return 1
	for(var/i = 1, i <= alerts.len, i++)
		var/obj/screen/alert/alert = alerts[alerts[i]]
		if(alert.icon_state == "template")
			alert.icon = ui_style
		switch(i)
			if(1)
				. = ui_alert1
			if(2)
				. = ui_alert2
			if(3)
				. = ui_alert3
			if(4)
				. = ui_alert4
			if(5)
				. = ui_alert5 // Right now there's 5 slots
			else
				. = ""
		alert.screen_loc = .
		mymob.client.screen |= alert
	return 1

/mob
	var/list/alerts = list() // contains /obj/screen/alert only // On /mob so clientless mobs will throw alerts properly

/obj/screen/alert/Click(location, control, params)
	if(!usr || !usr.client)
		return
	var/paramslist = params2list(params)
	if(paramslist["shift"]) // screen objects don't do the normal Click() stuff so we'll cheat
		to_chat(usr, "<span class='boldnotice'>[name]</span> - <span class='info'>[desc]</span>")
		return
	if(master)
		return usr.client.Click(master, location, control, params)
