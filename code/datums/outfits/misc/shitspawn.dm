/datum/outfit/space_gear
	name = "standard space gear"

	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/black

	head = /obj/item/clothing/head/helmet/space/globose
	suit = /obj/item/clothing/suit/space/globose

	back = /obj/item/weapon/tank/jetpack/oxygen
	mask = /obj/item/clothing/mask/breath

/datum/outfit/space_gear/post_equip()
	var/obj/item/weapon/tank/jetpack/J = back
	J.toggle()
	J.Topic(null, list("stat" = 1))

/datum/outfit/tournament
	name = "tournament standard red"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/black

	suit = /obj/item/clothing/suit/armor/vest
	head = /obj/item/clothing/head/helmet/thunderdome

	r_hand = /obj/item/weapon/gun/energy/pulse_rifle/destroyer
	l_hand = /obj/item/weapon/kitchenknife
	r_pocket = /obj/item/weapon/grenade/smokebomb

/datum/outfit/tournament/green
	name = "tournament standard green"

	uniform = /obj/item/clothing/under/color/green

/datum/outfit/tournament_ganster
	name = "tournament gangster"

	uniform = /obj/item/clothing/under/det
	shoes = /obj/item/clothing/shoes/black
	
	suit = /obj/item/clothing/suit/storage/det_suit
	glasses = /obj/item/clothing/glasses/thermal/monocle\
	head = /obj/item/clothing/head/det_hat

	r_hand = /obj/item/weapon/gun/projectile
	l_pocket = /obj/item/ammo_box/a357

/datum/outfit/tournament_chief
	name = "tournament chef"
	
	uniform = /obj/item/clothing/under/rank/chef
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/chefhat

	r_hand = /obj/item/weapon/kitchen/rollingpin
	l_hand = /obj/item/weapon/kitchenknife
	r_pocket = /obj/item/weapon/kitchenknife
	suit_store = /obj/item/weapon/kitchenknife

/datum/outfit/tournament_janitor
	name = "tournament janitor"
	
	uniform = /obj/item/clothing/under/rank/janitor
	shoes = /obj/item/clothing/shoes/black
	backpack = /obj/item/weapon/storage/backpack

	r_hand = /obj/item/weapon/mop
	l_hand = /obj/item/weapon/reagent_containers/glass/bucket/full

	r_pocket = /obj/item/weapon/grenade/chem_grenade/cleaner
	l_pocket = /obj/item/weapon/grenade/chem_grenade/cleaner
	backpack_contents = list(
		/obj/item/stack/tile/plasteel,
		/obj/item/stack/tile/plasteel,
		/obj/item/stack/tile/plasteel,
		/obj/item/stack/tile/plasteel,
		/obj/item/stack/tile/plasteel,
		/obj/item/stack/tile/plasteel,
		/obj/item/stack/tile/plasteel,
		/obj/item/stack/tile/plasteel,
	)

/datum/outfit/pirate
	name = "pirate"

	uniform = /obj/item/clothing/under/pirate
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/bandana
	glasses = /obj/item/clothing/glasses/eyepatch
	r_hand = /obj/item/weapon/melee/energy/sword/pirate

/datum/outfit/pirate/space
	name = "space pirate"

	suit = /obj/item/clothing/suit/space/pirate
	head = /obj/item/clothing/head/helmet/space/pirate

/datum/outfit/soviet_soldier
	name = "soviet soldier"
		
	uniform = /obj/item/clothing/under/soviet
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/ushanka

/datum/outfit/tunnel_clown
	name = "tunnel clown"

	uniform = /obj/item/clothing/under/rank/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	gloves = /obj/item/clothing/gloves/black
	mask = /obj/item/clothing/mask/gas/clown_hat
	head = /obj/item/clothing/head/chaplain_hood
	l_ear = /obj/item/device/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	suit = /obj/item/clothing/suit/chaplain_hoodie
	l_pocket = /obj/item/weapon/reagent_containers/food/snacks/grown/banana
	r_pocket = /obj/item/weapon/bikehorn
	id = /obj/item/weapon/card/id/clown/tunnel
	r_hand = /obj/item/weapon/fireaxe

