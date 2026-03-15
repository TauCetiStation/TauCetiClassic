/obj/item/device/radio/intercom/pod
	name = "station intercom"
	cases = list("интерком станции", "интеркома станции", "интеркому станции", "интерком станции", "интеркомом станции", "интеркоме станции")
	icon = 'icons/locations/shuttles/intercom.dmi'
	icon_state = "intercom"
	var/emagged = FALSE

/obj/item/device/radio/intercom/pod/emag_act(mob/user)
	if(emagged)
		return FALSE
	to_chat(user, "<span class='notice'>On the small screen you see a message:</span><span class='warning'> Launch is possible without an activated evacuation system; a better route has been selected. Have a nice flight, Agent Doe!</span>")
	playsound(src, 'sound/effects/sparks4.ogg', VOL_EFFECTS_MASTER)
	emagged = TRUE
