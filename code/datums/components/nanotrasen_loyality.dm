#define DEFAULT_MAX_NANOTRASEN_LOYALITY 100
#define DEFAULT_TIMER_ADJUST_LOYALUTY 600

/datum/component/nanotrasen_loyality
	var/max_loyality
	var/current_loyality
	var/list/timer_list = list()

/datum/component/nanotrasen_loyality/Initialize(maximum_loyality = DEFAULT_MAX_NANOTRASEN_LOYALITY, amount_loyality = DEFAULT_MAX_NANOTRASEN_LOYALITY)
	max_loyality = maximum_loyality
	current_loyality = amount_loyality

/datum/component/nanotrasen_loyality/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ADJUST_LOYALITY, .proc/adjust_loyality)

/datum/component/nanotrasen_loyality/proc/adjust_loyality(datum/signal_source, amount_loyality, datum/source, force = FALSE)
	SIGNAL_HANDLER

	var/mob/M = parent
	if(!M.mind)
		qdel(src)
		return
	for(var/i in list(REV, HEADREV))
		if(M.mind.GetRole(i))
			qdel(src)
			return

	if(M.ismindprotect() || M.isloyal())
		return

	if(!force)
		var/timer = timer_list[source.type]
		if(timer && timer + DEFAULT_TIMER_ADJUST_LOYALUTY > world.time)
			return
		timer_list[source.type] = world.time

	current_loyality = clamp(current_loyality + amount_loyality, -1, max_loyality)

	if(current_loyality < 0)
		convert_to_revolution()

/datum/component/nanotrasen_loyality/proc/convert_to_revolution()
	var/datum/faction/F = find_faction_by_type(/datum/faction/revolution)
	if(!F)
		return
	if(add_faction_member(F, parent, TRUE))
		qdel(src)

/datum/component/nanotrasen_loyality/Destroy()
	UnregisterSignal(parent, COMSIG_ADJUST_LOYALITY)
	return ..()
