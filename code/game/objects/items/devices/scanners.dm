/*
CONTAINS:
T-RAY
DETECTIVE SCANNER
HEALTH ANALYZER
GAS ANALYZER
PLANT ANALYZER
MASS SPECTROMETER
REAGENT SCANNER
*/
/obj/item/device/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	slot_flags = SLOT_FLAGS_BELT
	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	m_amt = 150
	origin_tech = "magnets=1;engineering=1"

	var/on = FALSE

/obj/item/device/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = "t-ray[on]"

	if(on)
		START_PROCESSING(SSobj, src)

/obj/item/device/t_scanner/proc/flick_sonar(obj/pipe)
	if(ismob(loc))
		var/mob/M = loc
		var/image/I = new(loc = get_turf(pipe))

		var/mutable_appearance/MA = new(pipe)
		MA.alpha = 128
		MA.dir = pipe.dir

		I.appearance = MA
		if(M.client)
			flick_overlay(I, list(M.client), 8)

/obj/item/device/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	scan()

/obj/item/device/t_scanner/proc/scan()

	for(var/turf/T in range(1, src.loc) )

		if(!T.intact)
			continue

		for(var/obj/O in T.contents)

			if(O.level != 1)
				continue

			if(O.invisibility >= INVISIBILITY_MAXIMUM)
				flick_sonar(O)

/obj/item/device/healthanalyzer
	name = "Health Analyzer"
	icon_state = "health"
	item_state = "healthanalyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	origin_tech = "magnets=1;biotech=1"
	var/mode = TRUE
	var/output_to_chat = TRUE
	var/last_scan = ""
	var/last_scan_name = ""

/obj/item/device/healthanalyzer/attack(mob/living/M, mob/living/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.flags[IS_SYNTHETIC] || H.species.flags[IS_PLANT])
			var/message = ""
			if(!output_to_chat)
				message += "<HTML><head><title>[M.name]'s scan results</title></head><BODY>"

			message += "<span class = 'notice'>Analyzing Results for ERROR:\n&emsp; Overall Status: ERROR</span><br>"
			message += "&emsp; Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font><br>"
			message += "&emsp; Damage Specifics: <font color='blue'>?</font> - <font color='green'>?</font> - <font color='#FFA500'>?</font> - <font color='red'>?</font><br>"
			message += "<span class = 'notice'>Body Temperature: [H.bodytemperature-T0C]&deg;C ([H.bodytemperature*1.8-459.67]&deg;F)</span><br>"
			message += "<span class = 'warning bold'>Warning: Blood Level ERROR: --% --cl.</span><span class = 'notice bold'>Type: ERROR</span><br>"
			message += "<span class = 'notice'>Subject's pulse:</span><font color='red'>-- bpm.</font><br>"

			last_scan = message
			last_scan_name = M.name
			if(!output_to_chat)
				message += "</BODY></HTML>"
				user << browse(message, "window=[M.name]_scan_report;size=400x400;can_resize=1")
				onclose(user, "[M.name]_scan_report")
			else
				to_chat(user, message)

			add_fingerprint(user)
			return
		else
			add_fingerprint(user)
			var/dat = health_analyze(M, user, mode, output_to_chat)
			last_scan = dat
			last_scan_name = M.name
			if(!output_to_chat)
				user << browse(dat, "window=[M.name]_scan_report;size=400x400;can_resize=1")
				onclose(user, "[M.name]_scan_report")
			else
				to_chat(user, dat)
	else
		add_fingerprint(user)
		to_chat(user, "<span class = 'warning'>Analyzing Results not compiled. Unknown anatomy detected.</span>")

/obj/item/device/healthanalyzer/attack_self(mob/user)
	user << browse(last_scan, "window=[last_scan_name]_scan_report;size=400x400;can_resize=1")
	onclose(user, "[last_scan_name]")

