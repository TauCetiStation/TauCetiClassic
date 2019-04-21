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

/obj/item/device/healthanalyzer/attack(mob/living/M, mob/living/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.flags[IS_SYNTHETIC] || H.species.flags[IS_PLANT])
			user.show_message("<span class = 'notice'>Analyzing Results for ERROR:\n&emsp; Overall Status: ERROR</span>")
			user.show_message("&emsp; Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font>", 1)
			user.show_message("&emsp; Damage Specifics: <font color='blue'>?</font> - <font color='green'>?</font> - <font color='#FFA500'>?</font> - <font color='red'>?</font>")
			user.show_message("<span class = 'notice'>Body Temperature: [H.bodytemperature-T0C]&deg;C ([H.bodytemperature*1.8-459.67]&deg;F)</span>", 1)
			user.show_message("<span class = 'warning bold'>Warning: Blood Level ERROR: --% --cl.</span><span class = 'notice bold'>Type: ERROR</span>")
			user.show_message("<span class = 'notice'>Subject's pulse:</span><font color='red'>-- bpm.</font>")
			return
		else
			health_analyze(M, user, mode)
	else
		user.show_message("<span class = 'warning'>Analyzing Results not compiled. Unknown anatomy detected.</span>")

/obj/item/device/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(TRUE)
			to_chat(usr, "The scanner now shows specific limb damage.")
		if(FALSE)
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
		msg_admin_attack("<span = 'danger'>[user] ([user.ckey]) irradiated [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>)</span>")
		var/cooldown = round(max(10, (intensity*5 - wavelength/4))) * 10
		used = 1
		icon_state = "health1"
		spawn(cooldown) // splits off to handle the cooldown while handling wavelength
			used = 0
			icon_state = "health"
		to_chat(user,"<span class='warning'>Successfully irradiated [M].</span>")
		M.attack_log += text("\[[time_stamp()]\]<font color='orange'> Has been irradiated by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>irradiated [M.name]'s ([M.ckey])</font>")
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
	flags = CONDUCT
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
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(usr, "\red You don't have the dexterity to do this!")
		return

	analyze_gases(user.loc, user,advanced_mode)
	return TRUE

/obj/item/device/analyzer/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if (user.incapacitated())
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(usr, "\red You don't have the dexterity to do this!")
		return
	if(istype(O) && O.simulated)
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
	if (user.stat)
		return
	if (crit_fail)
		to_chat(user, "\red This device has critically failed and is no longer functional!")
		return
	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "\red You don't have the dexterity to do this!")
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != "blood")
				reagents.clear_reagents()
				to_chat(user, "\red The sample was contaminated! Please insert another sample")
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

/obj/item/device/reagent_scanner/afterattack(obj/O, mob/user)
	if (user.stat)
		return
	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "\red You don't have the dexterity to do this!")
		return
	if(!istype(O))
		return
	if (crit_fail)
		to_chat(user, "\red This device has critically failed and is no longer functional!")
		return

	if(!isnull(O.reagents))
		var/dat = ""
		if(O.reagents.reagent_list.len > 0)
			var/one_percent = O.reagents.total_volume / 100
			for (var/datum/reagent/R in O.reagents.reagent_list)
				if(prob(reliability))
					dat += "\n &emsp; \blue [R][details ? ": [R.volume / one_percent]%" : ""]"
					recent_fail = 0
				else if(recent_fail)
					crit_fail = 1
					dat = null
					break
				else
					recent_fail = 1
		if(dat)
			to_chat(user, "\blue Chemicals found: [dat]")
		else
			to_chat(user, "\blue No active chemical agents found in [O].")
	else
		to_chat(user, "\blue No significant chemical agents found in [O].")

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

/obj/item/weapon/occult_pinpointer/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = W
		target_type = OS.scanned_type
		target = null // So we ain't looking for the old target
		to_chat(user, "<span class='notice'>[src] succesfully extracted [pick("mythical","magical","arcane")] knowledge from [W]</span>")

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

/obj/item/device/occult_scanner/afterattack(mob/M, mob/user)
	if(user && user.client)
		if(ishuman(M) && M.stat == DEAD)
			user.visible_message("<span class='notice'>[user] scans [M], the air around them humming gently.</span>",
			                     "<span class='notice'>[M] was [pick("possessed", "devoured", "destroyed", "murdered", "captured")] by [pick("Cthulhu", "Mi-Go", "Elder God", "dark spirit", "Outsider", "unknown alien creature")]</span>")
