/obj/item/weapon/implant/abductor
	name = "recall implant"
	desc = "Returns you to the mothership."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	item_action_types = list(/datum/action/item_action/implant/recall_implant)
	var/obj/machinery/abductor/pad/home

/datum/action/item_action/implant/recall_implant
	name = "Recall implant"
	cooldown = 30 SECONDS

/datum/action/item_action/implant/recall_implant/Activate()
	var/obj/item/weapon/implant/abductor/S = target
	if(S.use_implant())
		StartCooldown()

/obj/item/weapon/implant/abductor/activate()
	var/turf/T = get_turf(implanted_mob)
	if(SEND_SIGNAL(T, COMSIG_ATOM_INTERCEPT_TELEPORT))
		to_chat(implanted_mob, "<span class='warning'>WARNING! Bluespace interference has been detected in the location, preventing teleportation! Teleportation is canceled!</span>")
		return FALSE

	if(implanted_mob.buckled)
		implanted_mob.buckled.unbuckle_mob()
	home.Retrieve(implanted_mob)

	return TRUE
