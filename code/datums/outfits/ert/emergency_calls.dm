/datum/outfit/ert
	var/assignment = null //ERT ONLY

/datum/outfit/ert/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!id)
		return
	else
		var/obj/item/weapon/card/id/I = H.wear_id
		I.name = "[H.real_name]'s ID Card ([assignment])"
		I.registered_name = H.real_name
		I.assignment = assignment