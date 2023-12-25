// forts event outfits

/datum/outfit/forts_team
	name = "Forts Team"
	glasses = /obj/item/clothing/glasses/rocket_observation
	uniform = /obj/item/clothing/under/ert
	shoes = /obj/item/clothing/shoes/boots/combat
	belt = /obj/item/weapon/storage/belt/utility/full
	gloves = /obj/item/clothing/gloves/combat

	l_pocket = /obj/item/weapon/rcd/bluespace
	r_pocket = /obj/item/weapon/rcd/pp/bluespace
	suit_store = /obj/item/device/multitool

/datum/outfit/forts_team/blue
	implants = list(/obj/item/weapon/implant/death_alarm/coordinates/team_blue)
	l_ear = /obj/item/device/radio/headset/team_blue
	suit = /obj/item/clothing/suit/space/rig/forts/team_blue
	head = /obj/item/clothing/head/helmet/space/rig/forts/team_blue
	back = /obj/item/weapon/storage/backpack/ert/commander

/datum/outfit/forts_team/red
	implants = list(/obj/item/weapon/implant/death_alarm/coordinates/team_red)
	l_ear = /obj/item/device/radio/headset/team_red
	suit = /obj/item/clothing/suit/space/rig/forts/team_red
	head = /obj/item/clothing/head/helmet/space/rig/forts/team_red
	back = /obj/item/weapon/storage/backpack/ert/security
