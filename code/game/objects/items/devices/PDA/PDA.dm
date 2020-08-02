#define TRANSCATION_COOLDOWN 30	//delay between transactions
#define ALLOWED_ID_OVERLAYS list("id", "gold", "silver", "centcom", "ert", "ert-leader", "syndicate", "syndicate-command", "clown", "mime") // List of overlays in pda.dmi
//The advanced pea-green monochrome lcd of tomorrow.

/obj/item/device/pda
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_FLAGS_ID | SLOT_FLAGS_BELT

	//Main variables
	var/owner = null
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/weapon/cartridge/cartridge = null //current cartridge
	var/mode = 0 //Controls what menu the PDA will display. 0 is hub; the rest are either built in or based on cartridge.

	var/lastmode = 0
	var/ui_tick = 0
	var/nanoUI[0]

	//Secondary variables
	var/scanmode = 0 //1 is medical scanner, 2 is forensics, 3 is reagent scanner.
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 2 //Luminosity for the flashlight function
	var/message_silent = 0 //To beep or not to beep, that is the question
	var/toff = 0 //If 1, messenger disabled
	var/tnote[0]  //Current Texts
	var/last_text //No text spamming
	var/last_honk //Also no honk spamming that's bad too
	var/last_tap_sound = 0 // prevents tap sounds spam
	var/ttone = "beep" //The PDA ringtone!
	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/note = "Congratulations, your station has chosen the Thinktronic 5230 Personal Data Assistant!" //Current note in the notepad function
	var/notehtml = ""
	var/cart = "" //A place to stick cartridge menu information
	var/detonate = 1 // Can the PDA be blown up?
	var/hidden = 0 // Is the PDA hidden from the PDA list?
	var/active_conversation = null // New variable that allows us to only view a single conversation.
	var/list/conversations = list()    // For keeping up with who we have PDA messsages from.
	var/newmessage = 0			//To remove hackish overlay check

	var/list/cartmodes = list(40, 42, 43, 433, 44, 441, 45, 451, 46, 48, 47, 49) // If you add more cartridge modes add them to this list as well.
	var/list/no_auto_update = list(1, 40, 43, 44, 441, 45, 451, 72, 73)		     // These modes we turn off autoupdate
	var/list/update_every_five = list(3, 41, 433, 46, 47, 48, 49)			     // These we update every 5 ticks

	var/obj/item/weapon/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above
	var/ownrank = null // this one is rank, never alt title

	//Variables for Finance Management
	var/datum/money_account/owner_account = null
	var/target_account_number = 0
	var/funds_amount = 0
	var/transfer_purpose = "Funds transfer"
	var/pda_paymod = FALSE // if TRUE, click on someone to pay
	var/list/trans_log = list()
	var/list/safe_pages = list(7, 71, 72, 73)
	var/list/owner_fingerprints = list()	//fingerprint information is taken from the ID card
	var/boss_PDA = 0	//the PDA belongs to the heads or not	(can I change the salary?)
	var/list/subordinate_staff = list()
	var/last_trans_tick = 0

	var/obj/item/device/paicard/pai = null	// A slot for a personal AI device

/obj/item/device/pda/atom_init()
	. = ..()
	PDAs += src
	PDAs = sortAtom(PDAs)
	if(default_cartridge)
		cartridge = new default_cartridge(src)
	new /obj/item/weapon/pen(src)

/obj/item/device/pda/Destroy()
	PDAs -= src
	if (src.id && prob(90)) //IDs are kept in 90% of the cases
		src.id.loc = get_turf(src.loc)
	return ..()

/obj/item/device/pda/examine(mob/user)
	..()
	if(src in user)
		if (SSshuttle.online)
			to_chat(user, "The time [worldtime2text()] and shuttle ETA [shuttleeta2text()] are displayed in the corner of the screen.")
		else
			to_chat(user, "The time [worldtime2text()] is displayed in the corner of the screen.")

/obj/item/device/pda/AltClick(mob/user)
	if (can_use(user) && id)
		remove_id()
		update_icon()
	else if (can_use(user))
		verb_remove_pen()

/obj/item/device/pda/medical
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-m"

/obj/item/device/pda/viro
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-v"

/obj/item/device/pda/engineering
	default_cartridge = /obj/item/weapon/cartridge/engineering
	icon_state = "pda-e"

/obj/item/device/pda/security
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-s"

/obj/item/device/pda/detective
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon_state = "pda-det"

/obj/item/device/pda/warden
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-warden"

/obj/item/device/pda/janitor
	default_cartridge = /obj/item/weapon/cartridge/janitor
	icon_state = "pda-j"
	ttone = "slip"

/obj/item/device/pda/science
	default_cartridge = /obj/item/weapon/cartridge/signal/science
	icon_state = "pda-tox"
	ttone = "boom"

/obj/item/device/pda/clown
	default_cartridge = /obj/item/weapon/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/device/pda/clown/atom_init()
	. = ..()
	AddComponent(/datum/component/slippery, 4, NONE, CALLBACK(src, .proc/AfterSlip))

/obj/item/device/pda/clown/proc/AfterSlip(mob/living/carbon/human/M)
	if (istype(M) && (M.real_name != owner))
		var/obj/item/weapon/cartridge/clown/cart = cartridge
		if(istype(cart) && cart.charges < 5)
			cart.charges++

/obj/item/device/pda/mime
	default_cartridge = /obj/item/weapon/cartridge/mime
	icon_state = "pda-mime"
	message_silent = 1
	ttone = "silence"

/obj/item/device/pda/velocity
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-velocity"

/obj/item/device/pda/velocity/doctor
	default_cartridge = /obj/item/weapon/cartridge/medical

/obj/item/device/pda/heads
	default_cartridge = /obj/item/weapon/cartridge/head
	icon_state = "pda-h"

/obj/item/device/pda/heads/hop
	default_cartridge = /obj/item/weapon/cartridge/hop
	icon_state = "pda-hop"

/obj/item/device/pda/heads/hos
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-hos"

/obj/item/device/pda/heads/ce
	default_cartridge = /obj/item/weapon/cartridge/ce
	icon_state = "pda-ce"

/obj/item/device/pda/heads/cmo
	default_cartridge = /obj/item/weapon/cartridge/cmo
	icon_state = "pda-cmo"

/obj/item/device/pda/heads/rd
	default_cartridge = /obj/item/weapon/cartridge/rd
	icon_state = "pda-rd"

/obj/item/device/pda/captain
	default_cartridge = /obj/item/weapon/cartridge/captain
	icon_state = "pda-c"
	detonate = 0
	//toff = 1

/obj/item/device/pda/cargo
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/device/pda/quartermaster
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-q"

