
/datum/hud/proc/unplayer_hud()
	return

/datum/hud/proc/brain_hud()
	mymob.client.screen = list()
	mymob.client.screen += mymob.client.void

/datum/hud/proc/blob_hud()

	blobpwrdisplay = new /obj/screen()
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.layer = ABOVE_HUD_LAYER
	blobpwrdisplay.plane = ABOVE_HUD_PLANE

	blobhealthdisplay = new /obj/screen()
	blobhealthdisplay.name = "blob health"
	blobhealthdisplay.icon_state = "block"
	blobhealthdisplay.screen_loc = ui_internal
	blobpwrdisplay.layer = ABOVE_HUD_LAYER
	blobpwrdisplay.plane = ABOVE_HUD_PLANE

	mymob.client.screen = list()
	mymob.client.screen += list(blobpwrdisplay, blobhealthdisplay)
	mymob.client.screen += mymob.client.void


/datum/hud/proc/changeling_essence_hud()
	var/mob/living/parasite/essence/E = mymob

	E.voice = new /obj/screen/essence_voice()
	E.voice.name = "Voice"
	E.voice.icon = 'icons/mob/screen_gen.dmi'
	E.voice.icon_state = "phantom_[E.self_voice ? "on" : "off"]"
	E.voice.icon_state = "voice_off"
	E.voice.screen_loc = ui_rhand
	E.voice.layer = ABOVE_HUD_LAYER
	E.voice.plane = ABOVE_HUD_PLANE

	E.phantom_s = new /obj/screen/essence_phantom()
	E.phantom_s.name = "Phantom"
	E.phantom_s.icon = 'icons/mob/screen_gen.dmi'
	E.phantom_s.icon_state = "phantom_[(E.phantom && E.phantom.showed) ? "on" : "off"]"
	E.phantom_s.screen_loc = ui_lhand
	E.phantom_s.layer = ABOVE_HUD_LAYER
	E.phantom_s.plane = ABOVE_HUD_PLANE

	mymob.internals = new /obj/screen()
	mymob.internals.icon = ui_style
	mymob.internals.icon_state = "internal0"
	mymob.internals.name = "internal"
	mymob.internals.screen_loc = ui_internal

	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen_gen.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.healthdoll = new /obj/screen()
	mymob.healthdoll.icon = 'icons/mob/screen_gen.dmi'
	mymob.healthdoll.name = "health doll"
	mymob.healthdoll.screen_loc = ui_healthdoll

	lingchemdisplay = new /obj/screen()
	lingchemdisplay.icon = 'icons/mob/screen_gen.dmi'
	lingchemdisplay.name = "chemical storage"
	lingchemdisplay.icon_state = "power_display"
	lingchemdisplay.screen_loc = ui_lingchemdisplay
	lingchemdisplay.layer = ABOVE_HUD_LAYER
	lingchemdisplay.plane = ABOVE_HUD_PLANE

	var/obj/screen/using = new /obj/screen/ling_abilities()
	using.icon = 'icons/mob/screen_gen.dmi'
	using.icon_state = "power_list"
	using.name = "Host Abilities"
	using.screen_loc = ui_belt
	mymob.client.screen += using

	mymob.client.screen = list(mymob.internals, mymob.healths, mymob.healthdoll, E.voice, E.phantom_s, using)
	mymob.client.screen += mymob.client.void
	if(E.is_changeling)
		using = new /obj/screen/return_to_body()
		using.icon = 'icons/mob/screen1.dmi'
		using.icon_state = "facingOLD"
		using.name = "Return to Body"
		using.screen_loc = ui_zonesel
		mymob.client.screen += using

/obj/screen/essence_voice/Click(location, control, params)
	var/mob/living/parasite/essence/E = usr
	if(!E.host)
		return
	if(!(E.flags_allowed & ESSENCE_SELF_VOICE))
		to_chat(E, "<span class='userdanger'>Your host forbade you speaking with your voice.</span>")
		return
	if(E.self_voice)
		icon_state = "voice_off"
	else
		icon_state = "voice_on"
	E.self_voice = !E.self_voice

/obj/screen/essence_phantom/Click(location, control, params)
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

/obj/screen/return_to_body/Click(location, control, params)
	var/mob/living/parasite/essence/E = usr
	if(!E.host)
		return
	E.host.delegate_body_to_essence()

/obj/screen/ling_abilities/Click(location, control, params)
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

