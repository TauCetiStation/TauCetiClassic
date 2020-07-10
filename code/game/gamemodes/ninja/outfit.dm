/datum/outfit/space_ninja
	name = "Space Ninja"

	uniform = /obj/item/clothing/under/color/black
	uniform_f = /obj/item/clothing/under/color/blackf
	shoes = /obj/item/clothing/shoes/space_ninja
	suit = /obj/item/clothing/suit/space/space_ninja
	gloves = /obj/item/clothing/gloves/space_ninja
	head = /obj/item/clothing/head/helmet/space/space_ninja
	mask = /obj/item/clothing/mask/gas/voice/space_ninja
	belt = /obj/item/device/flashlight

	r_pocket = /obj/item/weapon/plastique
	l_pocket = /obj/item/weapon/plastique
	suit_store = /obj/item/weapon/tank/oxygen
	
	l_ear = /obj/item/device/radio/headset/ninja
	
	implants = list(/obj/item/weapon/implant/dexplosive = BP_HEAD)

	internals_slot = SLOT_S_STORE

/datum/outfit/space_ninja/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/clothing/suit/space/space_ninja/ninja_suit = H.wear_suit
	ninja_suit.randomize_param()//Give them a random set of suit parameters.