/obj/item/device/pda/shaftminer
	icon_state = "pda-miner"

/obj/item/device/pda/syndicate
	default_cartridge = /obj/item/weapon/cartridge/syndicate
	icon_state = "pda-syn"
	name = "Military PDA"
	owner = "John Doe"
	hidden = 1

/obj/item/device/pda/chaplain
	icon_state = "pda-holy"
	ttone = "holy"

/obj/item/device/pda/lawyer
	default_cartridge = /obj/item/weapon/cartridge/lawyer
	icon_state = "pda-lawyer"
	ttone = "..."

/obj/item/device/pda/lawyer2
	default_cartridge = /obj/item/weapon/cartridge/lawyer
	icon_state = "pda-lawyer-old"
	ttone = "..."

/obj/item/device/pda/botanist
	//default_cartridge = /obj/item/weapon/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/device/pda/roboticist
	icon_state = "pda-robot"

/obj/item/device/pda/librarian
	icon_state = "pda-libb"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	message_silent = 1 //Quiet in the library!

/obj/item/device/pda/reporter
	icon_state = "pda-libc"

/obj/item/device/pda/forensic
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda-forensic"

/obj/item/device/pda/clear
	icon_state = "pda-transp"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."
	note = "Congratulations, you have chosen the Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"

/obj/item/device/pda/chef
	icon_state = "pda-chef"

/obj/item/device/pda/barber
	icon_state = "pda-barber"

/obj/item/device/pda/bar
	icon_state = "pda-bar"

/obj/item/device/pda/atmos
	default_cartridge = /obj/item/weapon/cartridge/atmos
	icon_state = "pda-atmo"

/obj/item/device/pda/chemist
	default_cartridge = /obj/item/weapon/cartridge/chemistry
	icon_state = "pda-chem"

/obj/item/device/pda/geneticist
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-gene"


// Special AI/pAI PDAs that cannot explode.
/obj/item/device/pda/silicon
	icon_state = "NONE"
	ttone = "data"
	detonate = 0


/obj/item/device/pda/silicon/proc/set_name_and_job(newname, newjob, newrank)
	owner = newname
	ownjob = newjob
	if(newrank)
		ownrank = newrank
	else
		ownrank = ownjob
	name = newname + " (" + ownjob + ")"