/datum/outfit/tunnel_clown/post_equip(mob/living/carbon/human/H)
	var/obj/item/weapon/card/id/W = id
	if(istype(W))
		W.assign(H.real_name)

/datum/outfit/masked_killer
	name = "masked killer"
	
	uniform = /obj/item/clothing/under/overalls
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/latex
	mask = /obj/item/clothing/mask/surgical
	head = /obj/item/clothing/head/welding
	l_ear = /obj/item/device/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	suit = /obj/item/clothing/suit/apron
	l_pocket = /obj/item/weapon/kitchenknife
	r_pocket = /obj/item/weapon/scalpel
	r_hand = /obj/item/weapon/fireaxe/fire_axe

/datum/outfit/masked_killer/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.contents)
		if(!istype(carried_item, /obj/item/weapon/implant)
			carried_item.add_blood(H)//Oh yes, there will be blood...

/datum/outfit/assasin
	name = "assassin"
	
	uniform = /obj/item/clothing/under/suit_jacket
	shoes = /obj/item/clothing/shoes/black
	gloves = /obj/item/clothing/gloves/black
	l_ear = /obj/item/device/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses
	suit = /obj/item/clothing/suit/wcoat
	l_pocket = /obj/item/weapon/melee/energy/sword
	l_hand = /item/weapon/storage/secure/briefcase
	belt = /obj/item/device/pda/heads
	id = /obj/item/weapon/card/id/syndicate/reaper

/datum/outfit/assasin/post_equip(mob/living/carbon/human/H)
	var/obj/item/weapon/storage/secure/briefcase/sec_briefcase = l_hand
	for(var/obj/item/briefcase_item in sec_briefcase)
		qdel(briefcase_item)
	for(var/i in 1 to 3)
		sec_briefcase.contents += new /obj/item/weapon/spacecash/c1000
	sec_briefcase.contents += list(
		new /obj/item/weapon/gun/energy/crossbow,
		new /obj/item/weapon/gun/projectile/revolver/mateba,
		new /obj/item/ammo_box/a357,
		new /obj/item/weapon/plastique,
	)

	var/obj/item/device/pda/heads/pda = belt
	if(istype(pda))
		pda.ownjob = "Reaper"
		pda.assign(H.real_name)

	var/obj/item/weapon/card/id/W = id
	if(istype(W))
		W.assign(H.real_name)
	
/datum/outfit/preparation
	name = "preparation"

	uniform = /obj/item/clothing/under/color/black
	shoes = /obj/item/clothing/shoes/boots
	glasses = /obj/item/clothing/glasses/sunglasses
	l_ear = /obj/item/device/radio/headset
	back = /obj/item/weapon/storage/backpack/satchel/norm
	l_pocket = /obj/item/device/flashlight
	gloves = /obj/item/clothing/gloves/black
	id = /obj/item/weapon/card/id/syndicate

/datum/outfit/preparation/post_equip(mob/living/carbon/human/H)
	var/obj/item/weapon/card/id/syndicate/W = id
	if(istype(W))
		W.assignment = "Unknown"
		W.assign(H.real_name)
		W.access = get_all_accesses()

/datum/outfit/death_squad
	name = "death squad"

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
		/obj/item/weapon/storage/box,
		/obj/item/ammo_box/a357,
		/obj/item/weapon/storage/firstaid/regular,
		/obj/item/weapon/storage/box/flashbangs,
		/obj/item/device/flashlight,
		/obj/item/weapon/plastique,
	)

	l_pocket = /obj/item/weapon/melee/energy/sword
	r_pocket = /obj/item/weapon/grenade/flashbang
	suit_store = /obj/item/weapon/tank/emergency_oxygen
	belt = /obj/item/weapon/gun/projectile/revolver/mateba

	r_hand = /obj/item/weapon/gun/energy/pulse_rifle
	implants = list(/obj/item/weapon/implant/mind_protect/loyalty)
	id = /obj/item/weapon/card/id/centcom

