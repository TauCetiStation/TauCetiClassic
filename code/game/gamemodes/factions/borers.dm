/datum/faction/borers
	name = F_BORER_HIVEMIND
	ID = F_BORER_HIVEMIND
	required_pref = ROLE_ALIEN // in code\modules\events\borers.dm too

	roletype = /datum/role/borer

	max_roles = 3

	logo_state = "borer-logo"

/datum/faction/borers/OnPostSetup()
	var/list/vents = get_vents()
	for(var/datum/role/R in members)
		var/obj/vent = pick_n_take(vents)
		var/mob/living/simple_animal/borer/B = new(vent.loc)
		R.antag.transfer_to(B)
		QDEL_NULL(R.antag.original)

	return ..()