//AI verb and proc for sending PDA messages.
/obj/item/device/pda/silicon/verb/cmd_send_pdamesg()
	set category = "AI Commands"
	set name = "Send Message"
	set src in usr
	set hidden = 1
	if(usr.stat == DEAD)
		to_chat(usr, "You can't send PDA messages because you are dead!")
		return
	var/list/plist = available_pdas()
	if (plist)
		var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)
		if (!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		create_message(usr, selected)


/obj/item/device/pda/silicon/verb/cmd_toggle_pda_receiver()
	set category = "AI Commands"
	set name = "Toggle Sender/Receiver"
	set src in usr
	if(usr.stat == DEAD)
		to_chat(usr, "You can't do that because you are dead!")
		return
	toff = !toff
	to_chat(usr, "<span class='notice'>PDA sender/receiver toggled [(toff ? "Off" : "On")]!</span>")


/obj/item/device/pda/silicon/verb/cmd_toggle_pda_silent()
	set category = "AI Commands"
	set name = "Toggle Ringer"
	set src in usr
	if(usr.stat == DEAD)
		to_chat(usr, "You can't do that because you are dead!")
		return
	message_silent = !message_silent
	to_chat(usr, "<span class='notice'>PDA ringer toggled [(message_silent ? "Off" : "On")]!</span>")


/obj/item/device/pda/silicon/verb/cmd_show_message_log()
	set category = "AI Commands"
	set name = "Show Message Log"
	set src in usr
	set hidden = 1
	if(usr.stat == DEAD)
		to_chat(usr, "You can't do that because you are dead!")
		return
	var/HTML = "<html><head><title>AI PDA Message Log</title></head><body>"
	for(var/index in tnote)
		if(index["sent"])
			HTML += addtext("<i><b>&rarr; To <a href='byond://?src=\ref[src];choice=Message;target=",index["src"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
		else
			HTML += addtext("<i><b>&larr; From <a href='byond://?src=\ref[src];choice=Message;target=",index["target"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
	HTML +="</body></html>"
	usr << browse(HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")


/obj/item/device/pda/silicon/can_use()
	return 1


/obj/item/device/pda/silicon/attack_self(mob/user)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(src, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MASTER, 30)
	return

//Special PDA for robots

/obj/item/device/pda/silicon/robot/cmd_toggle_pda_receiver()
	set category = "Robot Commands"
	set hidden = 1
	..()

/obj/item/device/pda/silicon/robot/cmd_toggle_pda_silent()
	set category = "Robot Commands"
	set hidden = 1
	..()

/obj/item/device/pda/silicon/pai
	ttone = "assist"


/*
 *	The Actual PDA
 */

/obj/item/device/pda/proc/can_use()

	if(!ismob(loc))
		return 0

	var/mob/M = loc
	if(M.incapacitated())
		return 0
	if((src in M.contents) || ( istype(loc, /turf) && in_range(src, M) ))
		return 1
	else
		return 0

/obj/item/device/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/device/pda/GetID()
	return id

/obj/item/device/pda/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /obj/screen)) && can_use())
		return attack_self(M)
	return


/obj/item/device/pda/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	ui_tick++
	var/datum/nanoui/old_ui = nanomanager.get_open_ui(user, src, "main")
	var/auto_update = 1
	if(mode in no_auto_update)
		auto_update = 0
	if(old_ui && (mode == lastmode && ui_tick % 5 && (mode in update_every_five)))
		return

	lastmode = mode

	var/title = "Personal Data Assistant"

	var/data[0]  // This is the data that will be sent to the PDA

	data["owner"] = owner					// Who is your daddy...
	data["ownjob"] = ownjob					// ...and what does he do?

	data["money"] = owner_account ? owner_account.money : "error"
	data["salary"] = owner_account ? owner_account.owner_salary : "error"
	data["target_account_number"] = target_account_number
	data["funds_amount"] = funds_amount
	data["purpose"] = transfer_purpose
	data["trans_log"] = trans_log
	data["time_to_next_pay"] = time_stamp(format = "mm:ss", wtime = (SSeconomy.endtime - world.timeofday))
	data["boss"] = boss_PDA
	data["subordinate_staff"] = subordinate_staff
	data["ready_to_send"] = (last_trans_tick > world.time) ? 0 : 1

	data["mode"] = mode					// The current view
	data["scanmode"] = scanmode				// Scanners
	data["fon"] = fon					// Flashlight on?
	data["pai"] = (isnull(pai) ? 0 : 1)			// pAI inserted?
	data["note"] = note					// current pda notes
	data["message_silent"] = message_silent					// does the pda make noise when it receives a message?
	data["toff"] = toff					// is the messenger function turned off?
	data["active_conversation"] = active_conversation	// Which conversation are we following right now?


	data["idInserted"] = (id ? 1 : 0)
	data["idLink"] = (id ? text("[id.registered_name], [id.assignment]") : "--------")

	data["cart_loaded"] = cartridge ? 1:0
	if(cartridge)
		var/cartdata[0]
		cartdata["access"] = list(\
					"access_security" = cartridge.access_security,\
					"access_engine" = cartridge.access_engine,\
					"access_atmos" = cartridge.access_atmos,\
					"access_medical" = cartridge.access_medical,\
					"access_clown" = cartridge.access_clown,\
					"access_mime" = cartridge.access_mime,\
					"access_janitor" = cartridge.access_janitor,\
					"access_quartermaster" = cartridge.access_quartermaster,\
					"access_hydroponics" = cartridge.access_hydroponics,\
					"access_reagent_scanner" = cartridge.access_reagent_scanner,\
					"access_remote_door" = cartridge.access_remote_door,\
					"access_status_display" = cartridge.access_status_display,\
					"access_detonate_pda" = cartridge.access_detonate_pda\
			)

		if(mode in cartmodes)
			data["records"] = cartridge.create_NanoUI_values()

		if(mode == 0)
			cartdata["name"] = cartridge.name
			if(isnull(cartridge.radio))
				cartdata["radio"] = 0
			else
				if(istype(cartridge.radio, /obj/item/radio/integrated/beepsky))
					cartdata["radio"] = 1
				if(istype(cartridge.radio, /obj/item/radio/integrated/signal))
					cartdata["radio"] = 2
				if(istype(cartridge.radio, /obj/item/radio/integrated/mule))
					cartdata["radio"] = 3

		if(mode == 2)
			cartdata["type"] = cartridge.type
			cartdata["charges"] = cartridge.charges ? cartridge.charges : 0
		data["cartridge"] = cartdata

	data["stationTime"] = worldtime2text()

	var/secLevelStr
	switch(get_security_level())
		if("green")
			secLevelStr = "<font color='green'><b>&#9899;</b></font>"
		if("blue")
			secLevelStr = "<font color='blue'><b>&#9899;</b></font>"
		if("red")
			secLevelStr = "<font color='red'><b>&#9899;</b></font>"
		if("delta")
			secLevelStr = "<font color='purple'><b>&Delta;</b></font>"
	data["securityLevel"] = secLevelStr

	data["new_Message"] = newmessage
	if (SSshuttle.online)
		data["shuttle_eta"] = shuttleeta2text()

	if(mode==2)
		var/convopdas[0]
		var/pdas[0]
		var/count = 0
		for (var/obj/item/device/pda/P in PDAs)
			if (!P.owner||P.toff||P == src||P.hidden)       continue
			if(conversations.Find("\ref[P]"))
				convopdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "1")))
			else
				pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
			count++

		data["convopdas"] = convopdas
		data["pdas"] = pdas
		data["pda_count"] = count

	if(mode==21)
		data["messagescount"] = tnote.len
		data["messages"] = tnote
	else
		data["messagescount"] = null
		data["messages"] = null

	if(active_conversation)
		for(var/c in tnote)
			if(c["target"] == active_conversation)
				data["convo_name"] = sanitize(c["owner"])
				data["convo_job"] = sanitize(c["job"])
				break
	if(mode==41)
		data_core.get_manifest_json()

	if(mode==3)
		var/turf/T = get_turf(user.loc)
		if(!isnull(T))
			var/datum/gas_mixture/environment = T.return_air()

			var/pressure = environment.return_pressure()
			var/total_moles = environment.total_moles

			if (total_moles)
				var/o2_level = environment.gas["oxygen"] / total_moles
				var/n2_level = environment.gas["nitrogen"] / total_moles
				var/co2_level = environment.gas["carbon_dioxide"] / total_moles
				var/phoron_level = environment.gas["phoron"] / total_moles
				var/unknown_level =  1 - (o2_level + n2_level + co2_level + phoron_level)
				data["aircontents"] = list(
					"pressure" = "[round(pressure,0.1)]",
					"nitrogen" = "[round(n2_level*100,0.1)]",
					"oxygen" = "[round(o2_level*100,0.1)]",
					"carbon_dioxide" = "[round(co2_level*100,0.1)]",
					"phoron" = "[round(phoron_level*100,0.01)]",
					"other" = "[round(unknown_level, 0.01)]",
					"temp" = "[round(environment.temperature-T0C,0.1)]",
					"reading" = 1
					)
		if(isnull(data["aircontents"]))
			data["aircontents"] = list("reading" = 0)

	nanoUI = data
	// update the ui if it exists, returns null if no ui is passed/found
	if(ui)
		ui.load_cached_data(ManifestJSON)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		// the ui does not exist, so we'll create a new() one
	        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "pda.tmpl", title, 520, 400)
		// when the ui is first opened this is the data it will use

		ui.load_cached_data(ManifestJSON)

		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
	// auto update every Master Controller tick
	ui.set_auto_update(auto_update)

//NOTE: graphic resources are loaded on client login
/obj/item/device/pda/attack_self(mob/user)

	user.set_machine(src)

	if(active_uplink_check(user))
		return

	if(mode in safe_pages)
		mode = 0	//for safety
	ui_interact(user) //NanoUI requires this proc
	return

/obj/item/device/pda/Topic(href, href_list)
	if(href_list["cartmenu"] && !isnull(cartridge))
		cartridge.Topic(href, href_list)
		return 1
	if(href_list["radiomenu"] && !isnull(cartridge) && !isnull(cartridge.radio))
		cartridge.radio.Topic(href, href_list)
		return 1


	..()
	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")
	var/mob/living/U = usr
	//Looking for master was kind of pointless since PDAs don't appear to have one.
	//if ((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ) )
	if(!can_use()) //Why reinvent the wheel? There's a proc that does exactly that.
		U.unset_machine()
		if(ui)
			ui.close()
		return 0

	add_fingerprint(U)
	U.set_machine(src)

	if(href_list && (last_tap_sound <= world.time))
		if(iscarbon(usr))
			playsound(src, pick(SOUNDIN_PDA_TAPS), VOL_EFFECTS_MASTER, 15, FALSE)
			last_tap_sound = world.time + 8

	switch(href_list["choice"])

