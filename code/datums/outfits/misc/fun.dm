/datum/outfit/fun
	var/obj/item/weapon/card/id/spawned_card = null // If you want them to have an account with money.
	var/dresspacks_without_money = FALSE

/datum/outfit/fun/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	if(!dresspacks_without_money && M.mind)
		if(M.mind.initial_account)
			if(M.mind.initial_account.owner_name != M.real_name)
				qdel(M.mind.initial_account)
				M.mind.initial_account = null
				create_random_account_and_store_in_mind(M)

				if(spawned_card)
					spawned_card.associated_account_number = M.mind.initial_account.account_number
			//else do nothing
		else
			create_random_account_and_store_in_mind(M)

			if(spawned_card)
				spawned_card.associated_account_number = M.mind.initial_account.account_number

/datum/outfit/fun/tourist
	name = "Tourist"

	uniform = /obj/item/clothing/under/tourist
	shoes = /obj/item/clothing/shoes/tourist
	l_ear = /obj/item/device/radio/headset

/datum/outfit/fun/jolly_gravedigger
	name = "Jolly Gravedigger"

	shoes = /obj/item/clothing/shoes/jolly_gravedigger
	uniform = /obj/item/clothing/under/suit_jacket/charcoal
	gloves = /obj/item/clothing/gloves/white
	glasses = /obj/item/clothing/glasses/aviator_mirror
	head = /obj/item/clothing/head/beret/black

/datum/outfit/fun/jolly_gravedigger/pre_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	M.real_name = pick("Tyler", "Tyrone", "Tom", "Timmy", "Takeuchi", "Timber", "Tyrell")

	M.s_tone = max(min(round(rand(130, 170)), 220), 1)
	M.s_tone = -M.s_tone + 35

	M.apply_recolor()

/datum/outfit/fun/jolly_gravedigger/supreme
	name = "Jolly Gravedigger Supreme"

	shoes = /obj/item/clothing/shoes/jolly_gravedigger
	uniform = /obj/item/clothing/under/suit_jacket/charcoal
	gloves = /obj/item/clothing/gloves/white
	glasses = /obj/item/clothing/glasses/aviator_mirror
	head = /obj/item/clothing/head/that

/datum/outfit/fun/jolly_gravedigger/supreme/pre_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	M.real_name = "Jimbo"


/datum/outfit/fun/standard_space_gear
	name = "Standard Space Gear"

	shoes = /obj/item/clothing/shoes/black
	mask = /obj/item/clothing/mask/breath
	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/space/globose
	head = /obj/item/clothing/head/helmet/space/globose

/datum/outfit/fun/standard_space_gear/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	var/obj/item/weapon/tank/jetpack/J = new /obj/item/weapon/tank/jetpack/oxygen(M)
	M.equip_to_slot_or_del(J, SLOT_BACK)
	J.toggle()

	J.Topic(null, list("stat" = 1))

/datum/outfit/fun/standard_space_gear
	name = "Standard Space Gear Green"

	uniform = /obj/item/clothing/under/color/green
	shoes = /obj/item/clothing/shoes/black

	suit = /obj/item/clothing/suit/armor/vest
	head = /obj/item/clothing/head/helmet/thunderdome

	r_hand = /obj/item/weapon/gun/energy/pulse_rifle/destroyer
	l_hand = /obj/item/weapon/kitchenknife
	r_pocket = /obj/item/weapon/grenade/smokebomb

/datum/outfit/fun/standard_space_gear/red
	name = "Standard Space Gear Red"

	uniform = /obj/item/clothing/under/color/red

//gangster are supposed to fight each other. --rastaf0
/datum/outfit/fun/tournament_gangster
	name = "Tournament Gangster"

	uniform = /obj/item/clothing/under/det
	shoes = /obj/item/clothing/shoes/black

	suit = /obj/item/clothing/suit/storage/det_suit
	glasses = /obj/item/clothing/glasses/thermal/monocle
	head = /obj/item/clothing/head/det_hat

	r_hand = /obj/item/weapon/gun/projectile
	l_pocket = /obj/item/ammo_box/a357

//Steven Seagal FTW
/datum/outfit/fun/tournament_chef
	name = "Tournament Chef"

	uniform = /obj/item/clothing/under/rank/chef
	suit = /obj/item/clothing/suit/chef
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/chefhat

	r_hand = /obj/item/weapon/kitchen/rollingpin
	l_hand = /obj/item/weapon/kitchenknife
	r_pocket = /obj/item/weapon/kitchenknife
	suit_store = /obj/item/weapon/kitchenknife

