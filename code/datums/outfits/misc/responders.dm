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

/datum/outfit/responders/nanotrasen_ert/leader/ect
	name = "Responders: NT ERT Leader (ECT)"
	backpack_contents = list(/obj/item/weapon/gun/energy/gun/nuclear, /obj/item/weapon/pinpointer/advpinpointer, /obj/item/device/aicard, /obj/item/device/remote_device/ERT, /obj/item/weapon/storage/box/r4046/rubber, /obj/item/weapon/storage/box/r4046/teargas,\
								/obj/item/weapon/rcd/ert, /obj/item/weapon/storage/belt/utility/cool)

	assignment = "Engineering Corps Team Leader"

/datum/outfit/responders/nanotrasen_ert/leader/emt
	name = "Responders: NT ERT Leader (EMT)"
	backpack_contents = list(/obj/item/weapon/gun/energy/gun/nuclear, /obj/item/weapon/pinpointer/advpinpointer, /obj/item/device/aicard, /obj/item/device/remote_device/ERT, /obj/item/weapon/storage/box/r4046/rubber, /obj/item/weapon/storage/box/r4046/teargas,\
								/obj/item/weapon/storage/pouch/medical_supply/combat, /obj/item/weapon/storage/firstaid/adv)

	assignment = "Emergency Medical Team Leader"

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

/datum/outfit/responders/nanotrasen_ert/engineer/ect
	name = "Responders: NT ERT Engineer (ECT)"
	suit = /obj/item/clothing/suit/space/rig/ert/engineer
	head = /obj/item/clothing/head/helmet/space/rig/ert/engineer
	back = /obj/item/weapon/storage/backpack/ert/engineer

	belt = /obj/item/weapon/storage/belt/utility/cool
	l_hand = null
	suit_store = /obj/item/weapon/storage/lockbox/anti_singulo

	backpack_contents = list(/obj/item/weapon/gun/energy/gun/nuclear, /obj/item/weapon/rcd/ert, /obj/item/device/multitool, /obj/item/stack/sheet/metal/fifty, /obj/item/stack/sheet/glass/fifty)

	assignment = "Engineering Corps Team Engineer"

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

/datum/outfit/responders/nanotrasen_ert/medic/emt
	name = "Responders: NT ERT Medic (EMT)"

	l_pocket = /obj/item/weapon/storage/pouch/medical_supply/combat

	assignment = "Emergency Medical Team Medic"

/datum/outfit/responders/nanotrasen_ert/medic/emt/surgeon
	name = "Responders: NT ERT Surgeon (EMT)"
	belt = /obj/item/weapon/storage/belt/medical/surg/full
	l_hand = /obj/item/roller/roller_holder_surg
	assignment = "Emergency Medical Team Surgeon"

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

/datum/outfit/responders/ussp
	name = "Responders: Soviet"

	suit = /obj/item/clothing/suit/armor/vest/surplus
	l_ear = /obj/item/device/radio/headset
	uniform =/obj/item/clothing/under/soviet
	shoes = /obj/item/clothing/shoes/boots
	back = /obj/item/weapon/storage/backpack/kitbag
	suit_store = /obj/item/weapon/gun/projectile/shotgun/bolt_action

	backpack_contents = list(
	/obj/item/weapon/storage/box/space_suit/soviet,
	/obj/item/device/flashlight/seclite
	)

	l_pocket = /obj/item/ammo_box/magazine/a774clip
	r_pocket = /obj/item/ammo_box/magazine/a774clip

	belt = /obj/item/weapon/shovel/spade/soviet

	id = /obj/item/weapon/card/id/syndicate
	var/assignment = "Krasnoarmeets"
	var/list/surnames = list("Ivanov", "Petrov", "Vasilyev", "Semenov", "Mihailov", "Pavlov", "Fedorov", "Andreev", "Stepanov", "Smirnov", "Kuznetsov")

/datum/outfit/responders/ussp/post_equip(mob/living/carbon/human/H)
	H.real_name = "[assignment] [pick(surnames)][H.gender == "male" ? "" : "a"]"
	H.name = H.real_name
	var/obj/item/weapon/card/id/syndicate/W = H.wear_id
	W.assignment = "[assignment]"
	W.assign(H.real_name)

	if(prob(30))
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/surplus(H), SLOT_HEAD)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka/black(H), SLOT_HEAD)

