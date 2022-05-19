/datum/hud/proc/unplayer_hud()
	return


/atom/movable/screen/blob_power
	name = "blob power"
	icon_state = "block"
	screen_loc = ui_health
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/blob_health
	name = "blob health"
	icon_state = "block"
	screen_loc = ui_internal
	plane = ABOVE_HUD_PLANE


/datum/hud/proc/brain_hud()
	return

/datum/hud/proc/blob_hud()
	blobpwrdisplay = new /atom/movable/screen/blob_power
	blobhealthdisplay = new /atom/movable/screen/blob_health

	adding += list(blobpwrdisplay, blobhealthdisplay)

/atom/movable/screen/essence_voice
	name = "Voice"
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = ui_rhand
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/essence_voice/update_icon(mob/living/parasite/essence/mymob)
	icon_state = "voice_[mymob.self_voice ? "on" : "off"]"

/atom/movable/screen/essence_voice/add_to_hud(datum/hud/hud)
	. = ..()
	update_icon(hud.mymob)

/atom/movable/screen/essence_voice/action()
	var/mob/living/parasite/essence/E = usr
	if(!E.host)
		return
	if(!(E.flags_allowed & ESSENCE_SELF_VOICE))
		to_chat(E, "<span class='userdanger'>Your host forbade you speaking with your voice.</span>")
		return
	E.self_voice = !E.self_voice
	update_icon(usr)

/atom/movable/screen/essence_phantom
	name = "Phantom"
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = ui_lhand
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/essence_phantom/update_icon(mob/living/parasite/essence/mymob)
	icon_state =  "phantom_[(mymob.phantom?.showed) ? "on" : "off"]"

/atom/movable/screen/essence_phantom/add_to_hud(datum/hud/hud)
	. = ..()
	update_icon(hud.mymob)

/atom/movable/screen/essence_phantom/action()
	var/mob/living/parasite/essence/E = usr
	if(!E.host)
		return
	if(!(E.flags_allowed & ESSENCE_PHANTOM))
		to_chat(E, "<span class='userdanger'>Your host forbade you own phantom.</span>")
		return
	if(E.phantom.showed)
		E.phantom.hide_phantom()
	else
		E.phantom.show_phantom()

/atom/movable/screen/ling_abilities
	name = "Host Abilities"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "power_list"
	screen_loc = ui_belt

/atom/movable/screen/ling_abilities/action()
	var/mob/living/parasite/essence/E = usr
	if(!E.host || !E.changeling)
		return
	var/dat = ""
	for(var/obj/effect/proc_holder/changeling/P in E.changeling.purchasedpowers)
		if(P.genomecost < 1)
			continue
		dat += "[P.name]<br>"
	var/datum/browser/popup = new(E, "ling_abilities", "Host Abilities", 140)
	popup.set_content(dat)
	popup.open()

/atom/movable/screen/return_to_body
	name = "Return to Body"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "facingOLD"
	screen_loc = ui_zonesel

/atom/movable/screen/return_to_body/action()
	var/mob/living/parasite/essence/E = usr
	if(!E.host)
		return
	E.host.delegate_body_to_essence()


/datum/hud/proc/changeling_essence_hud()
	var/mob/living/parasite/essence/E = mymob

	add_essence_voice()
	add_phantom()

	add_internals()
	add_healths()
	add_health_doll()
	add_changeling()

	adding += new /atom/movable/screen/ling_abilities

	if(E.is_changeling)
		adding += new /atom/movable/screen/return_to_body