//BASIC FUNCTIONS===================================

		if("Close")//Self explanatory
			U.unset_machine()
			ui.close()
			return 0
		if("Refresh")//Refresh, goes to the end of the proc.
		if("Return")//Return
			if(mode<=9)
				mode = 0
			else
				mode = round(mode/10)
				if(mode==2)
					active_conversation = null
				if(mode==4)//Fix for cartridges. Redirects to hub.
					mode = 0
				else if(mode >= 40 && mode <= 49)//Fix for cartridges. Redirects to refresh the menu.
					cartridge.mode = mode
		if ("Authenticate")//Checks for ID
			id_check(U, 1)
		if("UpdateInfo")
			ownjob = id.assignment
			ownrank = id.rank
			check_rank(id.rank)		//check if we became the head
			name = "PDA-[owner] ([ownjob])"
			if(owner_account && owner_account.account_number == id.associated_account_number)
				return
			ui.close()
			var/datum/money_account/account = get_account(id.associated_account_number)
			if(account)		//another account tied to the card
				account.owner_PDA = src		//set PDA in /datum/money_account
				owner_account = account		//bind the account to the pda
				owner_fingerprints = list()	//remove old fingerprints
			else	//no account was tied to a card
				owner_account = null		//clear old account information
				owner_fingerprints = list()	//remove old fingerprints
		if("Eject")//Ejects the cart, only done from hub.
			if (!isnull(cartridge))
				var/turf/T = loc
				if(ismob(T))
					T = T.loc
				cartridge.loc = T
				mode = 0
				scanmode = 0
				if (cartridge.radio)
					cartridge.radio.hostpda = null
				cartridge = null

//MENU FUNCTIONS===================================

		if("0")//Hub
			mode = 0
		if("1")//Notes
			mode = 1
		if("2")//Messenger
			mode = 2
		if("21")//Read messages
			mode = 21
		if("3")//Atmos scan
			mode = 3
		if("4")//Redirects to hub
			mode = 0
		if("chatroom") // chatroom hub
			mode = 5
		if("41") //Manifest
			mode = 41

//MAIN FUNCTIONS===================================

		if("Light")
			if(fon)
				fon = 0
				set_light(0)
			else
				fon = 1
				set_light(f_lum)
		if("Medical Scan")
			if(scanmode == 1)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_medical))
				scanmode = 1
		if("Reagent Scan")
			if(scanmode == 3)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_reagent_scanner))
				scanmode = 3
		if("Halogen Counter")
			if(scanmode == 4)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_engine))
				scanmode = 4
		if("Honk")
			if ( !(last_honk && world.time < last_honk + 20) )
				playsound(src, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MASTER)
				last_honk = world.time
		if("Gas Scan")
			if(scanmode == 5)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_atmos))
				scanmode = 5

//MESSENGER/NOTE FUNCTIONS===================================

		if ("Edit")
			var/n = sanitize(input(U, "Please enter message", name, input_default(notehtml)) as message, extra = FALSE)
			if (in_range(src, U) && loc == U && mode == 1)
				note = html_decode(n)
				notehtml = note
				note = replacetext(note, "\n", "<br>")
			else
				ui.close()
		if("Toggle Messenger")
			toff = !toff
		if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
			message_silent = !message_silent
		if("Clear")//Clears messages
			if(href_list["option"] == "All")
				tnote.Cut()
				conversations.Cut()
			if(href_list["option"] == "Convo")
				var/new_tnote[0]
				for(var/i in tnote)
					if(i["target"] != active_conversation)
						new_tnote[++new_tnote.len] = i
				tnote = new_tnote
				conversations.Remove(active_conversation)

			active_conversation = null
			if(mode==21)
				mode=2

		if("Ringtone")
			var/t = sanitize(input(U, "Please enter new ringtone", name, input_default(ttone)) as text, 20)
			if (t && in_range(src, U) && loc == U)
				if(src.hidden_uplink && hidden_uplink.check_trigger(U, lowertext(t), lowertext(lock_code)))
					to_chat(U, "The PDA softly beeps.")
					ui.close()
				else
					ttone = t
			else
				ui.close()
				return 0
		if("Message")

			var/obj/item/device/pda/P = locate(href_list["target"])
			src.create_message(U, P, !href_list["notap"])
			if(mode == 2)
				if(href_list["target"] in conversations)            // Need to make sure the message went through, if not welp.
					active_conversation = href_list["target"]
					mode = 21

		if("Select Conversation")
			var/P = href_list["convo"]
			for(var/n in conversations)
				if(P == n)
					active_conversation=P
					mode=21
		if ("Send Honk")//Honk virus
			if(istype(cartridge, /obj/item/weapon/cartridge/clown))//Cartridge checks are kind of unnecessary since everything is done through switch.
				var/obj/item/device/pda/P = locate(href_list["target"])//Leaving it alone in case it may do something useful, I guess.
				if(!isnull(P))
					if (!P.toff && cartridge.charges > 0)
						cartridge.charges--
						to_chat(U, "<span class='notice'>Virus sent!</span>")
						P.honkamt = (rand(15,20))
				else
					to_chat(U, "PDA not found.")
			else
				ui.close()
				return 0
		if("Send Silence")//Silent virus
			if(istype(cartridge, /obj/item/weapon/cartridge/mime))
				var/obj/item/device/pda/P = locate(href_list["target"])
				if(!isnull(P))
					if (!P.toff && cartridge.charges > 0)
						cartridge.charges--
						to_chat(U, "<span class='notice'>Virus sent!</span>")
						P.message_silent = 1
						P.ttone = "silence"
				else
					to_chat(U, "PDA not found.")
			else
				ui.close()
				return 0