/datum/outfit/death_squad/post_equip(mob/living/carbon/human/H)
	var/obj/item/weapon/card/id/W = id
	if(istype(W))
		W.assign(H.real_name)

/datum/outfit/death_squad/leader
	name = "death squad leader"
	
	uniform = /obj/item/clothing/under/rank/centcom_officer

	backpack_contents = list(
		/obj/item/weapon/storage/box,
		/obj/item/ammo_box/a357,
		/obj/item/weapon/storage/firstaid/regular,
		/obj/item/weapon/storage/box/flashbangs,
		/obj/item/device/flashlight,
		/obj/item/weapon/pinpointer,
		/obj/item/weapon/disk/nuclear,
	)

/datum/outfit/syndicate_commando
	name = "syndicate commando"
	
	l_ear = /obj/item/device/radio/headset/syndicate

	uniform = /obj/item/clothing/under/syndicate
	implants = list(/obj/item/weapon/implant/dexplosive)
	shoes = /obj/item/clothing/shoes/boots/combat
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/syndicate
	glasses = /obj/item/clothing/glasses/thermal
	back = /obj/item/weapon/storage/backpack/security
	l_pocket = /obj/item/weapon/melee/energy/sword
	r_pocket = /obj/item/weapon/grenade/empgrenade
	belt = /obj/item/weapon/gun/projectile/automatic/silenced

	backpack_contents = list(
		/obj/item/weapon/storage/box,
		/obj/item/ammo_box/magazine/sm45,
		/obj/item/ammo_box/magazine/sm45,
		/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian/strike,
		/obj/item/weapon/storage/firstaid/small_firstaid_kit/nutriment,
		/obj/item/device/radio/uplink/strike,
	)

	suit = /obj/item/clothing/suit/space/rig/syndi/elite
	head = /obj/item/clothing/head/helmet/space/rig/syndi/elite
	suit_store = /obj/item/weapon/tank/oxygen/red
	id = /obj/item/weapon/card/id/syndicate/strike

/datum/outfit/syndicate_commando/post_equip(mob/living/carbon/human/H)
	var/obj/item/clothing/under/syndicate/US = H.w_uniform
	if(istype(US))
		var/obj/item/clothing/accessory/storage/syndi_vest/SV = new (US)
		US.accessories += SV
		SV.on_attached(US, H, TRUE)
		new /obj/item/weapon/screwdriver/power(SV.hold)
		new /obj/item/weapon/wirecutters/power(SV.hold)
		new /obj/item/weapon/weldingtool/largetank(SV.hold)
		new /obj/item/device/multitool(SV.hold)

	var/obj/item/weapon/card/id/syndicate/W = id
	if(istype(W))
		W.assign(H.real_name)

/datum/outfit/syndicate_commando/leader
	name = "syndicate commando comander"
	
	backpack_contents = list(
		/obj/item/weapon/storage/box,
		/obj/item/ammo_box/magazine/sm45,
		/obj/item/ammo_box/magazine/sm45,
		/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian/strike,
		/obj/item/weapon/storage/firstaid/small_firstaid_kit/nutriment,
		/obj/item/device/radio/uplink/strike_leader,
		/obj/item/weapon/pinpointer/advpinpointer,
	)

	suit = /obj/item/clothing/suit/space/rig/syndi/elite/commander
	head = /obj/item/clothing/head/helmet/space/rig/syndi/elite/commander
	id = /obj/item/weapon/card/id/syndicate/strike/leader

/datum/outfit/nanotrasen
	name = null
	var/ownjob

/datum/outfit/nanotrasen/post_equip(mob/living/carbon/human/H)
	var/obj/item/device/pda/pda = locate() in H
	if(pda)
		pda.ownjob = ownjob
		pda.assign(H.real_name)

	var/obj/item/weapon/card/id/W = locate() in H
	if(W)
		W.assignment = ownjob
		W.assign(H.real_name)

