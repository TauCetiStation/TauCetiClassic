#define JOB_MODIFICATION_MAP_NAME "Ministation"
//Command
/datum/job/captain/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/black(H), SLOT_HEAD)
	..()

/datum/job/hop/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/black(H), SLOT_HEAD)
	..()

/datum/job/hos/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/black(H), SLOT_HEAD)
	..()

/datum/job/rd/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/black(H), SLOT_HEAD)
	..()

/datum/job/cmo/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/black(H), SLOT_HEAD)
	..()

/datum/job/chief_engineer/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/black(H), SLOT_HEAD)
	..()


//Medical
/datum/job/doctor/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/black_white(H), SLOT_HEAD)
	..()

/datum/job/paramedic/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/black_white(H), SLOT_HEAD)
	..()

/datum/job/chemist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/black_white(H), SLOT_HEAD)
	..()


//Research
/datum/job/scientist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/brown_white(H), SLOT_HEAD)
	..()

/datum/job/xenobiologist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/brown_white(H), SLOT_HEAD)
	..()

/datum/job/roboticist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/brown_white(H), SLOT_HEAD)
	..()


//Security
/datum/job/detective/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/black_brown(H), SLOT_HEAD)
	..()

/datum/job/officer/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/black_brown(H), SLOT_HEAD)
	..()


//Engineering
/datum/job/engineer/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/brown(H), SLOT_HEAD)
	..()

/datum/job/atmos/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/brown(H), SLOT_HEAD)
	..()

MAP_REMOVE_JOB(mime)
MAP_REMOVE_JOB(clown)
MAP_REMOVE_JOB(ai)
MAP_REMOVE_JOB(cyborg)
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(barber)
MAP_REMOVE_JOB(recycler)
MAP_REMOVE_JOB(librarian)
MAP_REMOVE_JOB(psychiatrist)
MAP_REMOVE_JOB(forensic)
MAP_REMOVE_JOB(warden)