//Finance Management=============================================================

		if("Finance")
			if(check_owner_fingerprints(U))
				mode = 7

		if("Transaction Menu")
			mode = 71

		if("Transaction Log")
			mode = 72
			trans_log = null
			for(var/datum/transaction/T in owner_account.transaction_log)
				trans_log += list(list("data"="[T.date]", "time"="[T.time]", "name"="[T.target_name]", "purpose"="[T.purpose]", "amount"="[T.amount]", "source"="[T.source_terminal]"))

		if("Send Money")
			if(check_owner_fingerprints(U))
				target_account_number = text2num(href_list["account"])
				mode = 71

		if("Look for")
			ui.close()
			to_chat(U, "[bicon(src)]<span class='notice'>Select transfer recipient.</span>")
			pda_paymod = TRUE

		if("Show Manifest")
			mode = 41

		if("target_acc_number")
			target_account_number = text2num(input(U, "Enter an account number", name, target_account_number) as text)	//If "as num" I can't copy text from the buffer
		if("funds_amount")
			funds_amount =  round(text2num(input(U, "Enter the amount of funds", name, funds_amount) as text), 1)
		if("purpose")
			transfer_purpose = sanitize(input(U, "Enter the purpose of the transaction", name, transfer_purpose) as text, 20)

		if("make_transfer")
		//============check telecoms and message server=================
			var/obj/machinery/message_server/useMS = FALSE
			var/useTC = FALSE
			if(message_servers)
				for(var/obj/machinery/message_server/MS in message_servers)
					if(MS.active)
						useMS = TRUE
						break

			var/datum/signal/signal = src.telecomms_process()
			
			if(signal && signal.data["done"])
				useTC = TRUE
			if(!useMS || !useTC)
				to_chat(U, "[bicon(src)]<span class='warning'>Communication Error</span>")
				return
		//==============================================================
			if(owner_account.suspended)
				to_chat(U, "[bicon(src)]<span class='warning'>Your account is suspended!</span>")
				return
			if(funds_amount <= 0)
				to_chat(U, "[bicon(src)]<span class='warning'>That is not a valid amount!</span>")
				return
			if(funds_amount > owner_account.money)
				to_chat(U, "[bicon(src)]<span class='warning'>You don't have enough funds to do that!</span>")
				return
			if(target_account_number == owner_account.account_number)
				to_chat(U, "[bicon(src)]<span class='warning'>Eror! [target_account_number] is your account number, [owner].</span>")
				return
			if(charge_to_account(target_account_number, target_account_number, transfer_purpose, name, funds_amount))
				charge_to_account(owner_account.account_number, target_account_number, transfer_purpose, name, -funds_amount)
			else
				to_chat(U, "[bicon(src)]<span class='warning'>Funds transfer failed. Target account is suspended.</span>")
			target_account_number = 0
			funds_amount = 0
			last_trans_tick = world.time + TRANSCATION_COOLDOWN

		if("Staff Salary")
			mode = 73
			subordinate_staff = my_subordinate_staff(ownrank)

		if("Change Salary")
			var/account_number = text2num(href_list["account"])
			for(var/person in subordinate_staff)
				if(account_number == person["acc_number"])
					var/datum/money_account/account = person["acc_datum"]
					account.change_salary(U, owner, name, ownrank)
					break

//SYNDICATE FUNCTIONS===================================

		if("Toggle Door")
			if(cartridge && cartridge.access_remote_door)
				for(var/obj/machinery/door/poddoor/M in poddoor_list)
					if(M.id == cartridge.remote_door_id)
						if(M.density)
							M.open()
						else
							M.close()

		if("Detonate")//Detonate PDA... maybe
			// check if telecomms I/O route 1459 is stable
			//var/telecomms_intact = telecomms_process(P.owner, owner, t)
			var/obj/machinery/message_server/useMS = null
			if(message_servers)
				for (var/obj/machinery/message_server/MS in message_servers)
				//PDAs are now dependant on the Message Server.
					if(MS.active)
						useMS = MS
						break

			var/datum/signal/signal = src.telecomms_process()

			var/useTC = 0
			if(signal)
				if(signal.data["done"])
					useTC = 1
					var/turf/pos = get_turf(src)
					if(pos.z in signal.data["level"])
						useTC = 2

			if(istype(cartridge, /obj/item/weapon/cartridge/syndicate))
				if(!(useMS && useTC))
					U.show_message("<span class='warning'>An error flashes on your [src]: Connection unavailable</span>", SHOWMSG_VISUAL, "<span class='warning'>You hear a negative *beep*</span>", SHOWMSG_AUDIO)
					return
				if(useTC != 2) // Does our recepient have a broadcaster on their level?
					U.show_message("<span class='warning'>An error flashes on your [src]: Recipient unavailable</span>", SHOWMSG_VISUAL, "<span class='warning'>You hear a negative *beep*</span>", SHOWMSG_AUDIO)
					return
				var/obj/item/device/pda/P = locate(href_list["target"])
				if(!isnull(P))
					if (!P.toff && cartridge.charges > 0)
						cartridge.charges--

						var/difficulty = 2

						if(P.cartridge)
							difficulty += P.cartridge.access_medical
							difficulty += P.cartridge.access_security
							difficulty += P.cartridge.access_engine
							difficulty += P.cartridge.access_clown
							difficulty += P.cartridge.access_janitor
							if(P.hidden_uplink)
								difficulty += 3

						if(prob(difficulty))
							U.show_message("<span class='warning'>An error flashes on your [src].</span>", SHOWMSG_VISUAL, "<span class='warning'>You hear a negative *beep*</span>", SHOWMSG_AUDIO)
						else if (prob(difficulty * 7))
							U.show_message("<span class='warning'>Energy feeds back into your [src]!</span>", SHOWMSG_VISUAL, "<span class='warning'>You hear a negative *beep*</span>", SHOWMSG_AUDIO)
							ui.close()
							detonate_act(src)
							log_admin("[key_name(U)] just attempted to blow up [P] with the Detomatix cartridge but failed, blowing themselves up")
							message_admins("[key_name_admin(U)] just attempted to blow up [P] with the Detomatix cartridge but failed. [ADMIN_JMP(U)]")
						else
							to_chat("<span class='notice'>Success!</span>")
							log_admin("[key_name(U)] just attempted to blow up [P] with the Detomatix cartridge and succeeded")
							message_admins("[key_name_admin(U)] just attempted to blow up [P] with the Detomatix cartridge and succeeded. [ADMIN_JMP(U)]")
							detonate_act(P)
					else
						to_chat(U, "No charges left.")
				else
					to_chat(U, "PDA not found.")
			else
				U.unset_machine()
				ui.close()
				return 0

//pAI FUNCTIONS===================================
		if("pai")
			if(pai)
				if(pai.loc != src)
					pai = null
				else
					switch(href_list["option"])
						if("1")		// Configure pAI device
							pai.attack_self(U)
						if("2")		// Eject pAI device
							var/turf/T = get_turf_or_move(src.loc)
							if(T)
								pai.loc = T
								pai = null

		else
			mode = text2num(href_list["choice"])
			if(cartridge)
				cartridge.mode = mode

//EXTRA FUNCTIONS===================================

	if (mode == 2||mode == 21)//To clear message overlays.
		newmessage = 0
		update_icon()

	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(src, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MASTER, 30)

	return 1 // return 1 tells it to refresh the UI in NanoUI

/obj/item/device/pda/update_icon()
	..()

	cut_overlays()
	if(newmessage)
		add_overlay(image('icons/obj/pda.dmi', "pda-r"))
	if(id)
		var/id_overlay = get_id_overlay(id)
		if(id_overlay)
			add_overlay(image('icons/obj/pda.dmi', id_overlay))

