/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */

/*
 * DATA CARDS - Used for the teleporter
 */
/obj/item/weapon/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/card.dmi'
	w_class = ITEM_SIZE_TINY
	var/associated_account_number = 0

	var/list/files = list(  )

/obj/item/weapon/card/data
	name = "data disk"
	desc = "A disk of data."
	icon_state = "data"
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"

/obj/item/weapon/card/data/verb/label(t as text)
	set name = "Label Disk"
	set category = "Object"
	set src in usr

	if (t)
		src.name = text("data disk- '[]'", t)
	else
		src.name = "data disk"
	src.add_fingerprint(usr)
	return

/obj/item/weapon/card/data/clown
	name = "the coordinates to clown planet"
	icon_state = "data"
	item_state = "card-id"
	layer = 3
	level = 2
	desc = "This card contains coordinates to the fabled Clown Planet. Handle with care."
	function = "teleporter"
	data = "Clown Land"

/*
 * ID CARDS
 */

/obj/item/weapon/card/emag_broken
	desc = "It's a card with a magnetic strip attached to some circuitry. It looks too busted to be used for anything but salvage."
	name = "broken cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"

/obj/item/weapon/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"
	var/uses = 10

/obj/item/weapon/card/emag/attack(mob/living/M, mob/living/user, def_zone)
	if(!..())
		return TRUE

/obj/item/weapon/card/emag/afterattack(atom/target, mob/user, proximity, params)
	if(proximity && target.emag_act(user))
		user.SetNextMove(CLICK_CD_INTERACT)
		uses--

	if(uses < 1)
		user.visible_message("[src] fizzles and sparks - it seems it's been used once too often, and is now broken.")
		user.drop_item()
		var/obj/item/weapon/card/emag_broken/junk = new(user.loc)
		junk.add_fingerprint(user)
		qdel(src)
		return

	..()

/obj/item/weapon/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "id"
	item_state = "card-id"
	var/mining_points = 0 //For redeeming at mining equipment lockers
	var/access = list()
	var/registered_name = "Unknown" // The name registered_name on the card
	slot_flags = SLOT_FLAGS_ID
	var/customizable_view = UNIVERSAL_VIEW
	var/blood_type = "\[UNSET\]"
	var/dna_hash = "\[UNSET\]"
	var/fingerprint_hash = "\[UNSET\]"

	//alt titles are handled a bit weirdly in order to unobtrusively integrate into existing ID system
	var/assignment = null	//can be alt title or the actual job
	var/rank = null			//actual job
	var/dorm = 0		// determines if this ID has claimed a dorm already

/obj/item/weapon/card/id/atom_init()
	. = ..()

	if(ishuman(loc)) // this should be ok without any spawn as long, as item spawned inside mob by equip procs.
		var/mob/living/carbon/human/H = loc
		blood_type = H.dna.b_type
		dna_hash = H.dna.unique_enzymes
		fingerprint_hash = md5(H.dna.uni_identity)

/obj/item/weapon/card/id/attack_self(mob/user)
	visible_message("[user] shows you: [bicon(src)] [src.name]: assignment: [src.assignment]")
	src.add_fingerprint(user)
	return

/obj/item/weapon/card/id/examine(mob/user)
	..()
	if(mining_points)
		to_chat(user, "There's [mining_points] mining equipment redemption points loaded onto this card.")

/obj/item/weapon/card/id/GetAccess()
	return access

/obj/item/weapon/card/id/GetID()
	return src

/obj/item/weapon/card/id/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/id_wallet))
		to_chat(user, "You slip [src] into [I].")
		src.name = "[src.registered_name]'s [I.name] ([src.assignment])"
		src.desc = I.desc
		src.icon = I.icon
		src.icon_state = I.icon_state
		qdel(I)

	else
		return ..()

/obj/item/weapon/card/id/verb/read()
	set name = "Read ID Card"
	set category = "Object"
	set src in usr

	to_chat(usr, "[bicon(src)] [src.name]: The current assignment on the card is [src.assignment].")
	to_chat(usr, "The blood type on the card is [blood_type].")
	to_chat(usr, "The DNA hash on the card is [dna_hash].")
	to_chat(usr, "The fingerprint hash on the card is [fingerprint_hash].")
	return


