/datum/outfit/velocity
	name = "Velocity Officer"

	uniform = /obj/item/clothing/under/det/fluff/retpoluniform
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/boots/combat
	l_ear = /obj/item/device/radio/headset/velocity
	glasses = /obj/item/clothing/glasses/sunglasses/hud/sechud

	back = /obj/item/weapon/storage/backpack/satchel
	implants = list(/obj/item/weapon/implant/mind_protect/mindshield)

/datum/outfit/velocity/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/device/pda/velocity/pda = new(H)
	pda.owner = H.real_name
	pda.ownjob = "Velocity Officer"
	pda.name = "PDA-[H.real_name] ([name])"
	H.equip_to_slot_or_del(pda, SLOT_BELT)

	var/obj/item/weapon/card/id/velocity/card = new(H)
	card.name = "[H.real_name]'s ID Card ([name])"
	card.rank = name
	card.registered_name = H.real_name
	H.equip_to_slot_or_del(card, SLOT_WEAR_ID)

	if(H.mind)
		H.mind.assigned_role = "Velocity Officer"

	H.universal_speak = TRUE
	H.universal_understand = TRUE