/datum/outfit/fun/tournament_janitor
	name = "Tournament Janitor"

	uniform = /obj/item/clothing/under/rank/janitor
	shoes = /obj/item/clothing/shoes/black
	r_hand = /obj/item/weapon/mop

	back = /obj/item/weapon/storage/backpack
	r_pocket = /obj/item/weapon/grenade/chem_grenade/cleaner
	l_pocket = /obj/item/weapon/grenade/chem_grenade/cleaner
	backpack_contents = list(/obj/item/stack/tile/plasteel = 7)

/datum/outfit/fun/tournament_janitor/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	var/obj/item/weapon/reagent_containers/glass/bucket/bucket = new(M)
	bucket.reagents.add_reagent("water", 70)
	M.equip_to_slot_or_del(bucket, SLOT_L_HAND)

/datum/outfit/fun/pirate
	name = "Pirate"

	uniform = /obj/item/clothing/under/pirate
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/bandana
	glasses = /obj/item/clothing/glasses/eyepatch
	r_hand = /obj/item/weapon/melee/energy/sword/pirate

/datum/outfit/fun/space_pirate
	name = "Space Pirate"

	uniform = /obj/item/clothing/under/pirate
	shoes = /obj/item/clothing/shoes/brown
	suit = /obj/item/clothing/suit/space/pirate
	head = /obj/item/clothing/head/helmet/space/pirate
	glasses = /obj/item/clothing/glasses/eyepatch

	r_hand = /obj/item/weapon/melee/energy/sword/pirate

/datum/outfit/fun/soviet_soldier
	name = "Soviet Soldier"

	uniform = /obj/item/clothing/under/soviet
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/ushanka

//Tunnel clowns rule!
/datum/outfit/fun/tunnel_clown
	name = "Tunnel Clown"

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
	r_hand = /obj/item/weapon/twohanded/fireaxe

/datum/outfit/fun/tunnel_clown/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()

	var/obj/item/weapon/card/id/W = new(M)
	W.assignment = "Tunnel Clown!"
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.access = get_all_accesses()
	W.registered_name = M.real_name
	M.equip_to_slot_or_del(W, SLOT_WEAR_ID)

/datum/outfit/fun/masked_killer
	name = "Masked Killer"

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
	r_hand = /obj/item/weapon/twohanded/fireaxe

/datum/outfit/fun/masked_killer/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	for(var/obj/item/carried_item in M.contents)
		if(!istype(carried_item, /obj/item/weapon/implant))//If it's not an implant.
			carried_item.add_blood(M)//Oh yes, there will be blood...

/datum/outfit/fun/assassin
	name = "Assassin"

	uniform = /obj/item/clothing/under/suit_jacket
	shoes = /obj/item/clothing/shoes/black
	gloves = /obj/item/clothing/gloves/black
	l_ear = /obj/item/device/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses
	suit = /obj/item/clothing/suit/wcoat
	l_pocket = /obj/item/weapon/melee/energy/sword

/datum/outfit/fun/assassin/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	var/obj/item/weapon/storage/secure/briefcase/sec_briefcase = new(M)
	for(var/obj/item/briefcase_item in sec_briefcase)
		qdel(briefcase_item)
	for(var/i=3, i>0, i--)
		sec_briefcase.contents += new /obj/item/weapon/spacecash/c1000
	sec_briefcase.contents += new /obj/item/weapon/gun/energy/crossbow
	sec_briefcase.contents += new /obj/item/weapon/gun/projectile/revolver/mateba
	sec_briefcase.contents += new /obj/item/ammo_box/a357
	sec_briefcase.contents += new /obj/item/weapon/plastique
	M.equip_to_slot_or_del(sec_briefcase, SLOT_L_HAND)

	var/obj/item/device/pda/heads/pda = new(M)
	pda.owner = M.real_name
	pda.ownjob = "Reaper"
	pda.name = "PDA-[M.real_name] ([pda.ownjob])"
	M.equip_to_slot_or_del(pda, SLOT_BELT)

	var/obj/item/weapon/card/id/syndicate/W = new(M)
	W.assignment = "Reaper"
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.access = get_all_accesses()
	W.registered_name = M.real_name
	M.equip_to_slot_or_del(W, SLOT_WEAR_ID)