/datum/outfit/nanotrasen/representatives
	name = "nanotrasen representative"
	ownjob = "NanoTrasen Navy Representative"
	
	uniform = /obj/item/clothing/under/rank/centcom/representative
	shoes = /obj/item/clothing/shoes/centcom
	gloves = /obj/item/clothing/gloves/white
	l_ear = /obj/item/device/radio/headset/heads/hop
	r_pocket = /obj/item/device/pda/heads
	l_pocket = /obj/item/clothing/glasses/sunglasses
	belt = /obj/item/weapon/clipboard
	id = /obj/item/weapon/card/id/centcom

/datum/outfit/nanotrasen/officer
	name = "nanotrasen officer"
	ownjob = "NanoTrasen Navy Officer"

	uniform = /obj/item/clothing/under/rank/centcom/officer
	shoes = /obj/item/clothing/shoes/centcom
	gloves = /obj/item/clothing/gloves/white
	l_ear = /obj/item/device/radio/headset/heads/captain
	head = /obj/item/clothing/head/beret/centcomofficer
	r_pocket = /obj/item/device/pda/heads
	l_pocket = /obj/item/clothing/glasses/sunglasses
	belt = /obj/item/weapon/gun/energy
	id = /obj/item/weapon/card/id/centcom

/datum/outfit/nanotrasen/captain
	name = "nanotrasen captain"
	ownjob = "NanoTrasen Navy Captain"

	uniform = /obj/item/clothing/under/rank/centcom/captain
	shoes = /obj/item/clothing/shoes/centcom
	gloves = /obj/item/clothing/gloves/white
	l_ear = /obj/item/device/radio/headset/heads/captain
	head = /obj/item/clothing/head/beret/centcomcaptain
	r_pocket = /obj/item/device/pda/heads
	l_pocket = /obj/item/clothing/glasses/sunglasses
	belt = /obj/item/weapon/gun/energy
	id = /obj/item/weapon/card/id/centcom

/datum/outfit/psyops_officer
	name = "psyops officer"

	uniform = /obj/item/clothing/under/darkred
	head = /obj/item/clothing/head/helmet/psyamp
	suit = /obj/item/clothing/suit/armor/vest/fullbody/psy_robe
	shoes = /obj/item/clothing/shoes/boots/combat
	gloves = /obj/item/clothing/gloves/black/silence
	l_hand = /obj/item/weapon/paper/psyops_starting_guide
	r_hand = /obj/item/weapon/nullrod/forcefield_staff
	r_pocket = /obj/item/weapon/storage/firstaid/small_firstaid_kit/nutriment
	l_pocket = /obj/item/weapon/storage/firstaid/small_firstaid_kit/psyops
	l_ear = /obj/item/clothing/ears/earmuffs(M), SLOT_L_EAR)

