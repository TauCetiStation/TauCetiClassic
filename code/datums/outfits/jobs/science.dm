// RESEARCH DIRECTOR OUTFIT
/datum/outfit/job/rd
	name = OUTFIT_JOB_NAME("Research Director")

	uniform = /obj/item/clothing/under/rank/research_director
	shoes = /obj/item/clothing/shoes/brown
	suit = /obj/item/clothing/suit/storage/labcoat

	belt = /obj/item/device/pda/heads/rd
	l_ear = /obj/item/device/radio/headset/heads/rd

	back_style = BACKPACK_STYLE_RESEARCH

/datum/outfit/job/rd/pre_equip(mob/living/carbon/human/H)
	if(HAS_ROUND_ASPECT(ROUND_ASPECT_HF_AGENT))
		implants += /obj/item/weapon/implant/obedience


// SCIENTIST OUTFIT
/datum/outfit/job/scientist
	name = OUTFIT_JOB_NAME("Scientist")

	uniform = /obj/item/clothing/under/rank/scientist
	shoes = /obj/item/clothing/shoes/white
	suit = /obj/item/clothing/suit/storage/labcoat/science

	belt = /obj/item/device/pda/science
	l_ear = /obj/item/device/radio/headset/headset_sci

	back_style = BACKPACK_STYLE_RESEARCH

/datum/outfit/job/scientist/unathi_equip()
	backpack_contents += list(/obj/item/device/modkit/unathi)

/datum/outfit/job/scientist/tajaran_equip()
	backpack_contents += list(/obj/item/device/modkit/tajaran)

/datum/outfit/job/scientist/skrell_equip()
	backpack_contents += list(/obj/item/device/modkit/skrell)

/datum/outfit/job/scientist/vox_equip()
	backpack_contents += list(/obj/item/device/modkit/vox)

// XENOARCHAEOLOGIST OUTFIT
/datum/outfit/job/xenoarchaeologist
	name = OUTFIT_JOB_NAME("Xenoarchaeologist")

	uniform = /obj/item/clothing/under/rank/scientist
	shoes = /obj/item/clothing/shoes/white
	suit = /obj/item/clothing/suit/storage/labcoat/science

	belt = /obj/item/device/pda/science
	l_ear = /obj/item/device/radio/headset/headset_sci

	back_style = BACKPACK_STYLE_RESEARCH

/datum/outfit/job/xenoarchaeologist/unathi_equip()
	backpack_contents += list(/obj/item/device/modkit/unathi)

/datum/outfit/job/xenoarchaeologist/tajaran_equip()
	backpack_contents += list(/obj/item/device/modkit/tajaran)

/datum/outfit/job/xenoarchaeologist/skrell_equip()
	backpack_contents += list(/obj/item/device/modkit/skrell)

/datum/outfit/job/xenoarchaeologist/vox_equip()
	backpack_contents += list(/obj/item/device/modkit/vox)

// XENOBIOLOGIST OUTFIT
/datum/outfit/job/xenobiologist
	name = OUTFIT_JOB_NAME("Xenobiologist")

	uniform = /obj/item/clothing/under/rank/scientist
	suit = /obj/item/clothing/suit/storage/labcoat/science
	shoes = /obj/item/clothing/shoes/white

	belt = /obj/item/device/pda/science
	l_ear = /obj/item/device/radio/headset/headset_sci

	back_style = BACKPACK_STYLE_RESEARCH

// ROBOTICIST OUTFIT
/datum/outfit/job/roboticist
	name = OUTFIT_JOB_NAME("Roboticist")

	uniform = /obj/item/clothing/under/rank/roboticist
	uniform_f = /obj/item/clothing/under/rank/roboticist_fem
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/black

	belt = /obj/item/device/pda/roboticist
	l_ear = /obj/item/device/radio/headset/headset_sci

	back_style = BACKPACK_STYLE_RESEARCH

// RESEARCH ASSISTANT OUTFIT
/datum/outfit/job/research_assistant
	name = OUTFIT_JOB_NAME("Research Assistant")

	uniform = /obj/item/clothing/under/rank/scientist_new
	shoes = /obj/item/clothing/shoes/white

	belt = /obj/item/device/pda
	l_ear = /obj/item/device/radio/headset/headset_sci

	back_style = BACKPACK_STYLE_RESEARCH