/datum/outfit/fun/preparation
	name = "Preparation"

	uniform = /obj/item/clothing/under/color/black
	shoes = /obj/item/clothing/shoes/boots
	glasses = /obj/item/clothing/glasses/sunglasses
	l_ear = /obj/item/device/radio/headset
	back = /obj/item/weapon/storage/backpack/satchel/norm
	l_pocket = /obj/item/device/flashlight
	gloves = /obj/item/clothing/gloves/black

/datum/outfit/fun/preparation/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	var/obj/item/weapon/card/id/syndicate/W = new(M)
	W.assignment = "Unknown"
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.access = get_all_accesses()
	W.registered_name = M.real_name
	M.equip_to_slot_or_del(W, SLOT_WEAR_ID)

/datum/outfit/fun/death_commando
	name = "Death Commando"

/datum/outfit/fun/death_commando/pre_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	M.equip_death_commando()

/datum/outfit/fun/syndicate_commando
	name = "Syndicate Commando"

/datum/outfit/fun/syndicate_commando/pre_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	M.equip_syndicate_commando(FALSE)

/datum/outfit/fun/syndicate_commando_comander
	name = "Syndicate Commando Comander"

/datum/outfit/fun/syndicate_commando_comander/pre_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	M.equip_syndicate_commando(TRUE)

/datum/outfit/fun/nanotrasen_representative
	name = "Nanotrasen Representative"

	uniform = /obj/item/clothing/under/rank/centcom/representative
	shoes = /obj/item/clothing/shoes/centcom
	gloves = /obj/item/clothing/gloves/white
	l_ear = /obj/item/device/radio/headset/heads/hop
	l_pocket = /obj/item/clothing/glasses/sunglasses
	belt = /obj/item/weapon/clipboard

/datum/outfit/fun/nanotrasen_representative/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	var/obj/item/device/pda/heads/pda = new(M)
	pda.owner = M.real_name
	pda.ownjob = "NanoTrasen Navy Representative"
	pda.name = "PDA-[M.real_name] ([pda.ownjob])"
	M.equip_to_slot_or_del(pda, SLOT_R_STORE)

	var/obj/item/weapon/card/id/centcom/W = new(M)
	W.assignment = "NanoTrasen Navy Representative"
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.registered_name = M.real_name
	M.equip_to_slot_or_del(W, SLOT_WEAR_ID)

/datum/outfit/fun/nanotrasen_officer
	name = "Nanotrasen Officer"

	uniform = /obj/item/clothing/under/rank/centcom/officer
	shoes = /obj/item/clothing/shoes/centcom
	gloves = /obj/item/clothing/gloves/white
	l_ear = /obj/item/device/radio/headset/heads/captain
	head = /obj/item/clothing/head/beret/centcomofficer

/datum/outfit/fun/nanotrasen_officer/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	var/obj/item/device/pda/heads/pda = new(M)
	pda.owner = M.real_name
	pda.ownjob = "NanoTrasen Navy Officer"
	pda.name = "PDA-[M.real_name] ([pda.ownjob])"

	M.equip_to_slot_or_del(pda, SLOT_R_STORE)
	l_pocket = /obj/item/clothing/glasses/sunglasses
	belt = /obj/item/weapon/gun/energy

	var/obj/item/weapon/card/id/centcom/W = new(M)
	W.assignment = "NanoTrasen Navy Officer"
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.registered_name = M.real_name
	M.equip_to_slot_or_del(W, SLOT_WEAR_ID)


/datum/outfit/fun/nanotrasen_captain
	name = "Nanotrasen Captain"

	uniform = /obj/item/clothing/under/rank/centcom/captain
	shoes = /obj/item/clothing/shoes/centcom
	gloves = /obj/item/clothing/gloves/white
	l_ear = /obj/item/device/radio/headset/heads/captain
	head = /obj/item/clothing/head/beret/centcomcaptain
	l_pocket = /obj/item/clothing/glasses/sunglasses
	belt = /obj/item/weapon/gun/energy

/datum/outfit/fun/nanotrasen_captain/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	var/obj/item/device/pda/heads/pda = new(M)
	pda.owner = M.real_name
	pda.ownjob = "NanoTrasen Navy Captain"
	pda.name = "PDA-[M.real_name] ([pda.ownjob])"

	M.equip_to_slot_or_del(pda, SLOT_R_STORE)

	var/obj/item/weapon/card/id/centcom/W = new(M)
	W.assignment = "NanoTrasen Navy Captain"
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.registered_name = M.real_name
	M.equip_to_slot_or_del(W, SLOT_WEAR_ID)

