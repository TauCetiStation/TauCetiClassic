#define DEFAULT_MAX_NANOTRASEN_LOYALITY 100
#define DEFAULT_TIMER_ADJUST_LOYALUTY 600

/datum/component/nanotrasen_loyality
	var/current_anti_loyality = 0

/datum/component/nanotrasen_loyality/Initialize()
	var/mob/M = parent
	if(M.client?.prefs)
		if(M.client.prefs.nanotrasen_relation == "Opposed")
			current_anti_loyality = 20
		if(M.client.prefs.nanotrasen_relation == "Skeptical")
			current_anti_loyality = 50
	START_PROCESSING(SSlongprocess, src)

/datum/component/nanotrasen_loyality/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CONVERTED_TO_REV, .proc/converted_to_rev)
	RegisterSignal(parent, COMSIG_HEAR_REVCONVERT, .proc/hear_revconvert)
	RegisterSignal(parent, COMSIG_VIEW_POSTER, .proc/view_poster)
	RegisterSignal(parent, COMSIG_ATTACKED_BY_REVFLASHER, .proc/attacked_by_revflasher)
	RegisterSignal(parent, COMSIG_HEAR_MEGAPHONE, .proc/hear_megaphone)
	RegisterSignal(parent, COMSIG_ATTACKED_BY_TRANSPARANT, .proc/attacked_by_transparant)

/datum/component/nanotrasen_loyality/process(seconds_per_tick)
	adjust_anti_loyality(-1)

/datum/component/nanotrasen_loyality/proc/adjust_anti_loyality(amount_loyality)
	var/mob/living/carbon/human/M = parent
	if(!M.client)
		qdel(src)
		return
	for(var/i in list(REV, HEADREV))
		if(M.mind.GetRole(i))
			qdel(src)
			return
	if(M.ismindprotect() || M.isloyal())
		return
	current_anti_loyality = clamp(current_anti_loyality + amount_loyality, 0, 100)

	if(current_anti_loyality == 100)
		convert_to_revolution()

/datum/component/nanotrasen_loyality/proc/convert_to_revolution()
	var/datum/faction/F = find_faction_by_type(/datum/faction/revolution)
	if(!F)
		qdel(src)
		return
	add_faction_member(F, parent, TRUE)

/datum/component/nanotrasen_loyality/Destroy()
	STOP_PROCESSING(SSlongprocess, src)
	UnregisterSignal(parent, list(COMSIG_CONVERTED_TO_REV,
								COMSIG_HEAR_REVCONVERT,
								COMSIG_VIEW_POSTER,
								COMSIG_ATTACKED_BY_REVFLASHER,
								COMSIG_HEAR_MEGAPHONE,
								COMSIG_ATTACKED_BY_TRANSPARANT))
	return ..()

/datum/component/nanotrasen_loyality/proc/converted_to_rev(datum/source)
	qdel(src)

/datum/component/nanotrasen_loyality/proc/hear_revconvert(datum/source, mob/revolutioneer)
	var/mob/living/carbon/human/H = revolutioneer
	adjust_anti_loyality(isrevhead(H) ? 50 : 5)

/datum/component/nanotrasen_loyality/proc/view_poster(datum/source)
	adjust_anti_loyality(10)

/datum/component/nanotrasen_loyality/proc/attacked_by_revflasher(datum/source)
	var/mob/living/carbon/human/H = source
	if(!istype(H) || H.eyecheck() || H.blinded)
		return
	adjust_anti_loyality(100)

/datum/component/nanotrasen_loyality/proc/hear_megaphone(datum/source)
	adjust_anti_loyality(20)

/datum/component/nanotrasen_loyality/proc/attacked_by_transparant(datum/source, user, def_zone)
	if(def_zone == BP_HEAD)
		adjust_anti_loyality(20)