/obj/item/device/healthanalyzer/verb/toggle_output()
	set name = "Toggle Output"
	set category = "Object"

	output_to_chat = !output_to_chat
	if(output_to_chat)
		to_chat(usr, "The scanner now outputs data to chat.")
	else
		to_chat(usr, "The scanner now outputs data in a seperate window.")

/obj/item/device/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	mode = !mode
	if(mode)
		to_chat(usr, "The scanner now shows specific limb damage.")
	else
		to_chat(usr, "The scanner no longer shows limb damage.")

/obj/item/device/healthanalyzer/rad_laser
	materials = list(MAT_METAL=400)
	origin_tech = "magnets=3;biotech=5;syndicate=3"
	var/irradiate = 1
	var/intensity = 10 // how much damage the radiation does
	var/wavelength = 10 // time it takes for the radiation to kick in, in seconds
	var/used = 0 // is it cooling down?

/obj/item/device/healthanalyzer/rad_laser/attack(mob/living/M, mob/living/user)
	..()
	if(!irradiate)
		return
	if(!used)
		var/cooldown = round(max(10, (intensity*5 - wavelength/4))) * 10
		used = 1
		icon_state = "health1"
		spawn(cooldown) // splits off to handle the cooldown while handling wavelength
			used = 0
			icon_state = "health"
		to_chat(user,"<span class='warning'>Successfully irradiated [M].</span>")
		M.log_combat(user, "irradiated with [name]")
		spawn((wavelength+(intensity*4))*5)
			if(M)
				if(intensity >= 5)
					M.apply_effect(round(intensity/1.5), PARALYZE)
				M.apply_effect(intensity * 10,IRRADIATE, 0)
	else
		to_chat(user,"<span class='warning'>The radioactive microlaser is still recharging.</span>")

/obj/item/device/healthanalyzer/rad_laser/attack_self(mob/user)
	interact(user)

