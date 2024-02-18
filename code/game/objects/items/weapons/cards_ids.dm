/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */

/obj/item/weapon/card // this item not use in game
	name = "card"
	desc = "Используется в карточных делах."
	icon = 'icons/obj/card.dmi'
	icon_state = "blank"
	item_state_world = "blank_world"
	w_class = SIZE_MINUSCULE
	var/associated_account_number = 0

	var/list/files = list(  )

/obj/item/weapon/card/ticket // tickets for ticket machine
	name = "ticket"
	desc = "Билет"
	icon = 'icons/obj/card.dmi'
	icon_state = "ticket"
	item_state_world = "ticket_world"

	maptext_x = 1
	maptext_y = 3

	var/number = 0

/obj/item/weapon/card/ticket/update_world_icon()
	. = ..()
	if(icon_state == initial(icon_state))
		maptext = {"<div style="font-size:3;color:#595757;font-family:'StatusDisplays';text-align:center;" valign="middle">[number]</div>"}
	else
		maptext = ""

/obj/item/weapon/card/ticket/atom_init(mapload, newnumber)
	. = ..()

	number = newnumber

	maptext = {"<div style="font-size:3;color:#595757;font-family:'StatusDisplays';text-align:center;" valign="middle">[number]</div>"}
	desc += " №[number]."

/obj/item/weapon/card/emag_broken
	desc = "Это карта с магнитной полосой, прикрепленной к какой-то микросхеме. Выглядит слишком разбитой, чтобы её можно было использовать для чего-либо, кроме утилизации."
	name = "broken cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	item_state_world = "emag_world"
	origin_tech = "magnets=2;syndicate=2"

/obj/item/weapon/card/emag
	desc = "Это карта с магнитной полосой, прикрепленной к какой-то микросхеме."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	item_state_world = "emag_world"
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
		emag_break(user)
		return

	..()

/obj/item/weapon/card/emag/proc/emag_break(mob/user)
	var/obj/item/weapon/card/emag_broken/junk = new(user.loc)
	junk.add_fingerprint(user)
	user.visible_message("[src] fizzles and sparks - it seems it's been used once too often, and is now broken.")
	qdel(src)

/obj/item/weapon/card/emag/clown
	uses = 50

/*
 * DATA CARDS - Used for the teleporter
 */

/obj/item/weapon/card/data
	name = "data disk"
	desc = "Дискета для данных."
	icon_state = "data"
	item_state_world = "data_world"
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
	add_fingerprint(usr)
	return

/obj/item/weapon/card/data/clown
	name = "the coordinates to clown planet"
	icon_state = "data"
	item_state = "card-id"
	item_state_world = "data_world"
	layer = 3
	desc = "Эта дискета содержит координаты легендарной планеты Клоунов. Обращайтесь с ней осторожно."
	function = "teleporter"
	data = "Clown Land"

/*
 * ID CARDS
 */

/obj/item/weapon/card/id
	name = "identification card"
	desc = "ID карта, используемая для определения личности, должности и станционного доступа."
	icon_state = "id"
	item_state = "card-id"
	item_state_world = "id_world"
	var/mining_points = 0 //For redeeming at mining equipment lockers
	var/access = list()
	var/registered_name = "Unknown" // The name registered_name on the card
	slot_flags = SLOT_FLAGS_ID
	var/customizable_view = UNIVERSAL_VIEW
	var/blood_type = "\[UNSET\]"
	var/dna_hash = "\[UNSET\]"
	var/fingerprint_hash = "\[UNSET\]"
	var/list/disabilities = list()

	//alt titles are handled a bit weirdly in order to unobtrusively integrate into existing ID system
	var/assignment = null	//can be alt title or the actual job
	var/rank = null			//actual job
	var/dorm = 0		// determines if this ID has claimed a dorm already

/obj/item/weapon/card/id/atom_init()
	. = ..()

	if(!ishuman(loc))
		return

	var/mob/living/carbon/human/H = loc
	blood_type = H.dna.b_type
	dna_hash = H.dna.unique_enzymes
	fingerprint_hash = md5(H.dna.uni_identity)

/obj/item/weapon/card/id/attack_self(mob/user)
	visible_message("[user] shows you: [bicon(src)] [src.name]: assignment: [src.assignment]")
	add_fingerprint(user)
	return

/obj/item/weapon/card/id/examine(mob/user)
	..()
	if(mining_points)
		to_chat(user, "There's [mining_points] mining equipment redemption points loaded onto this card.")
	if(disabilities.len)
		to_chat(user, GetDisabilities())

/obj/item/weapon/card/id/GetAccess()
	return access

/obj/item/weapon/card/id/GetID()
	return src

/obj/item/weapon/card/id/proc/GetDisabilities()
	if(disabilities.len)
		var/msg = "Has disability indicators on the card: <span class='warning bold'><B>"
		for(var/I in 1 to disabilities.len - 1)
			msg += "[disabilities[I]], "
		msg += "[disabilities[disabilities.len]].</B></span>"
		return msg

/obj/item/weapon/card/id/verb/read()
	set name = "Read ID Card"
	set category = "Object"
	set src in usr

	to_chat(usr, "[bicon(src)] [src.name]: The current assignment on the card is [src.assignment].")
	to_chat(usr, "The blood type on the card is [blood_type].")
	to_chat(usr, "The DNA hash on the card is [dna_hash].")
	to_chat(usr, "The fingerprint hash on the card is [fingerprint_hash].")
	if(disabilities.len)
		to_chat(usr, GetDisabilities())
	return

/obj/item/weapon/card/id/proc/assign(real_name)
	if(!istext(real_name))
		stack_trace("Expected text, got reference")
		real_name = "[real_name]"

	name = "[real_name]'s ID Card[assignment ? " ([assignment])" : ""]"
	registered_name = real_name


/obj/item/weapon/card/id/silver
	name = "identification card"
	desc = "Серебряная ID карта, свидетельствующая о чести и преданности владельца."
	icon_state = "silver"
	item_state = "silver_id"
	item_state_world = "silver_world"

/obj/item/weapon/card/id/gold
	name = "identification card"
	desc = "Золотая ID карта, которая показывает силу и могущество владельца."
	icon_state = "gold"
	item_state = "gold_id"
	item_state_world = "gold_world"

/obj/item/weapon/card/id/civ
	name = "identification card"
	desc = "ID карта, выдаваемая сотрудникам обслуживающего персонала."
	icon_state = "civ"
	item_state = "civ_id"
	item_state_world = "civ_world"

/obj/item/weapon/card/id/civGold //This is not the HoP. There's no position that uses this right now.
	name = "identification card"
	desc = "ID карта начальника, олицетворяющая здравый смысл и ответственность владельца."
	icon_state = "civGold"
	item_state = "civGold_id"
	item_state_world = "civGold_world"

/obj/item/weapon/card/id/sec
	name = "identification card"
	desc = "ID карта, принадлежащая сотруднику службы безопасности."
	icon_state = "sec"
	item_state = "sec_id"
	item_state_world = "sec_world"

/obj/item/weapon/card/id/int
	name = "identification card"
	desc = "ID карта, принадлежащая агенту внутренних дел."
	icon_state = "int"
	item_state = "int_id"
	item_state_world = "int_world"

/obj/item/weapon/card/id/blueshield
	name = "identification card"
	desc = "ID карта офицера, которая олицетворяет личный щит командования станции и представителей Центрального Командования."
	icon_state = "blueshield"
	item_state = "int_id"
	item_state_world = "blueshield_world"

/obj/item/weapon/card/id/secGold
	name = "identification card"
	desc = "ID карта начальника, которая олицетворяет доблесть владельца и его покровительство над беззащитными."
	icon_state = "secGold"
	item_state = "secGold_id"
	item_state_world = "secGold_world"

/obj/item/weapon/card/id/eng
	name = "identification card"
	desc = "ID карта, принадлежащая сотруднику инженерного отдела."
	icon_state = "eng"
	item_state = "eng_id"
	item_state_world = "eng_world"

/obj/item/weapon/card/id/engGold
	name = "identification card"
	desc = "ID карта начальника, олицетворяющая креативность и изобретательность владельца."
	icon_state = "engGold"
	item_state = "engGold_id"
	item_state_world = "engGold_world"

/obj/item/weapon/card/id/med
	name = "identification card"
	desc = "ID карта, принадлежащая сотруднику медицинского отдела."
	icon_state = "med"
	item_state = "med_id"
	item_state_world = "med_world"

/obj/item/weapon/card/id/medGold
	name = "identification card"
	desc = "ID карта начальника, олицетворяющая заботу и сострадание к раненым и больным."
	icon_state = "medGold"
	item_state = "medGold_id"
	item_state_world = "medGold_world"

/obj/item/weapon/card/id/sci
	name = "identification card"
	desc = "ID карта, принадлежащая сотруднику научного отдела."
	icon_state = "sci"
	item_state = "sci_id"
	item_state_world = "sci_world"

/obj/item/weapon/card/id/sciGold
	name = "identification card"
	desc = "ID карта начальника, представляющая мудрость и рассудительность владельца."
	icon_state = "sciGold"
	item_state = "sciGold_id"
	item_state_world = "sciGold_world"

/obj/item/weapon/card/id/clown
	name = "identification card"
	desc = "Радужная ID карта, которая олицетворяет смех и несгибаемость владельца."
	icon_state = "clown"
	item_state = "clown_id"
	item_state_world = "clown_world"

/obj/item/weapon/card/id/clownGold //not in use
	name = "identification card"
	desc = "Радужная ID карта начальника, которая символизирует смех и несгибаемость владельца."
	icon_state = "clownGold"
	item_state = "clownGold_id"
	item_state_world = "clownGold_world"

/obj/item/weapon/card/id/mime
	name = "identification card"
	desc = "Чёрно-белая ID карта, которая символизирует слезы и молчаливость владельца."
	icon_state = "mime"
	item_state = "mime_id"
	item_state_world = "mime_world"

/obj/item/weapon/card/id/mimeGold //not in use
	name = "identification card"
	desc = "Чёрно-белая ID карта начальника, символизирующая слезы и молчаливость владельца."
	icon_state = "mimeGold"
	item_state = "mimeGold_id"
	item_state_world = "mimeGold_world"

/obj/item/weapon/card/id/cargo
	name = "identification card"
	desc = "ID карта, принадлежащая сотруднику отдела снабжения."
	icon_state = "cargo"
	item_state = "cargo_id"
	item_state_world = "cargo_world"

/obj/item/weapon/card/id/cargoGold
	name = "identification card"
	desc = "ID карта начальника, олицетворяющая умения владельца обеспечивать и планировать."
	icon_state = "cargoGold"
	item_state = "cargoGold_id"
	item_state_world = "cargoGold_world"

/obj/item/weapon/card/id/syndicate
	name = "Agent card"
	access = list(access_maint_tunnels, access_syndicate, access_external_airlocks)
	origin_tech = "syndicate=3"
	assignment = "Agent"
	var/registered_user=null
	var/obj/item/weapon/card/id/scard = null
	customizable_view = TRAITOR_VIEW
	var/list/radial_chooses

/obj/item/weapon/card/id/syndicate/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(istype(target, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = target
		src.access |= I.access
		if(isliving(user) && user.mind)
			if(user.mind.special_role)
				to_chat(usr, "<span class='notice'>The card's microscanners activate as you pass it over the ID, copying its access.</span>")

/obj/item/weapon/card/id/syndicate/attack_self(mob/user)
	if(!src.registered_name)
		//Stop giving the players unsanitized unputs! You are giving ways for players to intentionally crash clients! -Nodrak
		var/t = sanitize_name(input(user, "What name would you like to put on this card?", "Agent card name", input_default(ishuman(user) ? user.real_name : user.name)))
		if(!t) //Same as mob/dead/new_player/prefrences.dm
			tgui_alert(usr, "Invalid name.")
			return

		var/u = sanitize_safe(input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Agent"))
		if(!u)
			tgui_alert(usr, "Invalid assignment.")
			src.registered_name = ""
			return
		src.assignment = u
		assign(registered_name)
		to_chat(user, "<span class='notice'>You successfully forge the ID card.</span>")
		registered_user = user
	else if(!registered_user || registered_user == user)

		if(!registered_user) registered_user = user  //

		switch(tgui_alert(usr, "Would you like to display the ID, change its look, or retitle it?","Choose.", list("Rename", "Change look","Show")))
			if("Rename")
				var/t = sanitize_name(input(user, "What name would you like to put on this card?", "Agent card name", input_default(ishuman(user) ? user.real_name : user.name)))
				if(!t) //Same as mob/dead/new_player/prefrences.dm
					tgui_alert(usr, "Invalid name.")
					return

				var/u = sanitize_safe(input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Assistant"))
				if(!u)
					tgui_alert(usr, "Invalid assignment.")
					return
				src.assignment = u
				assign(t)
				to_chat(user, "<span class='notice'>You successfully forge the ID card.</span>")
				return
			if("Change look")
				if(!radial_chooses)
					radial_chooses = list()
					for(var/P in typesof(/obj/item/weapon/card/id))
						var/obj/item/weapon/card/id/C = new P
						if(C.customizable_view != FORDBIDDEN_VIEW) //everything except forbidden
							radial_chooses[C] = image(icon = C.icon, icon_state = initial(C.icon_state))

				var/obj/item/weapon/card/id/newc = show_radial_menu(user, src, radial_chooses, require_near = TRUE)
				if (newc)
					src.icon = 'icons/obj/card.dmi'
					src.item_state_inventory = initial(newc.icon_state)
					src.item_state_world = newc.item_state_world
					src.desc = newc.desc
				update_world_icon()
				to_chat(user, "<span class='notice'>You successfully change the look of the ID card!</span>")
				return

			if("Show")
				..()
	else
		..()

/obj/item/weapon/card/id/syndicate/equipped(mob/living/user, slot)
	. = ..()
	if(slot == SLOT_WEAR_ID)
		RegisterSignal(user, COMSIG_LIVING_CAN_TRACK, PROC_REF(can_track))
	else
		UnregisterSignal(user, COMSIG_LIVING_CAN_TRACK)

/obj/item/weapon/card/id/syndicate/dropped(mob/living/user)
	. = ..()
	UnregisterSignal(user, COMSIG_LIVING_CAN_TRACK)

/obj/item/weapon/card/id/syndicate/proc/can_track(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_CANT_TRACK

/obj/item/weapon/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "ID карта прямиком от Синдиката."
	registered_name = "Syndicate"
	assignment = "Syndicate Overlord"
	access = list(access_syndicate, access_external_airlocks)
	customizable_view = TRAITOR_VIEW

/obj/item/weapon/card/id/syndicate/commander
	name = "syndicate commander ID card"
	assignment = "Syndicate Commander"
	icon_state = "syndicate-command"
	item_state_world = "syndicate-command_world"
	access = list(access_maint_tunnels, access_syndicate, access_syndicate_commander, access_external_airlocks)


/obj/item/weapon/card/id/syndicate/nuker
	icon_state = "syndicate"
	item_state_world = "syndicate_world"

/obj/item/weapon/card/id/captains_spare
	name = "captain's spare ID"
	desc = "Запасная ID карта самого Верховного Властелина."
	icon_state = "gold"
	item_state = "gold_id"
	item_state_world = "gold_world"
	registered_name = "Captain"
	assignment = "Captain"

/obj/item/weapon/card/id/captains_spare/atom_init()
	. = ..()
	var/datum/job/captain/J = SSjob.GetJob("Captain")
	access = J.get_access()

/obj/item/weapon/card/id/centcom
	name = "CentCom. ID"
	desc = "ID карта прямиком с Центрального Командования."
	icon_state = "centcom"
	item_state_world = "centcom_world"
	registered_name = "Central Command"
	assignment = "General"
	rank = "NanoTrasen Representative"
	customizable_view = TRAITOR_VIEW

/obj/item/weapon/card/id/centcom/atom_init()
	. = ..()
	access = get_all_accesses() + get_all_centcom_access()

/obj/item/weapon/card/id/centcom/representative
	assignment = "NanoTrasen Navy Representative"

/obj/item/weapon/card/id/centcom/officer
	assignment = "NanoTrasen Navy Officer"

/obj/item/weapon/card/id/centcom/captain
	assignment = "NanoTrasen Navy Captain"

/obj/item/weapon/card/id/centcom/special_ops
	assignment = "Special Operations Officer"

/obj/item/weapon/card/id/centcom/ert
	icon_state = "ert"
	item_state_world = "ert_world"
	assignment = "Emergency Response Team"
	rank = "Emergency Response Team"

/obj/item/weapon/card/id/centcom/ert/leader
	icon_state = "ert-leader"
	item_state_world = "ert-leader_world"
	assignment = "Emergency Response Team Leader"
	rank = "Emergency Response Team Leader"

/obj/item/weapon/card/id/velocity
	name = "Cargo Industries. ID"
	desc = "ID карта сотрудников Велосити."
	icon_state = "velocity"
	item_state = "velcard_id"
	item_state_world = "velocity_world"
	registered_name = "Cargo Industries"
	assignment = "General"

/obj/item/weapon/card/id/velocity/atom_init()
	. = ..()
	access = get_all_centcom_access()

/obj/item/weapon/card/id/velocity/officer
	assignment = "Velocity Officer"
	rank = "Velocity Officer"

/obj/item/weapon/card/id/velocity/chief
	assignment = "Velocity Chief"
	rank = "Velocity Chief"

/obj/item/weapon/card/id/velocity/doctor
	assignment = "Velocity Medical Doctor"
	rank = "Velocity Medical Doctor"

/obj/item/weapon/card/id/space_police
	assignment = "Organized Crimes Department"
	rank = "Organized Crimes Department"

	icon_state = "ert"
	item_state_world = "ert_world"

/obj/item/weapon/card/id/space_police/atom_init()
	. = ..()
	access = get_all_accesses()

/obj/item/weapon/card/id/admiral
	assignment = "Admiral"
	rank = "Admiral"

/obj/item/weapon/card/id/admiral/atom_init()
	. = ..()
	access = get_all_accesses() + get_all_centcom_access()

/obj/item/weapon/card/id/clown/tunnel
	assignment = "Tunnel Clown!"
	rank = "Tunnel Clown!"

/obj/item/weapon/card/id/clown/tunnel/atom_init()
	. = ..()
	access = get_all_accesses()

/obj/item/weapon/card/id/syndicate/reaper
	assignment = "Reaper"
	rank = "Reaper"

/obj/item/weapon/card/id/syndicate/reaper/atom_init()
	. = ..()
	access = get_all_accesses()

/obj/item/weapon/card/id/syndicate/strike
	icon_state = "syndicate"
	assignment = "Syndicate Commando"

/obj/item/weapon/card/id/syndicate/strike/leader
	icon_state = "syndicate-command"
	assignment = "Syndicate Commando Leader"

/obj/item/weapon/card/id/syndicate/unknown
	assignment = "Unknown"

/obj/item/weapon/card/id/syndicate/unknown/atom_init()
	. = ..()
	access = get_all_accesses()

/obj/item/weapon/card/id/old_station
	name = "captain's ID"
	desc = "Старая ID карта, ранее она принадлежала капитану станции 'LCR'."
	icon_state = "gold"
	item_state = "gold_id"
	item_state_world = "gold_world"
	access = list(access_oldstation, access_RC_announce, access_keycard_auth, access_engine_equip, access_medical, access_surgery, access_captain, access_engine, access_research, access_tox, access_robotics, access_heads)

/obj/item/weapon/card/id/old_station/eng
	name = "engineer ID"
	desc = "ID карта, принадлежащая старшему сотруднику инженерного отдела станции 'LCR'."
	icon_state = "eng"
	item_state = "eng_id"
	item_state_world = "eng_world"
	rank = "Senior Engineer"
	assignment = "Senior Engineer"
	access = list(access_oldstation, access_engine, access_engine_equip, access_medical, access_research, access_tox, access_robotics)

/obj/item/weapon/card/id/old_station/med
	name = "medic ID"
	desc = "ID карта, принадлежащая старшему сотруднику медицинского отдела станции 'LCR'."
	icon_state = "med"
	item_state = "med_id"
	item_state_world = "med_world"
	rank = "Senior Medic"
	assignment = "Senior Medic"
	access = list(access_oldstation, access_engine, access_engine_equip, access_medical, access_surgery, access_research, access_tox, access_robotics)