/datum/outfit/fun/velocity_officer
	name = "Velocity Officer"

	uniform = /obj/item/clothing/under/det/fluff/retpoluniform
	shoes = /obj/item/clothing/shoes/boots/combat
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/device/radio/headset/velocity
	back = /obj/item/weapon/storage/backpack/satchel
	glasses = /obj/item/clothing/glasses/sunglasses/hud/sechud

/datum/outfit/fun/velocity_officer/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	var/obj/item/device/pda/velocity/pda = new(M)
	pda.owner = M.real_name
	pda.ownjob = "Velocity Officer"
	pda.name = "PDA-[M.real_name] ([pda.ownjob])"
	M.equip_to_slot_or_del(pda, SLOT_BELT)

	spawned_card = new/obj/item/weapon/card/id/velocity(M)
	spawned_card.assignment = "Velocity Officer"
	spawned_card.name = "[M.real_name]'s ID Card ([spawned_card.assignment])"
	spawned_card.rank = "Velocity Officer"
	spawned_card.registered_name = M.real_name
	M.equip_to_slot_or_del(spawned_card, SLOT_WEAR_ID)

	if(M.mind)
		M.mind.assigned_role = "Velocity Officer"

	M.universal_speak = TRUE
	M.universal_understand = TRUE

/datum/outfit/fun/velocity_chief
	name = "Velocity Chief"

	uniform = /obj/item/clothing/under/rank/head_of_security/corp
	shoes = /obj/item/clothing/shoes/boots/combat
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/device/radio/headset/velocity/chief
	head = /obj/item/clothing/head/beret/sec/hos
	suit = /obj/item/clothing/suit/storage/det_suit/fluff/retpolcoat
	glasses = /obj/item/clothing/glasses/sunglasses/hud/sechud
	back = /obj/item/weapon/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/weapon/storage/box/handcuffs,
		/obj/item/device/flash,
		/obj/item/weapon/storage/belt/security,
		/obj/item/device/megaphone,
		/obj/item/device/contraband_finder,
		/obj/item/device/reagent_scanner,
		/obj/item/weapon/stamp/cargo_industries,
	)
	implants = list(/obj/item/weapon/implant/mind_protect/mindshield)

/datum/outfit/fun/velocity_chief/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
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

	spawned_card = new/obj/item/weapon/card/id/velocity(M)
	spawned_card.assignment = "Velocity Chief"
	spawned_card.name = "[M.real_name]'s ID Card ([spawned_card.assignment])"
	spawned_card.access += get_all_accesses()
	spawned_card.rank = "Velocity Chief"
	spawned_card.registered_name = M.real_name
	M.equip_to_slot_or_del(spawned_card, SLOT_WEAR_ID)

	if(M.mind)
		M.mind.assigned_role = "Velocity Chief"

	M.universal_speak = TRUE
	M.universal_understand = TRUE

/datum/outfit/fun/velocity_doctor
	name = "Velocity Doctor"

	uniform = /obj/item/clothing/under/det/fluff/retpoluniform
	shoes = /obj/item/clothing/shoes/brown
	gloves = /obj/item/clothing/gloves/latex/nitrile
	suit = /obj/item/clothing/suit/storage/labcoat/blue
	l_ear = /obj/item/device/radio/headset/velocity
	back = /obj/item/weapon/storage/backpack/satchel/med
	glasses = /obj/item/clothing/glasses/hud/health
	l_pocket = /obj/item/weapon/reagent_containers/hypospray/cmo

/datum/outfit/fun/velocity_doctor/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	var/obj/item/device/pda/velocity/doctor/pda = new(M)
	pda.owner = M.real_name
	pda.ownjob = "Velocity Medical Doctor"
	pda.name = "PDA-[M.real_name] ([pda.ownjob])"
	M.equip_to_slot_or_del(pda, SLOT_BELT)

	spawned_card = new/obj/item/weapon/card/id/velocity(M)
	spawned_card.assignment = "Velocity Medical Doctor"
	spawned_card.name = "[M.real_name]'s ID Card ([spawned_card.assignment])"
	spawned_card.rank = "Velocity Medical Doctor"
	spawned_card.registered_name = M.real_name
	M.equip_to_slot_or_del(spawned_card, SLOT_WEAR_ID)

	if(M.mind)
		M.mind.assigned_role = "Velocity Medical Doctor"

	M.universal_speak = TRUE
	M.universal_understand = TRUE

