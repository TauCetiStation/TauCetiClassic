// Example of modifying and removing jobs based on a map name
#define JOB_MODIFICATION_MAP_NAME "Test Map (for development)"

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK

	title = "Clown Police" // Might break jobbans or something so be careful
	access += list(access_clown, access_theatre)

/datum/job/officer/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE

	if(!H)
		return 0

	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/clown(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), SLOT_WEAR_MASK)

	..()

MAP_REMOVE_JOB(barber)

MAP_REMOVE_JOB(recycler)

MAP_REMOVE_JOB(cadet)

MAP_REMOVE_JOB(forensic)