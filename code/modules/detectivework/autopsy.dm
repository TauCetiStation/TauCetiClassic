
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
	var/list/datum/autopsy_body_part/organs = list()
	var/list/datum/autopsy_body_part/chemtraces = list()
	var/target_name = null
	var/timeofdeath = null

/obj/item/weapon/paper/autopsy_report
	var/list/autopsy_data

/datum/autopsy_data
	var/weapon = null
	var/pretend_weapon = null
	var/damage = 0
	var/type_damage = ""
	var/hits = 0
	var/time_inflicted = ""

/datum/autopsy_data/proc/copy()
	var/datum/autopsy_data/W = new()
	W.weapon = weapon
	W.pretend_weapon = pretend_weapon
	W.damage = damage
	W.type_damage = type_damage
	W.hits = hits
	W.time_inflicted = time_inflicted
	return W

/datum/autopsy_body_part
	var/organ = ""
	var/list/datum/autopsy_data/trauma = list()

/obj/item/weapon/autopsy_scanner/proc/add_data(obj/item/organ/external/BP)
	if(!BP.autopsy_data.len && !BP.trace_chemicals.len)
		return

	var/datum/autopsy_body_part/D = organs[BP.name]
	if(!D)
		D = new()
		D.organ = BP.name
		organs[BP.name] = D

	for(var/tdata in BP.autopsy_data)
		var/datum/autopsy_data/W = BP.autopsy_data[tdata]
		if(!W.pretend_weapon)
			if(prob(40 + (W.hits * 10 + W.damage)))
				W.pretend_weapon = W.weapon
			else
				if(W.type_damage == BRUTE || W.type_damage == null || W.type_damage == "")
					W.pretend_weapon = pick("The mechanical toolbox", "The wirecutters", "The revolver", "The crowbar", "The fire extinguisher", "The tomato soup", "The oxygen tank", "The emergency oxygen tank", "The bullet", "The table", "The chair", "The ERROR")
				if(W.type_damage == BURN)
					W.pretend_weapon = pick("The laser", "The cigarette", "The lighter", "The ERROR", "The fire", "The hydrogen peroxide", "The steam", "The water", "The lava")
				if(W.type_damage == "mixed")
					W.pretend_weapon = pick("The nuclear explosion", "The explosion")
				if(W.type_damage == BRUISE)
					W.pretend_weapon = pick("The paper", "The nail", "The pen", "The shard", "The PDA", "The cat", "The dog", "The door", "The monkey", "The air", "The coin")

		if(!D.trauma[tdata])
			D.trauma[tdata] = W.copy()

	for(var/V in BP.trace_chemicals)
		if(BP.trace_chemicals[V] > 0 && !chemtraces.Find(V))
			chemtraces += V

/obj/item/weapon/autopsy_scanner/verb/print_data()
	set category = "Object"
	set src in view(usr, 1)
	set name = "Print Data"
	if(!ishuman(usr) || usr.incapacitated() || usr.lying)
		return

	flick("autopsy_printing",src)
	playsound(src, 'sound/items/polaroid1.ogg', VOL_EFFECTS_MASTER)

	var/scan_data = ""

	if(timeofdeath)
		scan_data += "<b>Time of death:</b> [worldtime2text(timeofdeath)]<br>"

	for(var/data in organs)
		var/datum/autopsy_body_part/D = organs[data]
		scan_data += "<table border=\"2\", style=\"text-align:center;\", width=\"100%\", table-layout: fixed;>"
		scan_data += "<tr><th colspan=\"5\">[D.organ]</th></tr>"
		scan_data += "<tr>"
		scan_data += "<th>Severity</th>"
		scan_data += "<th>Hits by weapon</th>"
		scan_data += "<th>Possible time</th>"
		scan_data += "<th>Possible weapon</th>"
		scan_data += "<th>Notes</th>"
		scan_data += "</tr>"
		for(var/tdata in D.trauma)
			var/datum/autopsy_data/W = D.trauma[tdata]
			var/damage_desc = ""
			var/type_damage = ""
			var/hits_desc = ""

			if(W.damage < 1)
				W.damage = 1

			if(W.type_damage == BRUTE)
				type_damage = " wound" //this space is really needed that table does not grow
			if(W.type_damage == BURN)
				type_damage = " burn"
			if(W.type_damage == "mixed")
				type_damage = " scorched wound"
			if(W.type_damage == BRUISE)
				type_damage = " bruise"

			switch(W.damage)
				if(0) //strangled comes in here
					damage_desc = "Unknown"
				if(1 to 5)
					damage_desc = "<font color='green'>negligible[type_damage]</font>"
				if(5 to 15)
					damage_desc = "<font color='green'>light[type_damage]</font>"
				if(15 to 30)
					damage_desc = "<font color='orange'>moderate[type_damage]</font>"
				if(30 to 10000)
					damage_desc = "<font color='red'>severe[type_damage]</font>"

			switch(W.hits)
				if(1 to 3)
					hits_desc = "<font color='green'>[W.hits]</font>"
				if(4 to 10)
					hits_desc = "<font color='orange'>[W.hits]</font>"
				if(11 to 10000)
					hits_desc = "<font color='red'>[W.hits]</font>"

			scan_data += "<tr>"
			scan_data += "<td>"
			scan_data += "[damage_desc]"
			scan_data += "</td>"
			scan_data += "<td>"
			scan_data += "[hits_desc]"
			scan_data += "</td>"
			scan_data += "<td>[W.time_inflicted]</td>"
			scan_data += "<td>"
			scan_data += "[W.pretend_weapon]"
			scan_data += "</td>"
			scan_data += "<td style=\"text-align:left;\">"
			scan_data += "-<font size = \"2\"><span class=\"paper_field\"></span></font>"
			scan_data += "</td>"
			scan_data += "</tr>"

		scan_data += "</table>"
		scan_data += "<br>"


	if(chemtraces.len)
		scan_data += "<b>Trace Chemicals: </b><br>"
		for(var/chemID in chemtraces)
			scan_data += chemID
			scan_data += "<br>"

	usr.visible_message("<span class='warning'>\the [src] rattles and prints out a sheet of paper.</span>")

	sleep(10)

	var/obj/item/weapon/paper/autopsy_report/P = new(usr.loc)
	P.fields = 0
	P.name = "Autopsy Data ([target_name])"
	P.info = "<tt>[scan_data]</tt>"
	P.autopsy_data = list() // Copy autopsy data for science tool
	for(var/data in organs)
		var/datum/autopsy_body_part/D = organs[data]
		for(var/tdata in D.trauma)
			var/datum/autopsy_data/W =  D.trauma[tdata]
			P.fields += 1 //we dont call needed proc, therefore var is necessary
			P.autopsy_data += W.copy()
	P.updateinfolinks()
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
		usr.update_inv_l_hand()
		usr.update_inv_r_hand()

/obj/item/weapon/autopsy_scanner/attack(mob/living/carbon/human/M, mob/living/carbon/user, def_zone)
	if(!istype(M) &!can_operate(M))
		return

	if(do_after(user,15,target = M))
		if(target_name != M.name)
			target_name = M.name
			src.organs = list()
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

		M.visible_message("<span class='warning'>[user.name] scans the wounds on [M.name]'s [BP.name] with \the [src.name]</span>")
		playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "[bicon(src)]<span class='notice'>Scanning completed!</span>")
		src.add_data(BP)
		flick("autopsy_scanning",src)
		return 1