/obj/item/device/healthanalyzer/rad_laser/interact(mob/user)
	user.set_machine(src)
	var/cooldown = round(max(10, (intensity*5 - wavelength/4)))
	var/dat = "Irradiation: <A href='?src=\ref[src];rad=1'>[irradiate ? "On" : "Off"]</A><br>"

	dat += {"
	Radiation Intensity:
	<A href='?src=\ref[src];radint=-5'>-</A><A href='?src=\ref[src];radint=-1'>-</A>
	[intensity]
	<A href='?src=\ref[src];radint=1'>+</A><A href='?src=\ref[src];radint=5'>+</A><BR>

	Radiation Wavelength:
	<A href='?src=\ref[src];radwav=-5'>-</A><A href='?src=\ref[src];radwav=-1'>-</A>
	[(wavelength+(intensity*4))]
	<A href='?src=\ref[src];radwav=1'>+</A><A href='?src=\ref[src];radwav=5'>+</A><BR>
	Laser Cooldown: [cooldown] Seconds<BR>
	"}

	var/datum/browser/popup = new(user, "radlaser", "Radioactive Microlaser Interface", 400, 240)
	popup.set_content(dat)
	popup.open()

/obj/item/device/healthanalyzer/rad_laser/Topic(href, href_list)

	usr.set_machine(src)
	if(href_list["rad"])
		irradiate = !irradiate

	else if(href_list["radint"])
		var/amount = text2num(href_list["radint"])
		amount += intensity
		intensity = max(1,(min(20,amount)))

	else if(href_list["radwav"])
		var/amount = text2num(href_list["radwav"])
		amount += wavelength
		wavelength = max(0,(min(120,amount)))

	attack_self(usr)
	add_fingerprint(usr)
	return


/obj/item/device/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels."
	name = "analyzer"
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL
	flags = CONDUCT | NOBLUDGEON | NOATTACKANIMATION
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=1;engineering=1"

	action_button_name = "Use Analyzer"

	var/advanced_mode = 0

/obj/item/device/analyzer/verb/verbosity(mob/user as mob)
	set name = "Toggle Advanced Gas Analysis"
	set category = "Object"
	set src in usr

	if (!user.incapacitated())
		advanced_mode = !advanced_mode
		to_chat(usr, "You toggle advanced gas analysis [advanced_mode ? "on" : "off"].")

/obj/item/device/analyzer/attack_self(mob/user)

	if (user.incapacitated())
		return
	if (!(istype(usr, /mob/living/carbon/human) || SSticker) && SSticker.mode.name != "monkey")
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	analyze_gases(user.loc, user,advanced_mode)
	return TRUE

/obj/item/device/analyzer/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if (user.incapacitated())
		return
	if (!(istype(usr, /mob/living/carbon/human) || SSticker) && SSticker.mode.name != "monkey")
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(!isobj(target))
		return
	var/obj/O = target
	if(O.simulated)
		analyze_gases(O, user, advanced_mode)

/obj/item/device/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	name = "mass-spectrometer"
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL
	flags = CONDUCT | OPENCONTAINER
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=2;biotech=2"
	var/details = 0
	var/recent_fail = 0

/obj/item/device/mass_spectrometer/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(5)
	reagents = R
	R.my_atom = src

/obj/item/device/mass_spectrometer/on_reagent_change()
	if(reagents.total_volume)
		icon_state = initial(icon_state) + "_s"
	else
		icon_state = initial(icon_state)

/obj/item/device/mass_spectrometer/attack_self(mob/user)
	if (crit_fail)
		to_chat(user, "<span class='warning'>This device has critically failed and is no longer functional!</span>")
		return
	if (!(istype(user, /mob/living/carbon/human) || SSticker) && SSticker.mode.name != "monkey")
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != "blood")
				reagents.clear_reagents()
				to_chat(user, "<span class='warning'>The sample was contaminated! Please insert another sample</span>")
				return
			else
				blood_traces = params2list(R.data["trace_chem"])
				break
		var/dat = "Trace Chemicals Found: "
		for(var/R in blood_traces)
			if(prob(reliability))
				if(details)
					dat += "[R] ([blood_traces[R]] units) "
				else
					dat += "[R] "
				recent_fail = 0
			else
				if(recent_fail)
					crit_fail = 1
					reagents.clear_reagents()
					return
				else
					recent_fail = 1
		to_chat(user, "[dat]")
		reagents.clear_reagents()
	return

/obj/item/device/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=2"

/obj/item/device/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents."
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=2;biotech=2"
	var/details = 0
	var/recent_fail = 0

/obj/item/device/reagent_scanner/afterattack(atom/target, mob/user, proximity, params)
	if (!(istype(user, /mob/living/carbon/human) || SSticker) && SSticker.mode.name != "monkey")
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(!isobj(target))
		return
	var/obj/O = target
	if (crit_fail)
		to_chat(user, "<span class='warning'>This device has critically failed and is no longer functional!</span>")
		return

	if(!isnull(O.reagents))
		var/dat = ""
		if(O.reagents.reagent_list.len > 0)
			var/one_percent = O.reagents.total_volume / 100
			for (var/datum/reagent/R in O.reagents.reagent_list)
				if(prob(reliability))
					dat += "\n &emsp; <span class='notice'>[R][details ? ": [R.volume / one_percent]%" : ""]</span>"
					recent_fail = 0
				else if(recent_fail)
					crit_fail = 1
					dat = null
					break
				else
					recent_fail = 1
		if(dat)
			to_chat(user, "<span class='notice'>Chemicals found: [dat]</span>")
		else
			to_chat(user, "<span class='notice'>No active chemical agents found in [O].</span>")
	else
		to_chat(user, "<span class='notice'>No significant chemical agents found in [O].</span>")

	return

/obj/item/device/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=2"

/obj/item/weapon/occult_pinpointer
	name = "occult locator"
	icon = 'icons/obj/device.dmi'
	icon_state = "locoff"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/target = null
	var/target_type = /obj/item/weapon/reagent_containers/food/snacks/ectoplasm
	var/active = FALSE