/datum/outfit/responders/ussp/leader
	name = "Responders: Soviet Leader"

	suit = /obj/item/clothing/suit/storage/comissar
	head = /obj/item/clothing/head/soviet_peaked_cap
	suit_store = /obj/item/weapon/gun/projectile/automatic/pistol/stechkin

	l_hand = /obj/item/device/megaphone

	back = /obj/item/weapon/storage/backpack/security

	backpack_contents = list(
	/obj/item/weapon/storage/box/space_suit/soviet,
	/obj/item/device/flashlight/seclite
	)

	l_pocket = /obj/item/ammo_box/magazine/stechkin
	r_pocket = /obj/item/ammo_box/magazine/stechkin

	belt = /obj/item/weapon/shovel/spade/soviet

	assignment = "Komissar"
	surnames = list("Makarov", "Zahaev", "Barkov", "Volkov")

/datum/outfit/responders/ussp/leader/post_equip(mob/living/carbon/human/H)
	. = ..()
	H.mind.skills.add_available_skillset(/datum/skillset/soviet_leader)
	H.mind.skills.maximize_active_skills()

/datum/outfit/responders/security
	name = "Responders: Security Officer"
	uniform = /obj/item/clothing/under/rank/security
	suit = /obj/item/clothing/suit/storage/flak
	head = /obj/item/clothing/head/helmet
	mask = /obj/item/clothing/mask/gas/sechailer
	glasses = /obj/item/clothing/glasses/sunglasses/hud/sechud
	gloves = /obj/item/clothing/gloves/security
	belt = /obj/item/weapon/storage/belt/security/ert
	shoes = /obj/item/clothing/shoes/boots
	l_ear = /obj/item/device/radio/headset/headset_sec
	back = /obj/item/weapon/storage/backpack/security
	id = /obj/item/weapon/card/id/sec

	l_pocket = /obj/item/device/flashlight/seclite
	r_pocket = /obj/item/weapon/storage/pouch/pistol_holster/security

	backpack_contents = list(
	/obj/item/weapon/storage/box/space_suit/security
	)

	implants = list(/obj/item/weapon/implant/mind_protect/mindshield, /obj/item/weapon/implant/obedience)

	back_style = BACKPACK_STYLE_SECURITY

/datum/outfit/responders/security/post_equip(mob/living/carbon/human/H)
	if(H.gender == "male")
		H.real_name = "[pick(global.first_names_male)] [pick(global.last_names)]"
	else
		H.real_name = "[pick(global.first_names_female)] [pick(global.last_names)]"
	H.name = H.real_name

	var/obj/item/clothing/under/rank/security/S = H.w_uniform
	var/obj/item/clothing/accessory/A = new /obj/item/clothing/accessory/holster/armpit/taser(S)
	A.on_attached(S, H, TRUE)
	LAZYADD(S.accessories, A)

	var/random_gun = rand(1, 5)
	switch(random_gun)
		if(1)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/shotgun/combat(H), SLOT_S_STORE)
			H.equip_to_slot_or_del(new /obj/item/ammo_box/eight_shells/buckshot(H), SLOT_IN_BACKPACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_box/eight_shells/buckshot(H), SLOT_IN_BACKPACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(H), SLOT_IN_BACKPACK)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/ionrifle(H), SLOT_S_STORE)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(H), SLOT_IN_BACKPACK)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/grenade_launcher/m79(H), SLOT_S_STORE)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/r4046/rubber(H), SLOT_IN_BACKPACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(H), SLOT_IN_BACKPACK)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/laser(H), SLOT_S_STORE)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(H), SLOT_IN_BACKPACK)
		if(5)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/plasma/p104sass(H), SLOT_S_STORE)
			H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/plasma(H), SLOT_IN_BACKPACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(H), SLOT_IN_BACKPACK)

	var/obj/item/weapon/card/id/ID = H.wear_id
	ID.registered_name = H.real_name
	ID.assignment = "Security Officer"
	ID.rank = ID.assignment
	ID.access = list(access_security, access_sec_doors, access_brig, access_maint_tunnels)
	H.sec_hud_set_ID()

/datum/outfit/responders/security/leader
	name = "Responders: Head of Security"
	uniform = /obj/item/clothing/under/rank/head_of_security
	suit = /obj/item/clothing/suit/armor/hos
	head = /obj/item/clothing/accessory/armor/dermal
	glasses = /obj/item/clothing/glasses/hud/hos_aug
	belt = /obj/item/weapon/storage/belt/security/ert
	l_ear = /obj/item/device/radio/headset/heads/hos
	l_pocket = /obj/item/weapon/melee/telebaton
	id = /obj/item/weapon/card/id/secGold
	mask = null

	backpack_contents = list(
	/obj/item/weapon/storage/box/space_suit/hos,
	/obj/item/weapon/storage/box/handcuffs,
	/obj/item/weapon/storage/box/flashbangs,
	/obj/item/weapon/melee/chainofcommand,
	/obj/item/device/remote_device/captain
	)

	implants = list(/obj/item/weapon/implant/mind_protect/loyalty)

	back_style = BACKPACK_STYLE_SECURITY