/obj/item/weapon/card/id/silver
	name = "identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	item_state = "silver_id"

/obj/item/weapon/card/id/gold
	name = "identification card"
	desc = "A golden card which shows power and might."
	icon_state = "gold"
	item_state = "gold_id"

/obj/item/weapon/card/id/civ
	name = "identification card"
	desc = "A card issued to civilian staff."
	icon_state = "civ"
	item_state = "civ_id"

/obj/item/weapon/card/id/civGold //This is not the HoP. There's no position that uses this right now.
	name = "identification card"
	desc = "A card which represents common sense and responsibility."
	icon_state = "civGold"
	item_state = "civGold_id"

/obj/item/weapon/card/id/sec
	name = "identification card"
	desc = "A card issued to security staff."
	icon_state = "sec"
	item_state = "sec_id"

/obj/item/weapon/card/id/int
	name = "identification card"
	desc = "A card issued to internal affairs agent."
	icon_state = "int"
	item_state = "int_id"

/obj/item/weapon/card/id/secGold
	name = "identification card"
	desc = "A card which represents honor and protection."
	icon_state = "secGold"
	item_state = "secGold_id"

/obj/item/weapon/card/id/eng
	name = "identification card"
	desc = "A card issued to engineering staff."
	icon_state = "eng"
	item_state = "eng_id"

/obj/item/weapon/card/id/engGold
	name = "identification card"
	desc = "A card which represents creativity and ingenuity."
	icon_state = "engGold"
	item_state = "engGold_id"

/obj/item/weapon/card/id/med
	name = "identification card"
	desc = "A card issued to medical staff."
	icon_state = "med"
	item_state = "med_id"

/obj/item/weapon/card/id/medGold
	name = "identification card"
	desc = "A card which represents care and compassion."
	icon_state = "medGold"
	item_state = "medGold_id"

/obj/item/weapon/card/id/sci
	name = "identification card"
	desc = "A card issued to science staff."
	icon_state = "sci"
	item_state = "sci_id"

/obj/item/weapon/card/id/sciGold
	name = "identification card"
	desc = "A card which represents knowledge and reasoning."
	icon_state = "sciGold"
	item_state = "sciGold_id"

/obj/item/weapon/card/id/clown
	name = "identification card"
	desc = "A card which represents laugh and robust."
	icon_state = "clown"
	item_state = "clown_id"

/obj/item/weapon/card/id/clownGold //not in use
	name = "identification card"
	desc = "A golden card which represents laugh and robust."
	icon_state = "clownGold"
	item_state = "clownGold_id"

/obj/item/weapon/card/id/mime
	name = "identification card"
	desc = "A card which represents tears and silence."
	icon_state = "mime"
	item_state = "mime_id"

/obj/item/weapon/card/id/mimeGold //not in use
	name = "identification card"
	desc = "A golden card which represents tears and silence."
	icon_state = "mimeGold"
	item_state = "mimeGold_id"

/obj/item/weapon/card/id/cargo
	name = "identification card"
	desc = "A card issued to cargo staff."
	icon_state = "cargo"
	item_state = "cargo_id"

/obj/item/weapon/card/id/cargoGold
	name = "identification card"
	desc = "A card which represents service and planning."
	icon_state = "cargoGold"
	item_state = "cargoGold_id"

/obj/item/weapon/card/id/syndicate
	name = "agent card"
	access = list(access_maint_tunnels, access_syndicate, access_external_airlocks)
	origin_tech = "syndicate=3"
	var/registered_user=null
	var/list/colorlist = list()
	var/obj/item/weapon/card/id/scard = null
	customizable_view = TRAITOR_VIEW



/obj/item/weapon/card/id/syndicate/atom_init()
	. = ..()
	if(ismob(loc)) // Runtime prevention on laggy starts or where users log out because of lag at round start.
		var/mob/user = loc
		registered_name = ishuman(user) ? user.real_name : user.name
	else
		registered_name = "Agent Card"
	assignment = "Agent"
	name = "[registered_name]'s ID Card ([assignment])"