/obj/item/weapon/occult_pinpointer/attack_self()
	if(!active)
		to_chat(usr, "<span class='notice'>You activate the [name]</span>")
		START_PROCESSING(SSobj, src)
	else
		icon_state = "locoff"
		to_chat(usr, "<span class='notice'>You deactivate the [name]</span>")
		STOP_PROCESSING(SSobj, src)
	active = !active

/obj/item/weapon/occult_pinpointer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		target_type = OS.scanned_type
		target = null // So we ain't looking for the old target
		to_chat(user, "<span class='notice'>[src] succesfully extracted [pick("mythical", "magical", "arcane")] knowledge from [I].</span>")
	else
		return ..()

/obj/item/weapon/occult_pinpointer/Destroy()
	active = FALSE
	STOP_PROCESSING(SSobj, src)
	target = null
	return ..()

/obj/item/weapon/occult_pinpointer/process()
	if(!active)
		return
	if(!target)
		target = locate(target_type)
		if(!target)
			icon_state = "locnull"
			return
	dir = get_dir(src,target)
	if(get_dist(src,target))
		icon_state = "locon"

/obj/item/device/occult_scanner
	name = "occult scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "occult_scan"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/scanned_type = /obj/item/weapon/reagent_containers/food/snacks/ectoplasm

/obj/item/device/occult_scanner/attack_self(mob/user)
	if(!istype(scanned_type, /obj/item/weapon/reagent_containers/food/snacks/ectoplasm))
		scanned_type = /obj/item/weapon/reagent_containers/food/snacks/ectoplasm
		to_chat(user, "<span class='notice'>You reset the scanned object of the scanner.</span>")

/obj/item/device/occult_scanner/afterattack(atom/target, mob/user, proximity, params)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	if(user && user.client && H.stat == DEAD)
		user.visible_message("<span class='notice'>[user] scans [H], the air around them humming gently.</span>",
			                 "<span class='notice'>[H] was [pick("possessed", "devoured", "destroyed", "murdered", "captured")] by [pick("Cthulhu", "Mi-Go", "Elder God", "dark spirit", "Outsider", "unknown alien creature")]</span>")