/datum/outfit/responders/security/leader/post_equip(mob/living/carbon/human/H)
	if(H.gender == "male")
		H.real_name = "[pick(global.first_names_male)] [pick(global.last_names)]"
	else
		H.real_name = "[pick(global.first_names_female)] [pick(global.last_names)]"
	H.name = H.real_name

	var/obj/item/clothing/under/S = H.w_uniform
	var/obj/item/clothing/accessory/A = new /obj/item/clothing/accessory/holster/armpit/revenant(S)
	A.on_attached(S, H, TRUE)
	LAZYADD(S.accessories, A)

	var/obj/item/weapon/card/id/ID = H.wear_id
	ID.registered_name = H.real_name
	ID.assignment = "Head of Security"
	ID.rank = ID.assignment
	ID.access = list(
		access_security, access_sec_doors, access_brig, access_armory,
		access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
		access_research, access_mining, access_medical, access_construction,
		access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway, access_detective
	)
	H.sec_hud_set_ID()

	H.mind.skills.add_available_skillset(/datum/skillset/hos)
	H.mind.skills.maximize_active_skills()

/datum/outfit/responders/marines
	name = "Responders: Marine"
	uniform = /obj/item/clothing/under/tactical/marinad
	suit = /obj/item/clothing/suit/marinad
	suit_store = /obj/item/weapon/gun/projectile/automatic/m41a
	head = /obj/item/clothing/head/helmet/tactical/marinad
	glasses = /obj/item/clothing/glasses/sunglasses/hud/sechud/tactical
	gloves = /obj/item/clothing/gloves/security/marinad
	belt = /obj/item/weapon/storage/belt/security/tactical/marines
	shoes = /obj/item/clothing/shoes/boots
	l_ear = /obj/item/device/radio/headset/headset_sec/marinad
	back = /obj/item/weapon/storage/backpack/dufflebag/marinad

	id = /obj/item/weapon/card/id/centcom/ert

	l_pocket = /obj/item/weapon/storage/pouch/flare/full
	r_pocket = /obj/item/weapon/storage/pouch/pistol_holster/marines

	backpack_contents = list(
	/obj/item/weapon/storage/box/space_suit/combat,
	/obj/item/weapon/storage/firstaid/small_firstaid_kit/combat,
	)

	var/list/rank = list("Pvt.", "PFC", "LCpl.", "Cpl.")
	var/assignment = "Marine"

/datum/outfit/responders/marines/post_equip(mob/living/carbon/human/H)
	H.real_name = "[pick(rank)] [pick(global.last_names)]"
	H.name = H.real_name
	var/obj/item/weapon/card/id/ID = H.wear_id
	ID.registered_name = H.real_name
	ID.assignment = assignment
	ID.rank = assignment

	H.sec_hud_set_ID()

	H.mind.skills.add_available_skillset(/datum/skillset/hos) //best fighter there is
	H.mind.skills.maximize_active_skills()

/datum/outfit/responders/marines/leader
	name = "Responders: Marine Squad Leader"

	head = /obj/item/clothing/head/helmet/tactical/marinad/leader
	suit_store = /obj/item/weapon/gun/projectile/automatic/m41a/launcher

	backpack_contents = list(
	/obj/item/weapon/storage/box/space_suit/combat,
	/obj/item/weapon/storage/firstaid/small_firstaid_kit/combat,
	/obj/item/ammo_casing/r4046/explosive/light,
	/obj/item/ammo_casing/r4046/explosive/light,
	/obj/item/ammo_casing/r4046/explosive/light,
	/obj/item/ammo_casing/r4046/explosive/light,
	/obj/item/ammo_casing/r4046/explosive/light
	)

	rank = list("Sergeant")
	assignment = "Marine Squad Leader"

/datum/outfit/responders/clown
	name = "Responders: Clown"
	uniform = /obj/item/clothing/under/rank/clown
	mask = /obj/item/clothing/mask/gas/clown_hat
	shoes = /obj/item/clothing/shoes/clown_shoes
	l_ear = /obj/item/device/radio/headset
	back = /obj/item/weapon/storage/backpack/clown

	id = /obj/item/weapon/card/id/clown

	r_hand = /obj/item/weapon/bikehorn
	l_hand = /obj/item/weapon/card/emag/clown

	r_pocket = /obj/item/weapon/reagent_containers/spray/lube

	backpack_contents = list(
	/obj/item/weapon/storage/box/space_suit/clown,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk,
	/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato
	)

