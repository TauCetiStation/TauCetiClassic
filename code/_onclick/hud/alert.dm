/proc/tgui_alert(mob/user, message = null, title = null, list/buttons = list("Ok"), timeout = 0)
	if (!user)
		user = usr
	if (!istype(user))
		if (isclient(user))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_modal/alert = new(user, message, title, buttons, timeout)
	alert.tgui_interact(user)
	alert.wait()
	if (alert)
		. = alert.choice
		qdel(alert)

/**
 * Creates an asynchronous TGUI alert window with an associated callback.
 *
 * This proc should be used to create alerts that invoke a callback with the user's chosen option.
 * Arguments:
 * * user - The user to show the alert to.
 * * message - The content of the alert, shown in the body of the TGUI window.
 * * title - The of the alert modal, shown on the top of the TGUI window.
 * * buttons - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * callback - The callback to be invoked when a choice is made.
 * * timeout - The timeout of the alert, after which the modal will close and qdel itself. Disabled by default, can be set to seconds otherwise.
 */
/proc/tgui_alert_async(mob/user, message = null, title = null, list/buttons = list("Ok"), datum/callback/callback, timeout = 0)
	if (!user)
		user = usr
	if (!istype(user))
		if (!isclient(user))
			return
		var/client/client = user
		user = client.mob

	var/datum/tgui_modal/async/alert = new(user, message, title, buttons, callback, timeout)
	alert.tgui_interact(user)

/**
 * # tgui_modal
 *
 * Datum used for instantiating and using a TGUI-controlled modal that prompts the user with
 * a message and has buttons for responses.
 */
/datum/tgui_modal
	/// The title of the TGUI window
	var/title
	/// The textual body of the TGUI window
	var/message
	/// The list of buttons (responses) provided on the TGUI window
	var/list/buttons
	/// The button that the user has pressed, null if no selection has been made
	var/choice
	/// The time at which the tgui_modal was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_modal, after which the window will close and delete itself.
	var/timeout
	/// Boolean field describing if the tgui_modal was closed by the user.
	var/closed

/datum/tgui_modal/New(mob/user, message, title, list/buttons, timeout)
	src.title = title
	src.message = message
	src.buttons = buttons.Copy()
	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_modal/Destroy(force, ...)
	SStgui.close_uis(src)
	. = ..()

