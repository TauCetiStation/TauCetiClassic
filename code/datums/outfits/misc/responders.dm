/datum/outfit/responders/nanotrasen_ert
	name = "Responders: NT ERT"
	uniform = /obj/item/clothing/under/ert
	glasses = /obj/item/clothing/glasses/night
	shoes = /obj/item/clothing/shoes/boots/combat
	belt = /obj/item/weapon/storage/belt/security/cops
	mask = /obj/item/clothing/mask/gas/sechailer
	gloves = /obj/item/clothing/gloves/combat
	id = /obj/item/weapon/card/id/centcom/ert
	l_ear = /obj/item/device/radio/headset/ert

	r_pocket = /obj/item/weapon/tank/emergency_oxygen/double
	l_pocket = /obj/item/weapon/storage/pouch/pistol_holster/ert

	backpack_contents = list(/obj/item/weapon/gun/energy/gun/nuclear)

	implants = list(/obj/item/weapon/implant/mind_protect/loyalty)

	var/vest = /obj/item/clothing/accessory/storage/black_vest/ert
	var/assignment = "Emergency Response Team"

/datum/outfit/responders/nanotrasen_ert/post_equip(mob/living/carbon/human/H)
	var/obj/item/clothing/under/U = H.w_uniform
	if(istype(U))
		var/obj/item/clothing/accessory/storage/S = new vest(U)
		LAZYADD(U.accessories, S)
		S.on_attached(U, H, TRUE)

		var/obj/item/weapon/card/id/centcom/ert/W = H.wear_id
		W.assignment = assignment
		W.rank = "Emergency Response Team"
		W.assign(H.real_name)

/datum/outfit/responders/nanotrasen_ert/security
	name = "Responders: NT ERT Security"
	suit = /obj/item/clothing/suit/space/rig/ert/security
	head = /obj/item/clothing/head/helmet/space/rig/ert/security
	back = /obj/item/weapon/storage/backpack/ert/security

	assignment = "Emergency Response Team Security"

/datum/outfit/responders/nanotrasen_ert/security/post_equip(mob/living/carbon/human/H)
	. = ..()
	if(prob(20))
		H.equip_to_slot(new /obj/item/weapon/gun/energy/sniperrifle(H), SLOT_S_STORE)
	else
		H.equip_to_slot(new /obj/item/weapon/gun/projectile/shotgun/combat(H), SLOT_S_STORE)
		H.equip_to_slot(new /obj/item/ammo_box/shotgun(H), SLOT_IN_BACKPACK)
		H.equip_to_slot(new /obj/item/ammo_box/shotgun(H), SLOT_IN_BACKPACK)

/datum/outfit/responders/nanotrasen_ert/leader
	name = "Responders: NT ERT Leader"
	suit = /obj/item/clothing/suit/space/rig/ert/commander
	head = /obj/item/clothing/head/helmet/space/rig/ert/commander
	back = /obj/item/weapon/storage/backpack/ert/commander
	id = /obj/item/weapon/card/id/centcom/ert/leader
	suit_store = /obj/item/weapon/gun/projectile/grenade_launcher/m79

	backpack_contents = list(/obj/item/weapon/gun/energy/gun/nuclear, /obj/item/weapon/pinpointer/advpinpointer, /obj/item/device/aicard, /obj/item/device/remote_device/ERT, /obj/item/weapon/storage/box/r4046/rubber, /obj/item/weapon/storage/box/r4046/teargas)

	assignment = "Emergency Response Team Leader"


/datum/outfit/responders/nanotrasen_ert/engineer
	name = "Responders: NT ERT Engineer"
	suit = /obj/item/clothing/suit/space/rig/ert/engineer
	head = /obj/item/clothing/head/helmet/space/rig/ert/engineer
	back = /obj/item/weapon/storage/backpack/ert/engineer

	belt = /obj/item/weapon/storage/belt/utility/cool

	suit_store = /obj/item/weapon/gun/energy/ionrifle

	backpack_contents = list(/obj/item/weapon/gun/energy/gun/nuclear, /obj/item/weapon/rcd/ert, /obj/item/device/multitool)

	l_hand = /obj/item/weapon/storage/lockbox/anti_singulo

	assignment = "Emergency Response Team Engineer"

/datum/outfit/responders/nanotrasen_ert/medic
	name = "Responders: NT ERT Medic"
	glasses = /obj/item/clothing/glasses/hud/health/night
	suit = /obj/item/clothing/suit/space/rig/ert/medical
	head = /obj/item/clothing/head/helmet/space/rig/ert/medical
	back = /obj/item/weapon/storage/backpack/ert/medical

	belt = /obj/item/weapon/storage/belt/medical/full

	suit_store = /obj/item/weapon/gun/medbeam

	backpack_contents = list(/obj/item/weapon/gun/energy/gun/nuclear, /obj/item/bodybag/cryobag = 2, /obj/item/weapon/storage/box/bodybags, /obj/item/weapon/reagent_containers/syringe, /obj/item/weapon/storage/firstaid/adv, /obj/item/weapon/shockpaddles/standalone)

	assignment = "Emergency Response Team Medic"


