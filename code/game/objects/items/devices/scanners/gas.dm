// radiation dose per second
#define SAFE_DOSE 5
#define HEALTH_EFFECT_DOSE 7.5
#define DANGEROUS_DOSE 10

var/global/list/geiger_items_list = list()

ADD_TO_GLOBAL_LIST(/obj/item/device/analyzer, geiger_items_list)
/obj/item/device/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels and radiation."
	name = "analyzer"
	icon_state = "atmos"
	item_state = "multitool"
	w_class = SIZE_TINY
	flags = CONDUCT | NOBLUDGEON | NOATTACKANIMATION
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=1;engineering=1"

	var/status
	var/last_rad_signal = 0
	var/last_distance = 0

	var/advanced_mode = 0
	COOLDOWN_DECLARE(sound_play_cd)

	item_action_types = list(/datum/action/item_action/hands_free/use_analyzer)

/datum/action/item_action/hands_free/use_analyzer
	name = "Use Analyzer"

/obj/item/device/analyzer/verb/verbosity(mob/user as mob)
	set name = "Toggle Advanced Gas Analysis"
	set category = "Object"
	set src in usr

	if(!user.incapacitated())
		advanced_mode = !advanced_mode
		to_chat(usr, "You toggle advanced gas analysis [advanced_mode ? "on" : "off"].")

/obj/item/device/analyzer/attack_self(mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(user.incapacitated())
		return
	if(status)
		cut_overlays()
		status = FALSE
		to_chat(user, "<span class='notice'>You turn off [src].</span>")
	else
		status = TRUE
		var/image/I = image(icon, icon_state = "atmos_overlay")
		add_overlay(I)
		to_chat(user, "<span class='notice'>You turn on [src].</span>")
	update_item_actions()
	playsound(user, 'sound/items/flashlight.ogg', VOL_EFFECTS_MASTER, 20)
	return TRUE

/obj/item/device/analyzer/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(user.incapacitated())
		return
	if(!status)
		return
	if(isobj(target) || isfloorturf(target))
		analyze_gases(target, user, advanced_mode)

/obj/item/device/analyzer/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Last recieved radiation signal: [last_rad_signal] mSv.<br>Approximate distance: [last_rad_signal] m.</span>")

/obj/item/device/analyzer/proc/recieve_rad_signal(amount_rad, distance_to_rad)
	if(!status)
		return
	if(!amount_rad)
		return
	if(distance_to_rad < 0)
		return
	var/distance_volume = abs(clamp(distance_to_rad, 0, 70)-100)
	var/dose_sound = "sound/items/radioactive_machine_light.ogg"
	switch(amount_rad)
		if(SAFE_DOSE to HEALTH_EFFECT_DOSE)
			dose_sound = "sound/items/radioactive_machine_medium.ogg"
		if(HEALTH_EFFECT_DOSE to DANGEROUS_DOSE)
			dose_sound = "sound/items/radioactive_machine_huge.ogg"
		if(DANGEROUS_DOSE to INFINITY)
			dose_sound = "sound/items/radioactive_machine_alert.ogg"
	if(COOLDOWN_FINISHED(src, sound_play_cd))
		playsound(src, dose_sound, VOL_EFFECTS_MASTER, distance_volume)
		var/sound/S = sound(dose_sound)
		COOLDOWN_START(src, sound_play_cd, S.len)
	last_rad_signal = round(amount_rad)
	last_distance = distance_to_rad

#undef SAFE_DOSE
#undef HEALTH_EFFECT_DOSE
#undef DANGEROUS_DOSE
