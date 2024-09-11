// Essence
/atom/movable/screen/essence
	icon = 'icons/hud/screen_gen.dmi'
	plane = ABOVE_HUD_PLANE

	copy_flags = NONE

/atom/movable/screen/essence/voice
	name = "Voice"
	screen_loc = ui_rhand

/atom/movable/screen/essence/voice/update_icon(mob/living/parasite/essence/mymob)
	icon_state = "voice_[mymob.self_voice ? "on" : "off"]"

/atom/movable/screen/essence/voice/add_to_hud(datum/hud/hud)
	..()
	var/mob/living/parasite/essence/E = hud.mymob
	E.voice = src
	update_icon(hud.mymob)

/atom/movable/screen/essence/voice/action()
	var/mob/living/parasite/essence/E = usr
	if(!E.host)
		return
	if(!(E.flags_allowed & ESSENCE_SELF_VOICE))
		to_chat(E, "<span class='userdanger'>Your host forbade you speaking with your voice.</span>")
		return
	E.self_voice = !E.self_voice
	update_icon(usr)

/atom/movable/screen/essence/phantom
	name = "Phantom"
	screen_loc = ui_lhand

/atom/movable/screen/essence/phantom/update_icon(mob/living/parasite/essence/mymob)
	icon_state =  "phantom_[(mymob.phantom?.showed) ? "on" : "off"]"

/atom/movable/screen/essence/phantom/add_to_hud(datum/hud/hud)
	..()
	var/mob/living/parasite/essence/E = hud.mymob
	E.phantom_s = src
	update_icon(hud.mymob)

/atom/movable/screen/essence/phantom/action()
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

/atom/movable/screen/essence/ling_abilities
	name = "Host Abilities"
	icon_state = "power_list"
	screen_loc = ui_belt

/atom/movable/screen/essence/ling_abilities/action()
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

/atom/movable/screen/essence/return_to_body
	name = "Return to Body"
	icon_state = "facingOLD"
	screen_loc = ui_zonesel

/atom/movable/screen/essence/return_to_body/action()
	var/mob/living/parasite/essence/E = usr
	if(!E.host)
		return
	E.host.delegate_body_to_essence()