/obj/item/device/contraband_finder
	name = "Contrband Finder"
	icon_state = "contraband_scanner"
	item_state = "contraband_scanner"
	desc = "A hand-held body scanner able to detect items that can't go past customs."
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	origin_tech = "magnets=4"

	var/can_scan = TRUE

	var/list/contraband_items = list(/obj/item/weapon/storage/box/syndie_kit/merch,
	                                 /obj/item/weapon/match,
	                                 /obj/item/clothing/mask/cigarette,
	                                 /obj/item/weapon/lighter,
	                                 /obj/item/weapon/storage/fancy/cigarettes,
	                                 /obj/item/weapon/storage/secure/briefcase,
	                                 /obj/item/weapon/storage/pouch/pistol_holster,
	                                 /obj/item/weapon/storage/pouch/baton_holster,
	                                 /obj/item/clothing/accessory/holster,
	                                 /obj/item/device/flash,
	                                 /obj/item/weapon/reagent_containers/hypospray,
	                                 /obj/item/weapon/reagent_containers/syringe,
	                                 /obj/item/weapon/reagent_containers/glass/bottle,
	                                 /obj/item/weapon/reagent_containers/food,
	                                 /obj/item/weapon/cartridge/clown,
	                                 /obj/item/weapon/bananapeel,
	                                 /obj/item/weapon/soap,
	                                 /obj/item/weapon/bikehorn,
	                                 /obj/item/toy/sound_button,
	                                 /obj/item/device/tabletop_assistant,
	                                 /obj/item/weapon/storage/pill_bottle,
	                                 /obj/item/device/paicard,
	                                 /obj/item/clothing/mask/ecig,
	                                 /obj/item/weapon/game_kit,
	                                 /obj/item/weapon/legcuffs,
	                                 /obj/item/weapon/handcuffs,
	                                 /obj/item/weapon/reagent_containers/spray/pepper
	                                 )

	var/list/danger_items = list(/obj/item/device/uplink,
	                             /obj/item/weapon/gun,
	                             /obj/item/weapon/shield,
	                             /obj/item/clothing/head/helmet,
	                             /obj/item/clothing/suit/armor,
	                             /obj/item/weapon/melee/powerfist,
	                             /obj/item/weapon/melee/energy/sword,
	                             /obj/item/weapon/storage/box/emps,
	                             /obj/item/weapon/grenade/empgrenade,
	                             /obj/item/weapon/grenade/syndieminibomb,
	                             /obj/item/weapon/grenade/spawnergrenade/manhacks,
	                             /obj/item/weapon/antag_spawner/borg_tele,
	                             /obj/item/ammo_box,
	                             /obj/item/ammo_casing,
	                             /obj/item/weapon/storage/box/syndie_kit/cutouts,
	                             /obj/item/cardboard_cutout,
	                             /obj/item/clothing/gloves/black/strip,
	                             /obj/item/weapon/soap/syndie,
	                             /obj/item/weapon/cartridge/syndicate,
	                             /obj/item/toy/carpplushie/dehy_carp,
	                             /obj/item/weapon/storage/box/syndie_kit/chameleon,
	                             /obj/item/weapon/storage/box/syndie_kit/fake,
	                             /obj/item/weapon/storage/backpack/satchel/flat,
	                             /obj/item/clothing/shoes/syndigaloshes,
	                             /obj/item/clothing/mask/gas/voice,
	                             /obj/item/device/chameleon,
	                             /obj/item/device/camera_bug,
	                             /obj/item/weapon/silencer,
	                             /obj/item/weapon/storage/box/syndie_kit/throwing_weapon,
	                             /obj/item/weapon/pen/edagger,
	                             /obj/item/weapon/grenade/clusterbuster/soap,
	                             /obj/item/device/healthanalyzer/rad_laser,
	                             /obj/item/weapon/card/emag,
	                             /obj/item/weapon/storage/toolbox/syndicate,
	                             /obj/item/weapon/storage/backpack/dufflebag/surgery,
	                             /obj/item/weapon/storage/backpack/dufflebag/c4,
	                             /obj/item/weapon/plastique,
	                             /obj/item/weapon/storage/belt/military,
	                             /obj/item/weapon/storage/firstaid/tactical,
	                             /obj/item/weapon/storage/firstaid/small_firstaid_kit/combat,
	                             /obj/item/weapon/storage/box/syndie_kit/space,
	                             /obj/item/clothing/glasses/thermal/syndi,
	                             /obj/item/device/flashlight/emp,
	                             /obj/item/device/encryptionkey/binary,
	                             /obj/item/device/encryptionkey/syndicate,
	                             /obj/item/weapon/storage/box/syndie_kit/posters,
	                             /obj/item/device/biocan,
	                             /obj/item/device/multitool/ai_detect,
	                             /obj/item/weapon/aiModule/freeform/syndicate,
	                             /obj/item/device/powersink,
	                             /obj/item/device/radio/beacon/syndicate,
	                             /obj/item/device/radio/beacon/syndicate_bomb,
	                             /obj/item/device/syndicatedetonator,
	                             /obj/item/weapon/shield/energy,
	                             /obj/item/device/traitor_caller,
	                             /obj/item/weapon/storage/box/syndie_kit/imp_freedom,
	                             /obj/item/weapon/storage/box/syndie_kit/imp_uplink,
	                             /obj/item/weapon/implanter/storage,
	                             /obj/item/weapon/storage/box/syndicate,
	                             /obj/item/device/assembly/mousetrap
	                             )

	var/list/contraband_reagents = list("sugar",
	                                    "serotrotium",
	                                    "kyphotorin",
	                                    "lube",
	                                    "glycerol",
	                                    "nicotine",
	                                    "nanites",
	                                    "nanites2",
	                                    "nanobots",
	                                    "mednanobots"
	                                    )

	var/list/contraband_reagents_types = list(/datum/reagent/consumable)

	var/list/danger_reagents_types = list(/datum/reagent/toxin)

	var/list/danger_reagents = list("potassium",
	                                "mercury",
	                                "chlorine",
	                                "radium",
	                                "uranium",
	                                "alphaamanitin",
	                                "aflatoxin",
	                                "chefspecial",
	                                "dioxin",
	                                "mulligan",
	                                "mutationtoxin",
	                                "amutationtoxin",
	                                "space_drugs",
	                                "cryptobiolin",
	                                "impedrezene",
	                                "stoxin2",
	                                "hyperzine",
	                                "blood",
	                                "nitroglycerin",
	                                "thermite",
	                                "fuel",
	                                "xenomicrobes",
	                                "ectoplasm"
	                                )