/**
 * Waits for a user's response to the tgui_modal's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_modal/proc/wait()
	while (!choice && !closed)
		stoplag(1)

/datum/tgui_modal/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AlertModal")
		ui.open()

/datum/tgui_modal/tgui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_modal/tgui_state(mob/user)
	return global.always_state

/datum/tgui_modal/tgui_data(mob/user)
	. = list(
		"title" = title,
		"message" = message,
		"buttons" = buttons
	)
	if(timeout)
		.["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))

/datum/tgui_modal/tgui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("choose")
			if (!(params["choice"] in buttons))
				return
			choice = params["choice"]
			SStgui.close_uis(src)
			return TRUE

/**
 * # async tgui_modal
 *
 * An asynchronous version of tgui_modal to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_modal/async
	/// The callback to be invoked by the tgui_modal upon having a choice made.
	var/datum/callback/callback

/datum/tgui_modal/async/New(mob/user, message, title, list/buttons, callback, timeout)
	..(user, title, message, buttons, timeout)
	src.callback = callback

/datum/tgui_modal/async/Destroy(force, ...)
	QDEL_NULL(callback)
	. = ..()

/datum/tgui_modal/async/tgui_close(mob/user)
	. = ..()
	qdel(src)

/datum/tgui_modal/async/tgui_act(action, list/params)
	. = ..()
	if (!. || choice == null)
		return
	callback.InvokeAsync(choice)
	qdel(src)

/datum/tgui_modal/async/wait()
	return

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

	var/atom/movable/screen/alert/thealert
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
		addtimer(CALLBACK(src, PROC_REF(alert_timeout), thealert, category), thealert.timeout)
		thealert.timeout = world.time + thealert.timeout - world.tick_lag
	return thealert

/mob/proc/alert_timeout(atom/movable/screen/alert/alert, category)
	if(alert.timeout && alerts[category] == alert && world.time >= alert.timeout)
		clear_alert(category)

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/atom/movable/screen/alert/alert = alerts[category]
	if(!alert)
		return FALSE
	if(alert.override_alerts && !clear_override)
		return FALSE

	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert
	qdel(alert)
	return TRUE

/atom/movable/screen/alert
	icon = 'icons/hud/screen_alert.dmi'
	icon_state = "default"
	name = "Alert"
	desc = "Something seems to have gone wrong with this alert, so report this bug please"
	mouse_opacity = MOUSE_OPACITY_ICON

	var/timeout = 0 //If set to a number, this alert will clear itself after that many deciseconds
	var/severity = 0
	var/alerttooltipstyle = ""
	var/override_alerts = FALSE //If it is overriding other alerts of the same type
	var/mob/mob_viewer //the mob viewing this alert

/atom/movable/screen/alert/Destroy()
	. = ..()
	severity = 0
	mob_viewer = null
	screen_loc = ""

/mob
	var/list/alerts = list() // contains /atom/movable/screen/alert only // On /mob so clientless mobs will throw alerts properly

/atom/movable/screen/alert/Click(location, control, params)
	if(!usr || !usr.client)
		return
	var/paramslist = params2list(params)
	if(paramslist[SHIFT_CLICK]) // screen objects don't do the normal Click() stuff so we'll cheat
		to_chat(usr, "<span class='boldnotice'>[name]</span> - <span class='info'>[desc]</span>")
		return
	if(master)
		return usr.client.Click(master, location, control, params)

/atom/movable/screen/alert/MouseEntered(location, control, params)
	if(!QDELETED(src))
		openToolTip(usr, src, params, title = name, content = desc, theme = alerttooltipstyle)

/atom/movable/screen/alert/MouseExited()
	closeToolTip(usr)

//Gas alerts
/atom/movable/screen/alert/oxy
	name = "Choking"
	desc = "You're not getting enough oxygen. Find some good air before you pass out! \
			The box in your backpack has an oxygen tank and gas mask in it."
	icon_state = "oxy"

/atom/movable/screen/alert/tox_in_air
	name = "Toxic Gas"
	desc = "There's highly flammable, toxic plasma in the air and you're breathing it in. Find some fresh air. \
			The box in your backpack has an oxygen tank and gas mask in it."
	icon_state = "tox_in_air"
//End gas alerts


/atom/movable/screen/alert/hot
	name = "Too Hot"
	desc = "You're flaming hot! Get somewhere cooler and take off any insulating clothing like a fire suit."
	icon_state = "hot"

/atom/movable/screen/alert/cold
	name = "Too Cold"
	desc = "You're freezing cold! Get somewhere warmer and take off any insulating clothing like a space suit."
	icon_state = "cold"

/atom/movable/screen/alert/lowpressure
	name = "Low Pressure"
	desc = "The air around you is hazardously thin. A space suit would protect you."
	icon_state = "lowpressure"

/atom/movable/screen/alert/highpressure
	name = "High Pressure"
	desc = "The air around you is hazardously thick. A fire suit would protect you."
	icon_state = "highpressure"

/atom/movable/screen/alert/blind
	name = "Blind"
	desc = "For whatever reason, you can't see. This may be caused by a genetic defect, eye trauma, being unconscious, \
			or something covering your eyes."
	icon_state = "blind"

/atom/movable/screen/alert/high
	name = "High"
	desc = "Woah man, you're tripping balls! Careful you don't get addicted to this... if you aren't already."
	icon_state = "high"

/atom/movable/screen/alert/drunk //Not implemented
	name = "Drunk"
	desc = "All that alcohol you've been drinking is impairing your speech, motor skills, and mental cognition. Make sure to act like it."
	icon_state = "drunk"

/atom/movable/screen/alert/embeddedobject
	name = "Embedded Object"
	desc = "Something got lodged into your flesh and is causing major bleeding. It might fall out with time, but surgery is the safest way. \
			If you're feeling frisky, click yourself in help intent to pull the object out."
	icon_state = "embeddedobject"

/atom/movable/screen/alert/weightless
	name = "Weightless"
	desc = "Gravity has ceased affecting you, and you're floating around aimlessly. You'll need something large and heavy, like a \
			wall or lattice strucure, to push yourself off of if you want to move. A jetpack would enable free range of motion. A pair of \
			magboots would let you walk around normally on the floor. Barring those, you can throw things, use a fire extuingisher, \
			or shoot a gun to move around via Newton's 3rd Law of motion."
	icon_state = "weightless"

//ALIENS

/atom/movable/screen/alert/alien_tox
	name = "Plasma"
	desc = "There's flammable plasma in the air. If it lights up, you'll be toast."
	icon_state = "alien_tox"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_fire
// This alert is temporarily gonna be thrown for all hot air but one day it will be used for literally being on fire
	name = "Burning"
	desc = "It's too hot! Flee to space or at least away from the flames. Standing on weeds will heal you up."
	icon_state = "alien_fire"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_embryo
	name = "Медленное развитие эмбриона"
	desc = "Носитель не находится в гнезде. Ваша скорость развития снижена."
	icon_state = "alien_embryo"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_queen
	name = "Низкая скорость роста"
	desc = "Королева вне зоны видимости. Ваша скорость роста снижена."
	icon_state = "alien_queen"
	alerttooltipstyle = "alien"

//BLOBS
/atom/movable/screen/alert/nofactory
	name = "No Factory"
	desc = "You have no factory, and are slowly dying!"
	icon_state = "blobbernaut"

//changeling
/atom/movable/screen/alert/regen_stasis
	name = "Regenerative Stasis"
	desc = "You has entered in stasis. Just wait a little bit."
	icon_state = "regen_stasis"

//IANS
/atom/movable/screen/alert/ian_oxy
	name = "Choking"
	desc = "You're not getting enough oxygen."
	icon_state = "ian_oxy"

/atom/movable/screen/alert/ian_tox
	name = "Gas"
	desc = "There's gas in the air and you're breathing it in."
	icon_state = "ian_tox"

/atom/movable/screen/alert/ian_hot
	name = "Too Hot"
	desc = "You're flaming hot!"
	icon_state = "ian_hot"

/atom/movable/screen/alert/ian_cold
	name = "Too Cold"
	desc = "You're freezing cold!"
	icon_state = "ian_cold"

//SILICONS

/atom/movable/screen/alert/nocell
	name = "Missing Power Cell"
	desc = "Unit has no power cell. No modules available until a power cell is reinstalled. Robotics may provide assistance."
	icon_state = "nocell"

/atom/movable/screen/alert/emptycell
	name = "Out of Power"
	desc = "Unit's power cell has no charge remaining. No modules available until power cell is recharged. \
			Reharging stations are available in robotics, the dormitory's bathrooms. and the AI satelite."
	icon_state = "emptycell"

/atom/movable/screen/alert/lowcell
	name = "Low Charge"
	desc = "Unit's power cell is running low. Reharging stations are available in robotics, the dormitory's bathrooms. and the AI satelite."
	icon_state = "lowcell"

//Need to cover all use cases - emag, illegal upgrade module, malf AI hack, traitor cyborg
/atom/movable/screen/alert/hacked
	name = "Hacked"
	desc = "Hazardous non-standard equipment detected. Please ensure any usage of this equipment is in line with unit's laws, if any."
	icon_state = "hacked"

/atom/movable/screen/alert/not_locked
	name = "Interface Unlocked"
	desc = "Unit's interface has been unlocked. Somebody accidentally or intentionally left it open. Robotics may provide assistance."
	icon_state = "not_locked"

/atom/movable/screen/alert/locked
	name = "Locked Down"
	desc = "Unit has remotely locked down. Usage of a Robotics Control Computer like the one in the Research Director's \
			office by your AI master or any qualified human may resolve this matter. Robotics my provide further assistance if necessary."
	icon_state = "locked"

/atom/movable/screen/alert/newlaw
	name = "Law Update"
	desc = "Laws have potentially been uploaded to or removed from this unit. Please be aware of any changes \
			so as to remain in compliance with the most up-to-date laws."
	icon_state = "newlaw"
	timeout = 300

/atom/movable/screen/alert/swarm_hunger
	name = "Swarm's Hunger"
	desc = "This reality can not support your presence... You must consume to live."
	icon_state = "swarm_hunger"

/atom/movable/screen/alert/swarm_upgrade
	name = "Array Upgrade"
	desc = "There is an array upgrade available. Examine yourself to reflect on prospective adaptabilities."
	icon_state = "swarm_upgrade"

/atom/movable/screen/alert/swarm_upgrade/Click()
	if(!mob_viewer)
		return
	if(mob_viewer.incapacitated())
		return
	if(!mob_viewer.mind)
		return
	if(!isreplicator(mob_viewer))
		return
	var/mob/living/simple_animal/hostile/replicator/R = mob_viewer
	R.acquire_array_upgrade()

//OBJECT-BASED

/atom/movable/screen/alert/buckled
	name = "Buckled"
	desc = "You've been buckled to something and can't move. Click the alert to unbuckle unless you're handcuffed."
	icon_state = "buckled"

/atom/movable/screen/alert/buckled/Click()
	if(!mob_viewer)
		return
	if(mob_viewer.restrained())
		to_chat(mob_viewer, "You are restrained! You need to remove handcuffs first!")
		return
	if(mob_viewer.incapacitated() || mob_viewer.crawling || mob_viewer.is_busy())
		return
	master.user_unbuckle_mob(mob_viewer)

/atom/movable/screen/alert/brake
	name = "Brake is on"
	desc = "Wheelchair's brake is on right now, so you can't move."
	icon_state = "brake"

/atom/movable/screen/alert/handcuffed // Not used right now.
	name = "Handcuffed"
	desc = "You're handcuffed and can't act. If anyone drags you, you won't be able to move. Click the alert to free yourself."


/atom/movable/screen/alert/notify_action
	name = "Body created"
	desc = "A body was created. You can enter it."
	icon_state = "template"
	timeout = 300
	var/atom/target = null
	var/action = NOTIFY_JUMP

/atom/movable/screen/alert/notify_action/Click()
	. = ..()
	if(!target)
		return
	var/mob/dead/observer/ghost_owner = mob_viewer
	if(!istype(ghost_owner))
		return
	switch(action)
		if(NOTIFY_ATTACK)
			target.attack_ghost(ghost_owner)
		if(NOTIFY_JUMP)
			var/turf/target_turf = get_turf(target)
			if(target_turf && isturf(target_turf))
				ghost_owner.abstract_move(target_turf)
		if(NOTIFY_ORBIT)
			ghost_owner.ManualFollow(target)

// PRIVATE = only edit, use, or override these if you're editing the system as a whole

// Re-render all alerts - also called in /datum/hud/show_hud() because it's needed there
/datum/hud/proc/reorganize_alerts()
	var/list/alerts = mymob.alerts
	if(!hud_shown)
		for(var/i = 1, i <= alerts.len, i++)
			mymob.client.screen -= alerts[alerts[i]]
		return TRUE
	for(var/i = 1, i <= alerts.len, i++)
		var/atom/movable/screen/alert/alert = alerts[alerts[i]]
		if(alert.icon_state == "template")
			if(ui_style)
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
	return TRUE