/obj/item/device/pda/proc/get_id_overlay(obj/item/weapon/card/id/I)
	if(!I)
		return
	if(I.icon_state in ALLOWED_ID_OVERLAYS)
		return I.icon_state
	return "id"

/obj/item/device/pda/proc/detonate_act(obj/item/device/pda/P)
	//TODO: sometimes these attacks show up on the message server
	var/i = rand(1,100)
	var/j = rand(0,1) //Possibility of losing the PDA after the detonation
	var/message = ""
	var/mob/living/M = null
	if(ismob(P.loc))
		M = P.loc

	//switch(i) //Yes, the overlapping cases are intended.
	if(i<=10) //The traditional explosion
		P.explode()
		j=1
		message += "Your [P] suddenly explodes!"
	if(i>=10 && i<= 20) //The PDA burns a hole in the holder.
		j=1
		if(M && isliving(M))
			M.apply_damage( rand(30,60) , BURN)
		message += "You feel a searing heat! Your [P] is burning!"
	if(i>=20 && i<=25) //EMP
		empulse(P.loc, 3, 6, 1)
		message += "Your [P] emits a wave of electromagnetic energy!"
	if(i>=25 && i<=40) //Smoke
		var/datum/effect/effect/system/smoke_spread/S = new /datum/effect/effect/system/smoke_spread
		S.attach(P.loc)
		S.set_up(n = 10, c = 0, loca = P.loc, direct = 0)
		playsound(P, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, null, null, -3)
		S.start()
		message += "Large clouds of smoke billow forth from your [P]!"
	if(i>=40 && i<=45) //Bad smoke
		var/datum/effect/effect/system/smoke_spread/bad/B = new /datum/effect/effect/system/smoke_spread/bad
		B.attach(P.loc)
		B.set_up(n = 10, c = 0, loca = P.loc, direct = 0)
		playsound(P, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, null, null, -3)
		B.start()
		message += "Large clouds of noxious smoke billow forth from your [P]!"
	if(i>=65 && i<=75) //Weaken
		if(M && isliving(M))
			M.apply_effects(0,1)
		message += "Your [P] flashes with a blinding white light! You feel weaker."
	if(i>=75 && i<=85) //Stun and stutter
		if(M && isliving(M))
			M.apply_effects(1,0,0,0,1)
		message += "Your [P] flashes with a blinding white light! You feel weaker."
	if(i>=85) //Sparks
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(n = 2, c = 1, loca = P.loc)
		s.start()
		message += "Your [P] begins to spark violently!"
	if(i>45 && i<65 && prob(50)) //Nothing happens
		message += "Your [P] bleeps loudly."
		j = prob(10)

	if(j) //This kills the PDA
		P.Destroy()
		if(message)
			message += "It melts in a puddle of plastic."
		else
			message += "Your [P] shatters in a thousand pieces!"

	if(M && isliving(M))
		message = "<span class='warning'></span>" + message
		M.show_message(message, SHOWMSG_ALWAYS) //vas visual only before, it's important message so I changed this. You can add more different messages

/obj/item/device/pda/proc/remove_id()
	if (id)
		if (ismob(loc))
			var/mob/M = loc
			M.put_in_hands(id)
			to_chat(usr, "<span class='notice'>You remove the ID from the [name].</span>")
		else
			id.loc = get_turf(src)
		id = null