/obj/item/weapon/card/id/syndicate/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(istype(target, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = target
		src.access |= I.access
		if(istype(user, /mob/living) && user.mind)
			if(user.mind.special_role)
				to_chat(usr, "<span class='notice'>The card's microscanners activate as you pass it over the ID, copying its access.</span>")

/obj/item/weapon/card/id/syndicate/attack_self(mob/user)
	if(!src.registered_name)
		//Stop giving the players unsanitized unputs! You are giving ways for players to intentionally crash clients! -Nodrak
		var/t = sanitize_name(input(user, "What name would you like to put on this card?", "Agent card name", input_default(ishuman(user) ? user.real_name : user.name)))
		if(!t) //Same as mob/dead/new_player/prefrences.dm
			alert("Invalid name.")
			return
		src.registered_name = t

		var/u = sanitize_safe(input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Agent"))
		if(!u)
			alert("Invalid assignment.")
			src.registered_name = ""
			return
		src.assignment = u
		src.name = "[src.registered_name]'s ID Card ([src.assignment])"
		to_chat(user, "<span class='notice'>You successfully forge the ID card.</span>")
		registered_user = user
	else if(!registered_user || registered_user == user)

		if(!registered_user) registered_user = user  //

		switch(alert("Would you like to display the ID, change its look, or retitle it?","Choose.","Rename", "Change look","Show"))
			if("Rename")
				var/t = sanitize_name(input(user, "What name would you like to put on this card?", "Agent card name", input_default(ishuman(user) ? user.real_name : user.name)))
				if(!t) //Same as mob/dead/new_player/prefrences.dm
					alert("Invalid name.")
					return
				src.registered_name = t

				var/u = sanitize_safe(input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Test Subject"))
				if(!u)
					alert("Invalid assignment.")
					return
				src.assignment = u
				src.name = "[src.registered_name]'s ID Card ([src.assignment])"
				to_chat(user, "<span class='notice'>You successfully forge the ID card.</span>")
				return
			if("Change look")
				for(var/P in typesof(/obj/item/weapon/card/id))
					var/obj/item/weapon/card/id/C = new P
					if (C.customizable_view != FORDBIDDEN_VIEW) //everything except forbidden
						C.name = C.icon_state
						colorlist += C

				var/obj/item/weapon/card/id/newc
				newc = input(user, "Select your type!", "Card Changing") as null|anything in colorlist
				if (newc)
					src.icon = 'icons/obj/card.dmi'
					src.icon_state = newc.icon_state
					src.desc = newc.desc
				src.update_icon()
				to_chat(user, "<span class='notice'>You successfully change the look of the ID card!</span>")
				return

			if("Show")
				..()
	else
		..()



/obj/item/weapon/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	assignment = "Syndicate Overlord"
	access = list(access_syndicate, access_external_airlocks)
	customizable_view = TRAITOR_VIEW

/obj/item/weapon/card/id/syndicate/commander
	name = "syndicate commander ID card"
	assignment = "Syndicate Commander"
	icon_state = "syndicate-command"
	access = list(access_maint_tunnels, access_syndicate, access_syndicate_commander, access_external_airlocks)


/obj/item/weapon/card/id/syndicate/nuker
	icon_state = "syndicate"

/obj/item/weapon/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	icon_state = "gold"
	item_state = "gold_id"
	registered_name = "Captain"
	assignment = "Captain"

/obj/item/weapon/card/id/captains_spare/atom_init()
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	. = ..()

/obj/item/weapon/card/id/centcom
	name = "CentCom. ID"
	desc = "An ID straight from Cent. Com."
	icon_state = "centcom"
	registered_name = "Central Command"
	assignment = "General"
	customizable_view = TRAITOR_VIEW

/obj/item/weapon/card/id/centcom/atom_init()
	access = get_all_centcom_access()
	. = ..()

/obj/item/weapon/card/id/velocity
	name = "Cargo Industries. ID"
	desc = "An ID designed for Velocity crew workers."
	icon_state = "velocity"
	item_state = "velcard_id"
	registered_name = "Cargo Industries"
	assignment = "General"

/obj/item/weapon/card/id/velocity/atom_init()
	access = get_all_centcom_access()
	. = ..()

/obj/item/weapon/card/id/ert
	name = "CentCom. ID"
	icon_state = "ert"
	registered_name = "Central Command"
	assignment = "Emergency Response Team"
	customizable_view = TRAITOR_VIEW

/obj/item/weapon/card/id/ert/atom_init()
	access = get_all_accesses()
	access += get_all_centcom_access()
	. = ..()