/datum/outfit/responders/clown/post_equip(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_CLUMSY, GENETIC_MUTATION_TRAIT)
	H.real_name = "[pick(clown_names)], Clown That Emags Things"
	H.name = H.real_name

	var/obj/item/weapon/card/id/ID = H.wear_id
	ID.registered_name = H.real_name
	ID.assignment = "Clown"
	ID.rank = ID.assignment

	H.sec_hud_set_ID()

/obj/item/weapon/storage/belt/security/ert
	startswith = list(/obj/item/weapon/melee/baton, /obj/item/device/flash, /obj/item/weapon/grenade/flashbang = 2, /obj/item/weapon/handcuffs = 3)

/obj/item/weapon/storage/belt/security/tactical/marines
	startswith = list(/obj/item/ammo_box/magazine/m41a = 7, /obj/item/ammo_box/magazine/colt = 2)


/obj/item/weapon/storage/pouch/pistol_holster/ert
	startswith = list(/obj/item/weapon/gun/projectile/automatic/pistol/glock/spec)

/obj/item/weapon/storage/pouch/pistol_holster/pirates
	startswith = list(/obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon/sawn_off/beanbag)

/obj/item/weapon/storage/pouch/pistol_holster/security
	startswith = list(/obj/item/weapon/gun/projectile/automatic/pistol/glock)

/obj/item/weapon/storage/pouch/pistol_holster/marines
	startswith = list(/obj/item/weapon/gun/projectile/automatic/pistol/colt1911/dungeon)

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
	max_matter = 100

/obj/item/stack/sheet/metal/fifty
	amount = 50
	w_class = SIZE_SMALL

/obj/item/stack/sheet/glass/fifty
	amount = 50
	w_class = SIZE_SMALL

/obj/item/weapon/storage/pouch/medical_supply/combat
	name = "combat medical supply pouch"
	desc = "Can hold large amount of combat medical equipment."
	icon_state = "medical_supply"
	item_state = "medical_supply"

	max_storage_space = 18
	storage_slots = 9
	max_w_class = SIZE_SMALL

	startswith = list(
		/obj/item/weapon/reagent_containers/hypospray/combat/bleed,
		/obj/item/weapon/reagent_containers/hypospray/combat/bruteburn,
		/obj/item/weapon/reagent_containers/hypospray/combat/dexalin,
		/obj/item/weapon/reagent_containers/hypospray/combat/atoxin,
		/obj/item/weapon/reagent_containers/hypospray/combat/intdam,
		/obj/item/weapon/reagent_containers/hypospray/combat/pain,
		/obj/item/weapon/reagent_containers/hypospray/combat/bone,
		/obj/item/stack/medical/suture,
		/obj/item/device/healthanalyzer,
	)

/obj/item/clothing/accessory/holster/armpit/taser
	holstered = /obj/item/weapon/gun/energy/taser

/obj/item/clothing/accessory/holster/armpit/revenant
	holstered = /obj/item/weapon/gun/energy/gun/hos

/obj/item/weapon/storage/box/space_suit
	name = "boxed space suit"
	desc = "It's a boxed space suit with breathing mask and emergency oxygen tank."

/obj/item/weapon/storage/box/space_suit/soviet/atom_init()
	. = ..()
	new /obj/item/clothing/head/helmet/space/syndicate/civilian(src)
	new /obj/item/clothing/suit/space/syndicate/civilian(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)

/obj/item/weapon/storage/box/space_suit/security/atom_init()
	. = ..()
	new /obj/item/clothing/head/helmet/space/rig/security(src)
	new /obj/item/clothing/suit/space/rig/security(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)

/obj/item/weapon/storage/box/space_suit/hos/atom_init()
	. = ..()
	new /obj/item/clothing/head/helmet/space/rig/security/hos(src)
	new /obj/item/clothing/suit/space/rig/security/hos(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)

/obj/item/weapon/storage/box/space_suit/combat/atom_init()
	. = ..()
	new /obj/item/clothing/head/helmet/space/syndicate/striker(src)
	new /obj/item/clothing/suit/space/syndicate/striker(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)

/obj/item/weapon/storage/box/space_suit/clown/atom_init()
	. = ..()
	new /obj/item/clothing/head/helmet/space/clown(src)
	new /obj/item/clothing/suit/space/clown(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)