/datum/outfit/fun/emergency_response_team
	name = "Emergency Response Team"

	uniform = /obj/item/clothing/under/rank/centcom_officer
	shoes = /obj/item/clothing/shoes/boots/swat
	gloves = /obj/item/clothing/gloves/swat
	l_ear = /obj/item/device/radio/headset/ert
	belt = /obj/item/weapon/gun/energy/gun
	glasses = /obj/item/clothing/glasses/sunglasses
	back = /obj/item/weapon/storage/backpack/satchel

/datum/outfit/fun/emergency_response_team/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	var/obj/item/weapon/card/id/centcom/ert/W = new(M)
	W.assignment = "Emergency Response Team"
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.registered_name = M.real_name
	M.equip_to_slot_or_del(W, SLOT_WEAR_ID)

/datum/outfit/fun/special_ops_officer
	name = "Special Ops Officer"

	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/armor/swat/officer
	shoes = /obj/item/clothing/shoes/boots/combat
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/device/radio/headset/heads/captain
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	head = /obj/item/clothing/head/helmet/space/deathsquad/beret
	belt = /obj/item/weapon/gun/energy/pulse_rifle/M1911
	r_pocket = /obj/item/weapon/lighter/zippo
	back = /obj/item/weapon/storage/backpack/satchel

/datum/outfit/fun/special_ops_officer/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	var/obj/item/weapon/card/id/centcom/W = new(M)
	W.assignment = "Special Operations Officer"
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.registered_name = M.real_name
	M.equip_to_slot_or_del(W, SLOT_WEAR_ID)

/datum/outfit/fun/blue_wizard
	name = "Blue Wizard"
	dresspacks_without_money = TRUE

	uniform = /obj/item/clothing/under/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	shoes = /obj/item/clothing/shoes/sandal
	l_ear = /obj/item/device/radio/headset
	head = /obj/item/clothing/head/wizard
	r_pocket = /obj/item/weapon/teleportation_scroll
	r_hand = /obj/item/weapon/spellbook
	l_hand = /obj/item/weapon/staff
	back = /obj/item/weapon/storage/backpack
	backpack_contents = /obj/item/weapon/storage/box

/datum/outfit/fun/red_wizard
	name = "Red Wizard"
	dresspacks_without_money = TRUE

	uniform = /obj/item/clothing/under/lightpurple
	suit = /obj/item/clothing/suit/wizrobe/red
	shoes = /obj/item/clothing/shoes/sandal
	l_ear = /obj/item/device/radio/headset
	head = /obj/item/clothing/head/wizard/red
	r_pocket = /obj/item/weapon/teleportation_scroll
	r_hand = /obj/item/weapon/spellbook
	l_hand = /obj/item/weapon/staff
	back = /obj/item/weapon/storage/backpack
	backpack_contents = /obj/item/weapon/storage/box

/datum/outfit/fun/marisa_wizard
	name = "Marisa Wizard"
	dresspacks_without_money = TRUE

	uniform = /obj/item/clothing/under/lightpurple
	suit = /obj/item/clothing/suit/wizrobe/marisa
	shoes = /obj/item/clothing/shoes/sandal/marisa
	l_ear = /obj/item/device/radio/headset
	head = /obj/item/clothing/head/wizard/marisa
	r_pocket = /obj/item/weapon/teleportation_scroll
	r_hand = /obj/item/weapon/spellbook
	l_hand = /obj/item/weapon/staff
	back = /obj/item/weapon/storage/backpack
	backpack_contents = /obj/item/weapon/storage/box

/datum/outfit/fun/soviet_admiral
	name = "Soviet Admiral"

	head = /obj/item/clothing/head/hgpiratecap
	shoes = /obj/item/clothing/shoes/boots/combat
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/device/radio/headset/heads/captain
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	suit = /obj/item/clothing/suit/hgpirate
	back = /obj/item/weapon/storage/backpack/satchel
	belt = /obj/item/weapon/gun/projectile/revolver/mateba
	uniform = /obj/item/clothing/under/soviet

/datum/outfit/fun/soviet_admiral/post_equip(mob/living/carbon/human/M, visualsOnly = FALSE)
	. = ..()
	var/obj/item/weapon/card/id/W = new(M)
	W.assignment = "Admiral"
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	W.registered_name = M.real_name
	M.equip_to_slot_or_del(W, SLOT_WEAR_ID)
