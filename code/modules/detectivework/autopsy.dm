
//moved these here from code/defines/obj/weapon.dm
//please preference put stuff where it's easy to find - C

/obj/item/weapon/autopsy_scanner
	name = "autopsy scanner"
	desc = "Extracts information on wounds."
	icon = 'icons/obj/autopsy_scanner.dmi'
	icon_state = "autopsy_main"
	item_state = "autopsy"
	flags = CONDUCT
	w_class = ITEM_SIZE_SMALL
	origin_tech = "materials=1;biotech=1"
	var/list/datum/autopsy_data_scanner/wdata = list()
	var/list/datum/autopsy_data_scanner/chemtraces = list()
	var/target_name = null
	var/timeofdeath = null

/obj/item/weapon/paper/autopsy_report
	var/list/autopsy_data

/datum/autopsy_data_scanner
	var/weapon = null // this is the DEFINITE weapon type that was used
	var/list/bodyparts_scanned = list() // this maps a number of scanned bodyparts to
									 // the wounds to those bodyparts with this data's weapon type
	var/organ_names = ""

/datum/autopsy_data
	var/weapon = null
	var/pretend_weapon = null
	var/damage = 0
	var/hits = 0
	var/time_inflicted = 0

/datum/autopsy_data/proc/copy()
	var/datum/autopsy_data/W = new()
	W.weapon = weapon
	W.pretend_weapon = pretend_weapon
	W.damage = damage
	W.hits = hits
	W.time_inflicted = time_inflicted
	return W

/obj/item/weapon/autopsy_scanner/proc/add_data(obj/item/organ/external/BP)
	if(!BP.autopsy_data.len && !BP.trace_chemicals.len)
		return

	for(var/V in BP.autopsy_data)
		var/datum/autopsy_data/W = BP.autopsy_data[V]

		if(!W.pretend_weapon)
			/*
			// the more hits, the more likely it is that we get the right weapon type
			if(prob(50 + W.hits * 10 + W.damage))
			*/

			// Buffing this stuff up for now!
			if(1)
				W.pretend_weapon = W.weapon
			else
				W.pretend_weapon = pick("mechanical toolbox", "wirecutters", "revolver", "crowbar", "fire extinguisher", "tomato soup", "oxygen tank", "emergency oxygen tank", "laser", "bullet")


		var/datum/autopsy_data_scanner/D = wdata[V]
		if(!D)
			D = new()
			D.weapon = W.weapon
			wdata[V] = D

		if(!D.bodyparts_scanned[BP.body_zone])
			if(D.organ_names == "")
				D.organ_names = BP.name
			else
				D.organ_names += ", [BP.name]"

		qdel(D.bodyparts_scanned[BP.body_zone])
		D.bodyparts_scanned[BP.body_zone] = W.copy()

	for(var/V in BP.trace_chemicals)
		if(BP.trace_chemicals[V] > 0 && !chemtraces.Find(V))
			chemtraces += V

