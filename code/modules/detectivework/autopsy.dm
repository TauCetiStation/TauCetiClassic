
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
	var/list/obj/item/organ/external/organs = list()
	var/list/datum/autopsy_data/chemtraces = list()
	var/target_name = null
	var/timeofdeath = null

/obj/item/weapon/paper/autopsy_report
	var/list/autopsy_data

/datum/autopsy_data
	var/weapon = null
	var/damage = 0
	var/type_damage = ""
	var/hits = 0
	var/time_inflicted = ""

/datum/autopsy_data/proc/copy()
	var/datum/autopsy_data/W = new()
	W.weapon = weapon
	W.damage = damage
	W.hits = hits
	W.time_inflicted = time_inflicted
	return W

/obj/item/weapon/autopsy_scanner/proc/add_data(obj/item/organ/external/BP)
	if(!BP.autopsy_data.len && !BP.trace_chemicals.len)
		return
	if(!(BP in organs))
		organs += BP

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

	for(var/organ in organs)
		var/obj/item/organ/external/BP = organ
		scan_data += "<table border=\"2\">"
		scan_data += "<tr><th colspan=\"4\">[BP.name]</th></tr>"
		scan_data += "<tr>"
		scan_data += "<th>Severity</th>"
		scan_data += "<th>Hits by weapon</th>"
		scan_data += "<th>The approximate time</th>"
		scan_data += "<th>Weapons</th>"
		scan_data += "</tr>"
		for(var/adata in BP.autopsy_data)
			var/datum/autopsy_data/W = BP.autopsy_data[adata]
			var/damage_desc = ""
			var/type_damage = ""
			var/hits_desc = ""

			if(W.type_damage == "brute")
				type_damage = " wound"
			if(W.type_damage == "burn")
				type_damage = " burn"
			if(W.type_damage == "mixed")
				type_damage = " scorched wound"
			if(W.type_damage == "bruise")
				type_damage = " bruise"

			switch(W.damage)
				if(0) //Strangled comes in here
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
			scan_data += "[W.weapon]"
			scan_data += "</td>"
			scan_data += "</tr>"

		scan_data += "<br>"

	if(chemtraces.len)
		scan_data += "<b>Trace Chemicals: </b><br>"
		for(var/chemID in chemtraces)
			scan_data += chemID
			scan_data += "<br>"

	usr.visible_message("<span class='warning'>\the [src] rattles and prints out a sheet of paper.</span>")

	sleep(10)

	var/obj/item/weapon/paper/autopsy_report/P = new(usr.loc)
	P.name = "Autopsy Data ([target_name])"
	P.info = "<tt>[scan_data]</tt>"
	P.autopsy_data = list() // Copy autopsy data for science tool
	for(var/organ in organs)
		var/obj/item/organ/external/BP = organ
		for(var/adata in BP.autopsy_data)
			var/datum/autopsy_data/W = BP.autopsy_data[adata]
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