/datum/outfit/psyops_officer/post_equip(mob/living/carbon/human/H)
		H.set_species(SKRELL)
		H.r_eyes = 102
		H.g_eyes = 204
		H.b_eyes = 255

		var/list/skin_variations = list(
			list(0, 0, 0),
			list(28, 28, 28),
			list(0, 0, 102),
			list(63, 31, 0),
			list(0, 51, 0),
		)

		var/list/variation = pick(skin_variations)

		H.r_skin = variation[1]
		H.g_skin = variation[2]
		H.b_skin = variation[3]

		H.r_hair = variation[1]
		H.g_hair = variation[2]
		H.b_hair = variation[3]

		H.universal_speak = TRUE
		H.universal_understand = TRUE

		M.mutations += list(NO_SHOCK, TK, REMOTE_TALK)
		M.update_mutations()

	name = "velocity officer"
		/obj/item/clothing/under/det/velocity(M), SLOT_W_UNIFORM)
		/obj/item/clothing/shoes/boots/combat(M), SLOT_SHOES)
		/obj/item/clothing/gloves/combat(M), SLOT_GLOVES)
		/obj/item/device/radio/headset/velocity(M), SLOT_L_EAR)
		/obj/item/weapon/storage/backpack/satchel(M), SLOT_BACK)

			var/obj/item/device/pda/velocity/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Velocity Officer"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_to_slot_or_del(pda, SLOT_BELT)
		/obj/item/clothing/glasses/sunglasses/hud/sechud(M), SLOT_GLASSES)

			spawned_card = new/obj/item/weapon/card/id/velocity(M)
			spawned_card.assignment = "Velocity Officer"
			spawned_card.name = "[M.real_name]'s ID Card ([spawned_card.assignment])"
			spawned_card.rank = "Velocity Officer"
			spawned_card.registered_name = M.real_name
			M.equip_to_slot_or_del(spawned_card, SLOT_WEAR_ID)

		name = M.mind
				M.mind.assigned_role = "Velocity Officer"

			M.universal_speak = TRUE
			M.universal_understand = TRUE

	name = "velocity chief"
		/obj/item/clothing/under/rank/head_of_security/corp(M), SLOT_W_UNIFORM)
		/obj/item/clothing/shoes/boots/combat(M), SLOT_SHOES)
		/obj/item/clothing/gloves/combat(M), SLOT_GLOVES)
		/obj/item/device/radio/headset/velocity/chief(M), SLOT_L_EAR)
		/obj/item/clothing/head/beret/sec/hos(M), SLOT_HEAD)
		/obj/item/clothing/suit/storage/det_suit/velocity(M), SLOT_WEAR_SUIT)

			var/obj/item/weapon/storage/backpack/satchel/back_storage = new /obj/item/weapon/storage/backpack/satchel(M)
			M.equip_to_slot_or_del(back_storage, SLOT_BACK)
			new /obj/item/weapon/storage/box/handcuffs(back_storage)
			new /obj/item/device/flash(back_storage)
			new /obj/item/weapon/storage/belt/security(back_storage)
			new /obj/item/device/megaphone(back_storage)
			new /obj/item/device/contraband_finder/deluxe(back_storage)
			new /obj/item/device/reagent_scanner(back_storage)
			new /obj/item/weapon/stamp/cargo_industries(back_storage)

			var/obj/item/device/pda/velocity/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Velocity Chief"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			var/obj/item/weapon/storage/pouch/baton_holster/BH = new(M)
			new /obj/item/weapon/melee/classic_baton(BH)
			BH.update_icon()
			M.equip_to_slot_or_del(BH, SLOT_L_STORE)

			var/obj/item/weapon/storage/pouch/pistol_holster/PH = new(M)
			var/obj/item/weapon/gun/energy/laser/selfcharging/SG = new /obj/item/weapon/gun/energy/laser/selfcharging(PH)
			SG.name = "laser pistol rifle"
			SG.can_be_holstered = TRUE
			PH.update_icon()
			M.equip_to_slot_or_del(PH, SLOT_R_STORE)

			M.equip_to_slot_or_del(pda, SLOT_BELT)
		/obj/item/clothing/glasses/sunglasses/hud/sechud(M), SLOT_GLASSES)

			spawned_card = new/obj/item/weapon/card/id/velocity(M)
			spawned_card.assignment = "Velocity Chief"
			spawned_card.name = "[M.real_name]'s ID Card ([spawned_card.assignment])"
			spawned_card.access += get_all_accesses()
			spawned_card.rank = "Velocity Chief"
			spawned_card.registered_name = M.real_name
			M.equip_to_slot_or_del(spawned_card, SLOT_WEAR_ID)

			var/obj/item/weapon/implant/mind_protect/mindshield/IMP = new(M)
			IMP.inject(M)

		name = M.mind
				M.mind.assigned_role = "Velocity Chief"

			M.universal_speak = TRUE
			M.universal_understand = TRUE

	name = "velocity doctor"
		/obj/item/clothing/under/det/velocity(M), SLOT_W_UNIFORM)
		/obj/item/clothing/shoes/brown(M), SLOT_SHOES)
		/obj/item/clothing/gloves/latex/nitrile(M), SLOT_GLOVES)
		/obj/item/clothing/suit/storage/labcoat/blue(M), SLOT_WEAR_SUIT)
		/obj/item/device/radio/headset/velocity(M), SLOT_L_EAR)
		/obj/item/weapon/storage/backpack/satchel/med(M), SLOT_BACK)

			var/obj/item/device/pda/velocity/doctor/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Velocity Medical Doctor"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_to_slot_or_del(pda, SLOT_BELT)
		/obj/item/clothing/glasses/hud/health(M), SLOT_GLASSES)

		/obj/item/weapon/reagent_containers/hypospray/cmo(M), SLOT_L_STORE)

			spawned_card = new/obj/item/weapon/card/id/velocity(M)
			spawned_card.assignment = "Velocity Medical Doctor"
			spawned_card.name = "[M.real_name]'s ID Card ([spawned_card.assignment])"
			spawned_card.rank = "Velocity Medical Doctor"
			spawned_card.registered_name = M.real_name
			M.equip_to_slot_or_del(spawned_card, SLOT_WEAR_ID)

		name = M.mind
				M.mind.assigned_role = "Velocity Medical Doctor"

			M.universal_speak = TRUE
			M.universal_understand = TRUE

	name = "emergency response team"
		/obj/item/clothing/under/rank/centcom_officer(M), SLOT_W_UNIFORM)
		/obj/item/clothing/shoes/boots/swat(M), SLOT_SHOES)
		/obj/item/clothing/gloves/swat(M), SLOT_GLOVES)
		/obj/item/device/radio/headset/ert(M), SLOT_L_EAR)
		/obj/item/weapon/gun/energy/gun(M), SLOT_BELT)
		/obj/item/clothing/glasses/sunglasses(M), SLOT_GLASSES)
		/obj/item/weapon/storage/backpack/satchel(M), SLOT_BACK)

			var/obj/item/weapon/card/id/centcom/ert/W = new(M)
			W.assignment = "Emergency Response Team"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, SLOT_WEAR_ID)

	name = "special ops officer"
		/obj/item/clothing/under/syndicate/combat(M), SLOT_W_UNIFORM)
		/obj/item/clothing/suit/armor/swat/officer(M), SLOT_WEAR_SUIT)
		/obj/item/clothing/shoes/boots/combat(M), SLOT_SHOES)
		/obj/item/clothing/gloves/combat(M), SLOT_GLOVES)
		/obj/item/device/radio/headset/heads/captain(M), SLOT_L_EAR)
		/obj/item/clothing/glasses/thermal/eyepatch(M), SLOT_GLASSES)
		/obj/item/clothing/mask/cigarette/cigar/havana(M), SLOT_WEAR_MASK)
		/obj/item/clothing/head/helmet/space/deathsquad/beret(M), SLOT_HEAD)
		/obj/item/weapon/gun/energy/pulse_rifle/M1911(M), SLOT_BELT)
		/obj/item/weapon/lighter/zippo(M), SLOT_R_STORE)
		/obj/item/weapon/storage/backpack/satchel(M), SLOT_BACK)

			var/obj/item/weapon/card/id/centcom/W = new(M)
			W.assignment = "Special Operations Officer"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, SLOT_WEAR_ID)

	name = "blue wizard"
		/obj/item/clothing/under/lightpurple(M), SLOT_W_UNIFORM)
		/obj/item/clothing/suit/wizrobe(M), SLOT_WEAR_SUIT)
		/obj/item/clothing/shoes/sandal(M), SLOT_SHOES)
		/obj/item/device/radio/headset(M), SLOT_L_EAR)
		/obj/item/clothing/head/wizard(M), SLOT_HEAD)
		/obj/item/weapon/teleportation_scroll(M), SLOT_R_STORE)
		/obj/item/weapon/spellbook(M), SLOT_R_HAND)
		/obj/item/weapon/staff(M), SLOT_L_HAND)
		/obj/item/weapon/storage/backpack(M), SLOT_BACK)
		/obj/item/weapon/storage/box(M), SLOT_IN_BACKPACK)

	name = "red wizard"
		/obj/item/clothing/under/lightpurple(M), SLOT_W_UNIFORM)
		/obj/item/clothing/suit/wizrobe/red(M), SLOT_WEAR_SUIT)
		/obj/item/clothing/shoes/sandal(M), SLOT_SHOES)
		/obj/item/device/radio/headset(M), SLOT_L_EAR)
		/obj/item/clothing/head/wizard/red(M), SLOT_HEAD)
		/obj/item/weapon/teleportation_scroll(M), SLOT_R_STORE)
		/obj/item/weapon/spellbook(M), SLOT_R_HAND)
		/obj/item/weapon/staff(M), SLOT_L_HAND)
		/obj/item/weapon/storage/backpack(M), SLOT_BACK)
		/obj/item/weapon/storage/box(M), SLOT_IN_BACKPACK)

	name = "marisa wizard"
		/obj/item/clothing/under/lightpurple(M), SLOT_W_UNIFORM)
		/obj/item/clothing/suit/wizrobe/marisa(M), SLOT_WEAR_SUIT)
		/obj/item/clothing/shoes/sandal/marisa(M), SLOT_SHOES)
		/obj/item/device/radio/headset(M), SLOT_L_EAR)
		/obj/item/clothing/head/wizard/marisa(M), SLOT_HEAD)
		/obj/item/weapon/teleportation_scroll(M), SLOT_R_STORE)
		/obj/item/weapon/spellbook(M), SLOT_R_HAND)
		/obj/item/weapon/staff(M), SLOT_L_HAND)
		/obj/item/weapon/storage/backpack(M), SLOT_BACK)
		/obj/item/weapon/storage/box(M), SLOT_IN_BACKPACK)
	name = "soviet admiral"
		/obj/item/clothing/head/hgpiratecap(M), SLOT_HEAD)
		/obj/item/clothing/shoes/boots/combat(M), SLOT_SHOES)
		/obj/item/clothing/gloves/combat(M), SLOT_GLOVES)
		/obj/item/device/radio/headset/heads/captain(M), SLOT_L_EAR)
		/obj/item/clothing/glasses/thermal/eyepatch(M), SLOT_GLASSES)
		/obj/item/clothing/suit/hgpirate(M), SLOT_WEAR_SUIT)
		/obj/item/weapon/storage/backpack/satchel(M), SLOT_BACK)
		/obj/item/weapon/gun/projectile/revolver/mateba(M), SLOT_BELT)
		/obj/item/clothing/under/soviet(M), SLOT_W_UNIFORM)
			var/obj/item/weapon/card/id/W = new(M)
			W.assignment = "Admiral"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, SLOT_WEAR_ID)
	name = "tourist"
		/obj/item/clothing/under/tourist(M), SLOT_W_UNIFORM)
		/obj/item/clothing/shoes/tourist(M), SLOT_SHOES)
		/obj/item/device/radio/headset(M), SLOT_L_EAR)

	name = "jolly gravedigger"
		/obj/item/clothing/shoes/jolly_gravedigger(M), SLOT_SHOES)
		/obj/item/clothing/under/suit_jacket/charcoal(M), SLOT_W_UNIFORM)
		/obj/item/clothing/gloves/white(M), SLOT_GLOVES)
		/obj/item/clothing/glasses/aviator_mirror(M), SLOT_GLASSES)
		/obj/item/clothing/head/beret/black(M), SLOT_HEAD)

			M.real_name = pick("Tyler", "Tyrone", "Tom", "Timmy", "Takeuchi", "Timber", "Tyrell")

			M.s_tone = max(min(round(rand(130, 170)), 220), 1)
			M.s_tone = -M.s_tone + 35

			M.apply_recolor()

	name = "jolly gravedigger supreme"
		/obj/item/clothing/shoes/jolly_gravedigger(M), SLOT_SHOES)
		/obj/item/clothing/under/suit_jacket/charcoal(M), SLOT_W_UNIFORM)
		/obj/item/clothing/gloves/white(M), SLOT_GLOVES)
		/obj/item/clothing/glasses/aviator_mirror(M), SLOT_GLASSES)
		/obj/item/clothing/head/that(M), SLOT_HEAD)

			M.real_name = "Jimbo"

			M.s_tone = max(min(round(rand(130, 170)), 220), 1)
			M.s_tone = -M.s_tone + 35

			M.apply_recolor()