/obj/item/weapon/autopsy_scanner/verb/print_data()
	set category = "Object"
	set src in view(usr, 1)
	set name = "Print Data"
	flick("autopsy_printing",src)
	playsound(src, 'sound/items/polaroid1.ogg', VOL_EFFECTS_MASTER)
	if(usr.stat || !(istype(usr,/mob/living/carbon/human)))
		to_chat(usr, "No.")
		return

	var/scan_data = ""

	if(timeofdeath)
		scan_data += "<b>Time of death:</b> [worldtime2text(timeofdeath)]<br><br>"

	var/n = 1
	for(var/wdata_idx in wdata)
		var/datum/autopsy_data_scanner/D = wdata[wdata_idx]
		var/total_hits = 0
		var/total_score = 0
		var/list/weapon_chances = list() // maps weapon names to a score
		var/age = 0

		for(var/wound_idx in D.bodyparts_scanned)
			var/datum/autopsy_data/W = D.bodyparts_scanned[wound_idx]
			total_hits += W.hits

			var/wname = W.pretend_weapon

			if(wname in weapon_chances) weapon_chances[wname] += W.damage
			else weapon_chances[wname] = max(W.damage, 1)
			total_score+=W.damage


			var/wound_age = W.time_inflicted
			age = max(age, wound_age)

		var/damage_desc

		var/damaging_weapon = (total_score != 0)

		// total score happens to be the total damage
		switch(total_score)
			if(0)
				damage_desc = "Unknown"
			if(1 to 5)
				damage_desc = "<font color='green'>negligible</font>"
			if(5 to 15)
				damage_desc = "<font color='green'>light</font>"
			if(15 to 30)
				damage_desc = "<font color='orange'>moderate</font>"
			if(30 to 1000)
				damage_desc = "<font color='red'>severe</font>"

		if(!total_score) total_score = D.bodyparts_scanned.len

		scan_data += "<b>Weapon #[n]</b><br>"
		if(damaging_weapon)
			scan_data += "Severity: [damage_desc]<br>"
			scan_data += "Hits by weapon: [total_hits]<br>"
		scan_data += "Approximate time of wound infliction: [worldtime2text(age)]<br>"
		scan_data += "Affected limbs: [D.organ_names]<br>"
		scan_data += "Possible weapons:<br>"
		for(var/weapon_name in weapon_chances)
			scan_data += "\t[100*weapon_chances[weapon_name]/total_score]% [weapon_name]<br>"

		scan_data += "<br>"

		n++

	if(chemtraces.len)
		scan_data += "<b>Trace Chemicals: </b><br>"
		for(var/chemID in chemtraces)
			scan_data += chemID
			scan_data += "<br>"

	for(var/mob/O in viewers(usr))
		O.show_message("<span class='warning'>\the [src] rattles and prints out a sheet of paper.</span>", 1)

	sleep(10)

	var/obj/item/weapon/paper/autopsy_report/P = new(usr.loc)
	P.name = "Autopsy Data ([target_name])"
	P.info = "<tt>[scan_data]</tt>"
	P.autopsy_data = list() // Copy autopsy data for science tool
	for(var/wdata_idx in wdata)
		for(var/wound_idx in wdata[wdata_idx].bodyparts_scanned)
			var/datum/autopsy_data/W = wdata[wdata_idx].bodyparts_scanned[wound_idx]
			P.autopsy_data += W.copy()
	P.update_icon()

	if(istype(usr,/mob/living/carbon))
		// place the item in the usr's hand if possible
		if(!usr.r_hand)
			P.loc = usr
			usr.r_hand = P
			P.layer = ABOVE_HUD_LAYER
			P.plane = ABOVE_HUD_PLANE
		else if(!usr.l_hand)
			P.loc = usr
			usr.l_hand = P
			P.layer = ABOVE_HUD_LAYER
			P.plane = ABOVE_HUD_PLANE

	if(istype(usr,/mob/living/carbon/human))
		usr:update_inv_l_hand()
		usr:update_inv_r_hand()

/obj/item/weapon/autopsy_scanner/attack(mob/living/carbon/human/M, mob/living/carbon/user, def_zone)
	if(!istype(M))
		return

	if(!can_operate(M))
		return
	if(do_after(user,15,target = M))
		if(target_name != M.name)
			target_name = M.name
			src.wdata = list()
			src.chemtraces = list()
			src.timeofdeath = null
			to_chat(user, "<span class='warning'>A new patient has been registered.. Purging data for previous patient.</span>")

		src.timeofdeath = M.timeofdeath

		var/obj/item/organ/external/BP = M.get_bodypart(def_zone)
		if(!BP)
			to_chat(usr, "<b>You can't scan this body part.</b>")
			return
		if(!BP.open)
			to_chat(usr, "<b>You have to cut the limb open first!</b>")
			return
		for(var/mob/O in viewers(M))
			O.show_message("<span class='warning'>[user.name] scans the wounds on [M.name]'s [BP.name] with \the [src.name]</span>", 1)
		playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "[bicon(src)]<span class='notice'>Scanning completed!</span>")
		src.add_data(BP)
		flick("autopsy_scanning",src)
		return 1