/obj/item/device/pda/proc/create_message(mob/living/U = usr, obj/item/device/pda/P, tap = 1)
	if(tap && iscarbon(U))
		U.visible_message("<span class='notice'>[U] taps on \his PDA's screen.</span>")
	U.last_target_click = world.time
	var/t = sanitize(input(U, "Please enter message", name, null) as text)
	t = replacetext(t, "&#34;", "\"")

	if (!t || !istype(P))
		return
	if (!in_range(src, U) && loc != U)
		return

	if (isnull(P)||P.toff || toff)
		return

	if (last_text && world.time < last_text + 5)
		return

	if(!can_use())
		return

	last_text = world.time
	// check if telecomms I/O route 1459 is stable
	//var/telecomms_intact = telecomms_process(P.owner, owner, t)
	var/obj/machinery/message_server/useMS = null
	if(message_servers)
		for (var/obj/machinery/message_server/MS in message_servers)
		//PDAs are now dependent on the Message Server.
			if(MS.active)
				useMS = MS
				break

	var/datum/signal/signal = src.telecomms_process()

	var/useTC = 0
	if(signal)
		if(signal.data["done"])
			useTC = 1
			var/turf/pos = get_turf(P)
			if(pos.z in signal.data["level"])
				useTC = 2
				//Let's make this barely readable
				if(signal.data["compression"] > 0)
					t = Gibberish(t, signal.data["compression"] + 50)

	if(useMS && useTC) // only send the message if it's stable
		if(useTC != 2) // Does our recipient have a broadcaster on their level?
			to_chat(U, "ERROR: Cannot reach recipient.")
			return

		useMS.send_pda_message("[P.owner]","[owner]","[t]")
		tnote.Add(list(list("sent" = 1, "owner" = "[P.owner]", "job" = "[P.ownjob]", "message" = "[t]", "target" = "\ref[P]")))
		P.tnote.Add(list(list("sent" = 0, "owner" = "[owner]", "job" = "[ownjob]", "message" = "[t]", "target" = "\ref[src]")))
		for(var/mob/M in player_list)
			if(M.stat == DEAD && M.client && (M.client.prefs.chat_toggles & CHAT_GHOSTEARS)) // src.client is so that ghosts don't have to listen to mice
				if(isnewplayer(M))
					continue
				to_chat(M, "<span class='game say'>PDA Message - <span class='name'>[owner]</span> -> <span class='name'>[P.owner]</span>: <span class='message emojify linkify'>[t]</span></span>")

		if(!conversations.Find("\ref[P]"))
			conversations.Add("\ref[P]")
		if(!P.conversations.Find("\ref[src]"))
			P.conversations.Add("\ref[src]")

		if (prob(15)) //Give the AI a chance of intercepting the message
			var/who = src.owner
			if(prob(50))
				who = P.owner
			for(var/mob/living/silicon/ai/ai in ai_list)
				// Allows other AIs to intercept the message but the AI won't intercept their own message.
				if(ai.pda != P && ai.pda != src)
					to_chat(ai, "<i>Intercepted message from <b>[who]</b>: <span class='emojify linkify'>[t]</span></i>")

		nanomanager.update_user_uis(U, src) // Update the sending user's PDA UI so that they can see the new message

		if (!P.message_silent)
			playsound(P, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
			audible_message("[bicon(P)] *[P.ttone]*", hearing_distance = 3)

		//Search for holder of the PDA.
		var/mob/living/L = null
		if(P.loc && isliving(P.loc))
			L = P.loc
		//Maybe they are a pAI!
		else
			L = get(P, /mob/living/silicon)


		if(L)
			to_chat(L, "[bicon(P)] <b>Message from [src.owner] ([ownjob]), </b>\"<span class='message emojify linkify'>[t]</span>\" (<a href='byond://?src=\ref[P];choice=Message;notap=[istype(loc, /mob/living/silicon)];skiprefresh=1;target=\ref[src]'>Reply</a>)")
			nanomanager.update_user_uis(L, P) // Update the receiving user's PDA UI so that they can see the new message

		nanomanager.update_user_uis(U, P) // Update the sending user's PDA UI so that they can see the new message

		log_pda("[usr] (PDA: [src.name]) sent \"[t]\" to [P.name]")
		P.cut_overlays()
		P.add_overlay(image('icons/obj/pda.dmi', "pda-r"))
		P.newmessage = 1
	else
		to_chat(U, "<span class='notice'>ERROR: Messaging server is not responding.</span>")

/obj/item/device/pda/verb/verb_reset_pda()
	set category = "Object"
	set name = "Reset PDA"
	set src in usr

	if(issilicon(usr))
		return

	if(can_use(usr))
		mode = 0
		nanomanager.update_uis(src)
		to_chat(usr, "<span class='notice'>You press the reset button on \the [src].</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")

/obj/item/device/pda/verb/verb_remove_id()
	set category = "Object"
	set name = "Remove id"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		if(id)
			remove_id()
			update_icon()
		else
			to_chat(usr, "<span class='notice'>This PDA does not have an ID in it.</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")


/obj/item/device/pda/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove pen"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			if (istype(loc, /mob))
				var/mob/M = loc
				if(M.get_active_hand() == null)
					M.put_in_hands(O)
					to_chat(usr, "<span class='notice'>You remove \the [O] from \the [src].</span>")
					playsound(src, 'sound/items/penclick.ogg', VOL_EFFECTS_MASTER, 20)
					return
			O.loc = get_turf(src)
		else
			to_chat(usr, "<span class='notice'>This PDA does not have a pen in it.</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")


/obj/item/device/pda/proc/id_check(mob/user, choice)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if (id)
			remove_id()
		else
			var/obj/item/I = user.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				user.drop_item()
				I.loc = src
				id = I
	else
		var/obj/item/weapon/card/I = user.get_active_hand()
		if (istype(I, /obj/item/weapon/card/id) && I:registered_name)
			var/obj/old_id = id
			user.drop_item()
			I.loc = src
			id = I
			user.put_in_hands(old_id)
	update_icon()
	return

// access to status display signals
/obj/item/device/pda/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/cartridge) && !cartridge)
		cartridge = I
		user.drop_from_inventory(I, src)
		to_chat(user, "<span class='notice'>You insert [cartridge] into [src].</span>")
		nanomanager.update_uis(src) // update all UIs attached to src
		if(cartridge.radio)
			cartridge.radio.hostpda = src

	else if(istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/idcard = I
		if(!idcard.registered_name)
			to_chat(user, "<span class='notice'>\The [src] rejects the ID.</span>")
			return
		if(!owner)
			owner = idcard.registered_name
			ownjob = idcard.assignment
			ownrank = idcard.rank
			check_rank(idcard.rank)
			var/datum/money_account/account = get_account(idcard.associated_account_number)
			if(account)
				account.owner_PDA = src			//set PDA in /datum/money_account
				owner_account = account			//bind the account to the pda
				owner_fingerprints = list()		//remove old fingerprints
			name = "PDA-[owner] ([ownjob])"
			to_chat(user, "<span class='notice'>Card scanned.</span>")
		else
			//Basic safety check. If either both objects are held by user or PDA is on ground and card is in hand.
			if(((src in user.contents) && (idcard in user.contents)) || (istype(loc, /turf) && in_range(src, user) && (idcard in user.contents)) )
				id_check(user, 2)
				to_chat(user, "<span class='notice'>You put the ID into \the [src]'s slot.</span>")
				updateSelfDialog()//Update self dialog on success.
			return	//Return in case of failed check or when successful.
		updateSelfDialog()//For the non-input related code.
	else if(istype(I, /obj/item/device/paicard) && !src.pai)
		user.drop_from_inventory(I, src)
		pai = I
		to_chat(user, "<span class='notice'>You slot \the [I] into [src].</span>")
		nanomanager.update_uis(src) // update all UIs attached to src
	else if(istype(I, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			to_chat(user, "<span class='notice'>There is already a pen in \the [src].</span>")
		else
			user.drop_from_inventory(I, src)
			to_chat(user, "<span class='notice'>You slide \the [I] into \the [src].</span>")
	else
		return ..()

/obj/item/device/pda/attack(mob/living/L, mob/living/user)
	if (istype(L, /mob/living/carbon))
		var/mob/living/carbon/C = L
		var/data_message = ""
		switch(scanmode)
			if(1)
				data_message += "<span class='notice'>Analyzing Results for [C]:</span>"
				data_message += "<span class='notice'>&emsp; Overall Status: [C.stat > 1 ? "dead" : "[C.health - C.halloss]% healthy"]</span>"
				var/has_oxy_damage = (C.getOxyLoss() > 50)
				var/has_tox_damage = (C.getToxLoss() > 50)
				var/has_fire_damage = (C.getFireLoss() > 50)
				var/has_brute_damage = (C.getBruteLoss() > 50)
				data_message += "<span class='notice'>&emsp; Damage Specifics: <span class='[has_oxy_damage ? "warning" : "notice"]'>[C.getOxyLoss()]</span>-<span class='[has_tox_damage ? "warning" : "notice"]'>[C.getToxLoss()]</span>-<span class='[has_fire_damage ? "warning" : "notice"]'>[C.getFireLoss()]</span>-<span class='[has_brute_damage ? "warning" : "notice"]'>[C.getBruteLoss()]</span></span>"
				data_message += "<span class='notice'>&emsp; Key: Suffocation/Toxin/Burns/Brute</span>"
				data_message += "<span class='notice'>&emsp; Body Temperature: [C.bodytemperature-T0C]&deg;C ([C.bodytemperature*1.8-459.67]&deg;F)</span>"
				if(C.tod && (C.stat == DEAD || (C.status_flags & FAKEDEATH)))
					data_message += "<span class='notice'>&emsp; Time of Death: [C.tod]</span>"
				if(istype(C, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = C
					var/list/damaged = H.get_damaged_bodyparts(1, 1)
					data_message += "<span class='notice'>Localized Damage, Brute/Burn:</span>"
					if(length(damaged)>0)
						for(var/obj/item/organ/external/BP in damaged)
							data_message += text("<span class='notice'>&emsp; []: []-[]</span>",capitalize(BP.name),(BP.brute_dam > 0)?"<span class='warning'>[BP.brute_dam]</span>":0,(BP.burn_dam > 0)?"<span class='warning'>[BP.burn_dam]</span>":0)
					else
						data_message += "<span class='notice'>&emsp; Limbs are OK.</span>"

				for(var/datum/disease/D in C.viruses)
					if(!D.hidden[SCANNER])
						data_message += "<span class='warning'><b>Warning: [D.form] Detected</b>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]</span>"

				visible_message("<span class='warning'>[user] has analyzed [C]'s vitals!</span>")
				to_chat(user, data_message)

			if(2)
				if (!istype(C.dna, /datum/dna))
					data_message += "<span class='notice'>No fingerprints found on [C]</span>"
				else if(istype(C, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = C
					if(H.gloves)
						data_message += "<span class='notice'>No fingerprints found on [C]</span>"
				else
					data_message += text("<span class='notice'>[C]'s Fingerprints: [md5(C.dna.uni_identity)]</span>")
				if ( !(C.blood_DNA) )
					data_message += "<span class='notice'>No blood found on [C]</span>"
					if(C.blood_DNA)
						C.blood_DNA = null
				else
					data_message += "<span class='notice'>Blood found on [C]. Analysing...</span>"
					spawn(15)
						for(var/blood in C.blood_DNA)
							data_message += "<span class='notice'>Blood type: [C.blood_DNA[blood]]\nDNA: [blood]</span>"
				to_chat(user, data_message)

			if(4)
				data_message += "<span class='notice'>Analyzing Results for [C]:</span>"
				if(C.radiation)
					data_message += "<span class='notice'>Radiation Level:</span> [C.radiation]"
				else
					data_message += "<span class='notice'>No radiation detected.</span>"
				visible_message("<span class='warning'>[user] has analyzed [C]'s radiation levels!</span>")
				to_chat(user, data_message)

/obj/item/device/pda/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	switch(scanmode)

		if(3)
			if(!isobj(target))
				return
			if(!isnull(target.reagents))
				if(target.reagents.reagent_list.len > 0)
					var/reagents_length = target.reagents.reagent_list.len
					to_chat(user, "<span class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found.</span>")
					for (var/re in target.reagents.reagent_list)
						to_chat(user, "<span class='notice'>&emsp; [re]</span>")
				else
					to_chat(user, "<span class='notice'>No active chemical agents found in [target].</span>")
			else
				to_chat(user, "<span class='notice'>No significant chemical agents found in [target].</span>")

		if(5)
			analyze_gases(target, user)

	if (!scanmode && istype(target, /obj/item/weapon/paper) && owner)
		var/obj/item/weapon/paper/P = target
		note = P.info
		to_chat(user, "<span class='notice'>Paper scanned.</span>")//concept of scanning paper copyright brainoblivion 2009

/obj/item/device/pda/get_current_temperature()
	. = 5
	if(detonate)
		. += 10

/obj/item/device/pda/proc/explode() //This needs tuning. //Sure did.
	if(!src.detonate) return
	var/turf/T = get_turf(src.loc)
	if(T)
		T.hotspot_expose(700,125)
		explosion(T, 0, 0, 1, rand(1,2))
	return

/obj/item/device/pda/proc/available_pdas()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if (toff)
		to_chat(usr, "Turn on your receiver in order to send messages.")
		return

	for (var/obj/item/device/pda/P in PDAs)
		if (!P.owner)
			continue
		else if(P.hidden)
			continue
		else if (P == src)
			continue
		else if (P.toff)
			continue

		var/name = P.owner
		if (name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P
	return plist

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/device/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emplode(severity)

/obj/item/device/pda/proc/click_to_pay(atom/target)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/receiver = target
		if(receiver.mind.initial_account)
			target_account_number = text2num(receiver.mind.initial_account.account_number)
			mode = 7
			pda_paymod = FALSE
			ui_interact(usr)
			to_chat(usr, "[bicon(src)]<span class='info'>Target account is [target_account_number]</span>")
			return
		else
			to_chat(usr, "[bicon(src)]<span class='warning'>Target haven't account.</span>")
			pda_paymod = FALSE
			return
	else
		to_chat(usr, "[bicon(src)]<span class='warning'>Incorrect target.</span>")
		pda_paymod = FALSE
		return

/obj/item/device/pda/proc/check_owner_fingerprints(mob/living/carbon/human/user)
	if(!owner_account)
		alert("Eror! Account information not saved in this PDA, please insert your ID card in PDA and update the information.")
		return FALSE
	if(!user.dna)	//just in case
		alert("Eror! PDA can't read your fingerprints.")
		return FALSE
	var/fingerprints = md5(user.dna.uni_identity)
	if(fingerprints in owner_fingerprints)
		return TRUE
	else
		var/tried_pin =  text2num(input(user, "[owner] please enter your account password", name) as text)
		if(tried_pin == owner_account.remote_access_pin)
			owner_fingerprints += fingerprints	//add new owner's fingerprints to the list
			to_chat(user, "[bicon(src)]<span class='info'>Password is correct</span>")
			return TRUE
		else
			alert("Invalid Password!")
			return FALSE

/obj/item/device/pda/proc/transaction_inform(target, source, amount, salary_change = FALSE)
	if(!can_use())
		return
	if(src.message_silent)
		return
	//Search for holder of the PDA. (some copy-paste from /obj/item/device/pda/proc/create_message)
	var/mob/living/L = null
	if(src.loc && isliving(src.loc))
		L = src.loc
	if(L)
		if(salary_change)
			if(amount > 0)
				to_chat(L, "[bicon(src)]<font color='#579914'><b>[owner], your salary was increased by [source] by [amount]%!</b></font>")
			else if(amount < 0)
				to_chat(L, "[bicon(src)]<span class='red'>[owner], your salary was reduced by [source] by [amount]%!</span>")
			else
				to_chat(L, "[bicon(src)]<span class='notice'><b>[owner], [source] returned your base salary.</b></span>")
		else
			if(amount > 0)
				to_chat(L, "[bicon(src)]<span class='notice'>[owner], the amount of [amount]$ from [source] was transferred to your account.</span>")
			else
				to_chat(L, "[bicon(src)]<span class='notice'>You have successfully transferred [amount]$ to [target] account number.</span>")
		playsound(L, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)

/obj/item/device/pda/proc/check_rank(rank)
	if((rank in command_positions) || (rank == "Quartermaster"))
		boss_PDA = 1

#undef TRANSCATION_COOLDOWN