/obj/item/device/contraband_finder/proc/reset_color()
	icon_state = "contraband_scanner"
	item_state = "contraband_scanner"
	if(ismob(loc))
		var/mob/M = loc
		if(M.is_in_hands(src))
			if(M.hand)
				M.update_inv_l_hand()
			else
				M.update_inv_r_hand()
	can_scan = TRUE

/obj/item/device/contraband_finder/attack(mob/M, mob/user)
	return

/obj/item/device/contraband_finder/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	scan(target, user)

/obj/item/device/contraband_finder/MouseDrop_T(atom/dropping, mob/user)
	if(!dropping.Adjacent(user))
		return

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return

	scan(dropping, user)

/obj/item/device/contraband_finder/proc/scan(atom/target, mob/user)
	if(!can_scan)
		return

	var/list/to_check = target.get_contents()
	to_check += target

	var/danger_color = "green"

	to_check_loop:
		for(var/atom/A in to_check)
			if(danger_color == "green" && is_type_in_list(A, contraband_items))
				danger_color = "yellow"
			if(A.blood_DNA)
				danger_color = "red"
				break
			if(istype(A, /obj/item))
				var/obj/item/I = A
				if(I.is_sharp())
					danger_color = "red"
					break
				if(I.force >= 10)
					danger_color = "red"
					break
			if(is_type_in_list(A, danger_items))
				danger_color = "red"
				break

			if(A.reagents)
				if(danger_color == "green")
					for(var/reagent in contraband_reagents_types)
						if(locate(reagent) in A.reagents.reagent_list)
							danger_color = "yellow"

					for(var/reagent_id in contraband_reagents)
						if(A.reagents.has_reagent(reagent_id))
							danger_color = "yellow"

				for(var/reagent in danger_reagents_types)
					if(locate(reagent) in A.reagents.reagent_list)
						danger_color = "red"
						break to_check_loop

				for(var/reagent_id in danger_reagents)
					if(A.reagents.has_reagent(reagent_id))
						danger_color = "red"
						break to_check_loop

	switch(danger_color)
		if("green")
			user.visible_message("[bicon(src)] <span class='notice'>Ping.</span>")
			playsound(user, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER)
		if("yellow")
			user.visible_message("[bicon(src)] <span class='warning'>Beep!</span>")
			playsound(user, 'sound/rig/shortbeep.wav', VOL_EFFECTS_MASTER)
		if("red")
			user.visible_message("[bicon(src)] <span class='warning bold'>BE-E-E-EP!</span>")
			playsound(user, 'sound/rig/longbeep.wav', VOL_EFFECTS_MASTER)

	icon_state = "contraband_scanner_[danger_color]"
	item_state = "contraband_scanner_[danger_color]"
	if(user.hand)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()
	can_scan = FALSE
	addtimer(CALLBACK(src, .proc/reset_color), 2 SECONDS)