/datum/outfit/responders/gorlex_marauders
	name = "Responders: Gorlex Marauder"
	head = /obj/item/clothing/head/helmet/space/rig/syndi
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/rig/syndi
	glasses = /obj/item/clothing/glasses/night
	shoes = /obj/item/clothing/shoes/boots/combat
	belt = /obj/item/weapon/storage/belt/military
	mask = /obj/item/clothing/mask/gas/syndicate
	gloves = /obj/item/clothing/gloves/combat
	id = /obj/item/weapon/card/id/syndicate/nuker
	back = PREFERENCE_BACKPACK

	l_ear = /obj/item/device/radio/headset/syndicate

	r_pocket = /obj/item/weapon/tank/emergency_oxygen/double
	l_pocket = /obj/item/weapon/storage/pouch/pistol_holster/stechkin

	backpack_contents = list(/obj/item/weapon/pinpointer/nukeop, /obj/item/weapon/reagent_containers/pill/cyanide, /obj/item/weapon/crowbar/red)

	implants = list(/obj/item/weapon/implant/dexplosive)

	var/list/possible_kits = list(/obj/item/weapon/storage/backpack/dufflebag/nuke/assaultman, /obj/item/weapon/storage/backpack/dufflebag/nuke/scout, /obj/item/weapon/storage/backpack/dufflebag/nuke/hacker,\
								/obj/item/weapon/storage/backpack/dufflebag/nuke/sniper, /obj/item/weapon/storage/backpack/dufflebag/nuke/demo, /obj/item/weapon/storage/backpack/dufflebag/nuke/heavygunner) //no medic, chem and custom

/datum/outfit/responders/gorlex_marauders/post_equip(mob/living/carbon/human/H)
	var/obj/item/clothing/under/U = H.w_uniform
	if(istype(U))
		var/obj/item/clothing/accessory/storage/S = new /obj/item/clothing/accessory/storage/syndi_vest(U)
		LAZYADD(U.accessories, S)
		S.on_attached(U, H, TRUE)
	var/obj/item/weapon/storage/backpack/dufflebag/nuke/N = pick(possible_kits)
	H.equip_to_slot(new N(H), SLOT_L_HAND)

/datum/outfit/responders/gorlex_marauders/leader
	head = /obj/item/clothing/head/helmet/space/rig/syndi/heavy
	suit = /obj/item/clothing/suit/space/rig/syndi/heavy
	id = /obj/item/weapon/card/id/syndicate/commander
	r_hand = /obj/item/device/radio/uplink


