// Put qualities that change gameplay in unique ways, which are neither strictly positve or negative.

/datum/quality/cyborg
	desc = "Все твои конечности и органы были заменены протезами в результате недавнего несчастного случая."
	restriction = "Нет."

/datum/quality/cyborg/add_effect(mob/living/carbon/human/H, latespawn)
	qdel(H.bodyparts_by_name[BP_L_LEG])
	qdel(H.bodyparts_by_name[BP_R_LEG])
	qdel(H.bodyparts_by_name[BP_L_ARM])
	qdel(H.bodyparts_by_name[BP_R_ARM])

	var/obj/item/organ/external/l_arm/robot/LA = new(null)
	LA.insert_organ(H)

	var/obj/item/organ/external/r_arm/robot/RA = new(null)
	RA.insert_organ(H)

	var/obj/item/organ/external/l_leg/robot/LL = new(null)
	LL.insert_organ(H)

	var/obj/item/organ/external/r_leg/robot/RL = new(null)
	RL.insert_organ(H)

	for(var/obj/item/organ/internal/IO in H.organs)
		IO.mechanize()
