/datum/role/space_trader
	name = SPACE_TRADER
	id = SPACE_TRADER

	disallow_job = TRUE
	logo_state = "space_traders"
	var/datum/outfit/outfit
	var/money

/datum/role/space_trader/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/H = antag.current

	H.equipOutfit(outfit)

	var/datum/money_account/MA = create_random_account_and_store_in_mind(H, money)

	var/obj/item/weapon/card/id/C = new(H)
	C.rank = "Space Trader"
	C.assign(H.real_name)
	C.access = list(access_space_traders)
	C.associated_account_number = MA.account_number
	H.equip_or_collect(C, SLOT_WEAR_ID)

	var/obj/item/device/pda/pda = new(H)
	pda.assign(H.real_name)
	pda.ownrank = C.rank
	pda.owner_account = MA.account_number
	pda.owner_fingerprints += C.fingerprint_hash
	MA.owner_PDA = pda
	H.equip_or_collect(pda, SLOT_R_STORE)

	var/datum/faction/space_traders/F = create_uniq_faction(/datum/faction/space_traders)
	add_faction_member(F, H, TRUE)

/datum/role/space_trader/dealer
	skillset_type = /datum/skillset/quartermaster
	outfit = /datum/outfit/space_trader/dealer
	money = 500

/datum/role/space_trader/dealer/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Вы - барыга.

------------------</b></span>"})


/datum/role/space_trader/guard
	skillset_type = /datum/skillset/officer
	outfit = /datum/outfit/space_trader/guard
	money = 200

/datum/role/space_trader/guard/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Вы - ЧОПовец.

------------------</b></span>"})


/datum/role/space_trader/porter
	skillset_type = /datum/skillset/cargotech
	outfit = /datum/outfit/space_trader/porter
	money = 20

/datum/role/space_trader/porter/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Вы - грузчик.

------------------</b></span>"})