/datum/outfit/responders/deathsquad
	name = "Responders: Death Squad"

	l_ear = /obj/item/device/radio/headset/deathsquad
	uniform = /obj/item/clothing/under/color/green
	shoes = /obj/item/clothing/shoes/boots/swat
	suit = /obj/item/clothing/suit/armor/swat
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/helmet/space/deathsquad
	mask = /obj/item/clothing/mask/gas/swat
	glasses = /obj/item/clothing/glasses/thermal
	back = /obj/item/weapon/storage/backpack/security

	backpack_contents = list(
		/obj/item/weapon/storage/firstaid/tactical,
		/obj/item/weapon/storage/box/flashbangs,
		/obj/item/device/flashlight/seclite,
		/obj/item/weapon/plastique,
		/obj/item/weapon/tank/emergency_oxygen/double,
		/obj/item/weapon/shield/energy
	)

	l_pocket = /obj/item/weapon/melee/energy/sword
	r_pocket = /obj/item/weapon/storage/pouch/ammo
	belt = /obj/item/weapon/gun/projectile/revolver/mateba

	implants = list(/obj/item/weapon/implant/mind_protect/loyalty)
	id = /obj/item/weapon/card/id/centcom

	var/list/rank = list("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/assignment = "Deathsquad Officer"

/datum/outfit/responders/deathsquad/post_equip(mob/living/carbon/human/H)
	var/obj/item/weapon/storage/pouch/ammo/P = H.r_store
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/speedloader/a357(P)

	var/obj/item/clothing/under/color/green/U = H.w_uniform
	if(istype(U))
		var/obj/item/clothing/accessory/storage/black_vest/A = new(U)
		LAZYADD(U.accessories, A)
		A.on_attached(U, H, TRUE)
		new /obj/item/weapon/multi/hand_drill(A.hold)
		new /obj/item/weapon/multi/jaws_of_life(A.hold)
		new /obj/item/weapon/weldingtool/largetank(A.hold)
		new /obj/item/device/multitool(A.hold)

	if(prob(50))
		H.equip_or_collect(new /obj/item/weapon/gun/projectile/automatic/l6_saw(H), SLOT_S_STORE)
		H.equip_or_collect(new /obj/item/ammo_box/magazine/saw(H), SLOT_IN_BACKPACK)
		H.equip_or_collect(new /obj/item/ammo_box/magazine/saw(H), SLOT_IN_BACKPACK)
	else if(prob(20))
		H.equip_or_collect(new /obj/item/weapon/gun/projectile/revolver/rocketlauncher/commando(H), SLOT_S_STORE)
		H.equip_or_collect(new /obj/item/weapon/gun/projectile/automatic(H), SLOT_IN_BACKPACK)
		H.equip_or_collect(new /obj/item/ammo_box/magazine/smg(H), SLOT_IN_BACKPACK)
		H.equip_or_collect(new /obj/item/ammo_box/magazine/smg(H), SLOT_IN_BACKPACK)
	else
		H.equip_or_collect(new /obj/item/weapon/gun/energy/pulse_rifle(H), SLOT_S_STORE)


	H.real_name = "[pick(rank)] [pick(last_names)]"
	var/obj/item/weapon/card/id/centcom/W = H.wear_id
	W.assignment = assignment
	W.rank = "Nanotrasen Representative"
	W.assign(H.real_name)


/datum/outfit/responders/deathsquad/leader
	name = "Responders: Death Squad Leader"

	head = /obj/item/clothing/head/helmet/space/deathsquad/leader
	uniform = /obj/item/clothing/under/rank/centcom_officer

	backpack_contents = list(
		/obj/item/weapon/storage/firstaid/tactical,
		/obj/item/weapon/storage/box/flashbangs,
		/obj/item/device/flashlight/seclite,
		/obj/item/weapon/pinpointer,
		/obj/item/weapon/disk/nuclear,
		/obj/item/weapon/plastique,
		/obj/item/weapon/shield/energy,
		/obj/item/weapon/tank/emergency_oxygen/double
	)
	rank = list("Lieutenant", "Captain", "Major")
	assignment = "Deathsquad Leader"

/datum/outfit/responders/pirate
	name = "Responders: Pirate"

	l_ear = /obj/item/device/radio/headset
	uniform = /obj/item/clothing/under/pirate
	shoes = /obj/item/clothing/shoes/boots/combat
	suit = /obj/item/clothing/suit/space/globose/black/pirate
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/helmet/space/globose/black/pirate
	mask = /obj/item/clothing/mask/gas/coloured
	glasses = /obj/item/clothing/glasses/eyepatch
	back = /obj/item/weapon/storage/backpack/santabag
	suit_store = /obj/item/weapon/gun/projectile/automatic/a28/nonlethal

	backpack_contents = list(
		/obj/item/weapon/tank/emergency_oxygen/double,
		/obj/item/weapon/storage/firstaid/small_firstaid_kit/space,
		/obj/item/device/flashlight/seclite,
		/obj/item/weapon/plastique,
		/obj/item/weapon/grenade/empgrenade,
		/obj/item/ammo_box/shotgun/beanbag,
		/obj/item/weapon/extraction_pack/pirates
	)

	l_pocket = /obj/item/weapon/melee/energy/sword/pirate
	r_pocket = /obj/item/weapon/storage/pouch/pistol_holster/pirates

	belt = /obj/item/weapon/storage/belt/utility/full

	id = /obj/item/weapon/card/id/syndicate

/datum/outfit/responders/pirate/post_equip(mob/living/carbon/human/H)
	H.real_name = "[pick(global.first_names_male)] [pick(global.pirate_first)][pick(global.pirate_second)]"
	H.name = H.real_name
	var/obj/item/weapon/card/id/syndicate/W = H.wear_id
	W.assignment = "Pirate"
	W.assign(H.real_name)

/datum/outfit/responders/pirate/leader
	head = /obj/item/clothing/head/helmet/space/globose/black/pirate/leader
	glasses = /obj/item/clothing/glasses/thermal/eyepatch

/datum/outfit/responders/pirate/leader/post_equip(mob/living/carbon/human/H)
	H.real_name = "Captain [pick(global.first_names_male)] Redskull"
	H.name = H.real_name
	var/obj/item/weapon/card/id/syndicate/W = H.wear_id
	W.assignment = "Pirate Captain"
	W.assign(H.real_name)

/obj/item/weapon/storage/belt/security/ert
	startswith = list(/obj/item/weapon/melee/baton, /obj/item/device/flash, /obj/item/weapon/grenade/flashbang = 2, /obj/item/weapon/handcuffs = 3)

/obj/item/weapon/storage/pouch/pistol_holster/ert
	startswith = list(/obj/item/weapon/gun/projectile/automatic/pistol/glock/spec)

/obj/item/weapon/storage/pouch/pistol_holster/pirates
	startswith = list(/obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon/sawn_off/beanbag)

/obj/item/clothing/accessory/storage/black_vest/ert/atom_init()
	. = ..()
	new /obj/item/weapon/plastique(hold)
	new /obj/item/weapon/storage/firstaid/small_firstaid_kit/combat(hold)
	new /obj/item/weapon/storage/firstaid/small_firstaid_kit/space(hold)
	new /obj/item/ammo_box/magazine/glock/extended(hold)
	new /obj/item/ammo_box/magazine/glock/extended(hold)

/obj/item/weapon/rcd/ert
	name = "advanced RCD"
	matter = 100
