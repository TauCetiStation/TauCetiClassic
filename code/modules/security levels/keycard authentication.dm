/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	var/active = 0 //This gets set to 1 on all devices except the one where the initial request was made.
	var/event = ""
	var/screen = 1
	var/confirmed = 0 //This variable is set by the device that confirms the request.
	var/confirm_delay = 20 //(2 seconds)
	var/busy = 0 //Busy when waiting for authentication or an event request has been sent from this device.
	var/obj/machinery/keycard_auth/event_source
	var/mob/event_triggered_by
	var/mob/event_confirmed_by
	//1 = select event
	//2 = authenticate
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = STATIC_ENVIRON

/obj/machinery/keycard_auth/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()
	to_chat(user, "The station AI is not to interact with these devices.")

/obj/machinery/keycard_auth/attack_paw(mob/user)
	to_chat(user, "You are too primitive to use this device.")
	return

/obj/machinery/keycard_auth/attackby(obj/item/weapon/W, mob/user)
	if(stat & (NOPOWER|BROKEN))
		to_chat(user, "This device is not powered.")
		return
	if(istype(W,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/ID = W
		if(access_keycard_auth in ID.access)
			if(active == 1)
				//This is not the device that made the initial request. It is the device confirming the request.
				if(event_source)
					event_source.confirmed = 1
					event_source.event_confirmed_by = usr
			else if(screen == 2)
				event_triggered_by = usr
				broadcast_request() //This is the device making the initial event request. It needs to broadcast to other devices

/obj/machinery/keycard_auth/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
		icon_state = "auth_off"
	else
		stat |= NOPOWER
	update_power_use()

/obj/machinery/keycard_auth/ui_interact(mob/user)
	if(stat & (NOPOWER|BROKEN))
		to_chat(user, "This device is not powered.")
		return
	if(busy)
		to_chat(user, "This device is busy.")
		return

	var/dat = "<h1>Keycard Authentication Device</h1>"

	dat += "This device is used to trigger some high security events. It requires the simultaneous swipe of two high-level ID cards."
	dat += "<br><hr><br>"

	if(screen == 1)
		dat += "Select an event to trigger:<ul>"
		dat += "<li><A href='?src=\ref[src];triggerevent=Red alert'>Red alert</A></li>"
		if(!config.ert_admin_call_only)
			dat += "<li><A href='?src=\ref[src];triggerevent=Emergency Response Team'>Emergency Response Team</A></li>"

		dat += "<li><A href='?src=\ref[src];triggerevent=Grant Emergency Maintenance Access'>Grant Emergency Maintenance Access</A></li>"
		dat += "<li><A href='?src=\ref[src];triggerevent=Revoke Emergency Maintenance Access'>Revoke Emergency Maintenance Access</A></li>"
		dat += "</ul>"
		user << browse(entity_ja(dat), "window=keycard_auth;size=500x250")
	if(screen == 2)
		dat += "Please swipe your card to authorize the following event: <b>[event]</b>"
		dat += "<p><A href='?src=\ref[src];reset=1'>Back</A>"
		user << browse(entity_ja(dat), "window=keycard_auth;size=500x250")


/obj/machinery/keycard_auth/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(busy)
		to_chat(usr, "This device is busy.")
		return
	if(href_list["triggerevent"])
		event = href_list["triggerevent"]
		screen = 2
	if(href_list["reset"])
		reset()

	updateUsrDialog()


/obj/machinery/keycard_auth/proc/reset()
	active = 0
	event = ""
	screen = 1
	confirmed = 0
	event_source = null
	icon_state = "auth_off"
	event_triggered_by = null
	event_confirmed_by = null

/obj/machinery/keycard_auth/proc/broadcast_request()
	icon_state = "auth_on"
	for(var/obj/machinery/keycard_auth/KA in machines)
		if(KA == src) continue
		KA.reset()
		spawn()
			KA.receive_request(src)

	sleep(confirm_delay)
	if(confirmed)
		confirmed = 0
		trigger_event(event)
		log_game("[key_name(event_triggered_by)] triggered and [key_name(event_confirmed_by)] confirmed event [event]")
		message_admins("[key_name(event_triggered_by)] triggered and [key_name(event_confirmed_by)] confirmed event [event]")
	reset()

/obj/machinery/keycard_auth/proc/receive_request(obj/machinery/keycard_auth/source)
	if(stat & (BROKEN|NOPOWER))
		return
	event_source = source
	busy = 1
	active = 1
	icon_state = "auth_on"

	sleep(confirm_delay)

	event_source = null
	icon_state = "auth_off"
	active = 0
	busy = 0

/obj/machinery/keycard_auth/proc/trigger_event()
	switch(event)
		if("Red alert")
			set_security_level(SEC_LEVEL_RED)
			feedback_inc("alert_keycard_auth_red",1)
		if("Grant Emergency Maintenance Access")
			make_maint_all_access(TRUE)
			feedback_inc("alert_keycard_auth_maintGrant",1)
		if("Revoke Emergency Maintenance Access")
			if(timer_maint_revoke_id)
				deltimer(timer_maint_revoke_id)
				timer_maint_revoke_id = 0
			revoke_maint_all_access(TRUE)
			feedback_inc("alert_keycard_auth_maintRevoke",1)
		if("Emergency Response Team")
			if(is_ert_blocked())
				to_chat(usr, "<span class='warning'>All emergency response teams are dispatched and can not be called at this time.</span>")
				return

			trigger_armed_response_team(1)
			feedback_inc("alert_keycard_auth_ert",1)

/obj/machinery/keycard_auth/proc/is_ert_blocked()
	if(config.ert_admin_call_only) return 1
	return ticker.mode && ticker.mode.ert_disabled

var/global/maint_all_access_priority = FALSE    // Set only by keycard auth. If true, maint
                                                // access  can be revoked only by calling revoke_maint_all_access(TRUE) (this doing keycard auth)
var/global/timer_maint_revoke_id = 0

/proc/make_maint_all_access(var/priority = FALSE)
	if(priority)
		maint_all_access_priority = TRUE

	change_maintenance_access(TRUE)
	captain_announce("The maintenance access requirement has been revoked on all airlocks.")

/proc/revoke_maint_all_access(var/priority = FALSE)
	if(priority)
		maint_all_access_priority = FALSE
	if(maint_all_access_priority)	// We must use keycard auth
		return

	change_maintenance_access(FALSE)
	captain_announce("The maintenance access requirement has been readded on all maintenance airlocks.")

/proc/change_maintenance_access(allow_state)
	for(var/area/maintenance/M in all_areas)
		for(var/obj/machinery/door/airlock/A in M)
			A.emergency = allow_state
			A.update_icon()
