/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/sleep_console
	name = "Sleeper Console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeperconsole"
	anchored = 1 //About time someone fixed this.
	density = 0
	light_color = "#7BF9FF"

/obj/machinery/sleeper
	name = "Sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper-open"
	density = 0
	anchored = 1
	var/efficiency
	state_open = 1
	var/min_health = 25
	var/list/injection_chems = list() //list of injectable chems except inaprovaline, coz inaprovaline is always avalible
	var/list/possible_chems = list(list("stoxin", "dexalin", "bicaridine", "kelotane"),
									list("stoxin", "dexalinp", "imidazoline", "dermaline", "bicaridine"),
									list("tricordrazine", "anti_toxin", "ryetalyn", "dermaline", "bicaridine", "imidazoline", "alkysine", "arithrazine"))

	var/available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "paracetamol" = "Paracetamol", "anti_toxin" = "Dylovene", "dexalin" = "Dexalin")
	var/amounts = list(5, 10)
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/filtering = 0
	light_color = "#7BF9FF"

/obj/machinery/sleeper/New()
	..()
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/sleeper(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/sleeper/allow_drop()
	return 0

/obj/machinery/sleeper/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user)|| !iscarbon(target))
		return
	close_machine(target)

/obj/machinery/sleeper/process()
	if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant
		if(filtering > 0)
			if(beaker)
				if(beaker.reagents.total_volume < beaker.reagents.maximum_volume)
					H.vessel.trans_to(beaker, 1)
					for(var/datum/reagent/x in src.occupant.reagents.reagent_list)
						H.reagents.trans_to(beaker, 3)
						H.vessel.trans_to(beaker, 1)
	return

/obj/machinery/sleeper/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
			A.blob_act()
		qdel(src)

/obj/machinery/sleeper/attack_animal(var/mob/living/simple_animal/M)//Stop putting hostile mobs in things guise
	if(M.environment_smash)
		visible_message("<span class='danger'>[M.name] smashes [src] apart!</span>")
		qdel(src)
	return

/obj/machinery/sleeper/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(!beaker)
			beaker = I
			user.drop_item()
			I.loc = src
			user.visible_message("[user] adds \a [I] to \the [src]!", "You add \a [I] to \the [src]!")
			src.updateUsrDialog()
			return
		else
			user << "\red The sleeper has a beaker already."
			return

	if(!state_open && !occupant)
		if(default_deconstruction_screwdriver(user, "sleeper-o", "sleeper", I))
			return

	if(default_change_direction_wrench(user, I))
		return

	if(exchange_parts(user, I))
		return

	default_deconstruction_crowbar(I)

/obj/machinery/sleeper/ex_act(severity)
	if(filtering)
		toggle_filter()
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
	return

/obj/machinery/sleeper/emp_act(severity)
	if(filtering)
		toggle_filter()
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..(severity)

/obj/machinery/sleeper/proc/toggle_filter()
	if(filtering)
		filtering = 0
	else
		filtering = 1

/obj/machinery/sleeper/proc/go_out()
	if(filtering)
		toggle_filter()
	if(!occupant)
		return
	for(var/atom/movable/O in src)
		if(O == beaker)
			continue
		O.loc = loc
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant = null
	icon_state = "sleeper-open"

/obj/machinery/sleeper/proc/inject_chemical(mob/living/user as mob, chemical, amount)
	if(src.occupant && src.occupant.reagents)
		if(src.occupant.reagents.get_reagent_amount(chemical) + amount <= 20)
			src.occupant.reagents.add_reagent(chemical, amount)
			user << "Occupant now has [src.occupant.reagents.get_reagent_amount(chemical)] units of [available_chemicals[chemical]] in his/her bloodstream."
			return
	user << "There's no occupant in the sleeper or the subject has too many chemicals!"
	return

/obj/machinery/sleeper/container_resist()
	open_machine()

/obj/machinery/sleeper/relaymove(var/mob/user)
	..()
	open_machine()

/obj/machinery/sleeper/Destroy()
	var/turf/T = loc
	T.contents += contents
	return ..()

/obj/machinery/sleeper/verb/remove_beaker()
	set name = "Remove Beaker"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	if(beaker)
		filtering = 0
		beaker.loc = usr.loc
		beaker = null
	add_fingerprint(usr)
	return

/obj/machinery/sleeper/attack_hand(mob/user)
	if(..())
		return
	var/dat = "<h3>Sleeper Status</h3>"

	dat += "<div class='statusDisplay'>"
	if(!occupant)
		dat += "Sleeper Unoccupied"
	else
		dat += "[occupant.name] => "
		switch(occupant.stat)	//obvious, see what their status is
			if(0)
				dat += "<span class='good'>Conscious</span>"
			if(1)
				dat += "<span class='average'>Unconscious</span>"
			else
				dat += "<span class='bad'>DEAD</span>"

		dat += "<br />"

		dat +=  "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [occupant.health]%;' class='progressFill good'></div></div><div class='statusValue'>[occupant.health]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Brute Damage:</div><div class='progressBar'><div style='width: [occupant.getBruteLoss()]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.getBruteLoss()]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Resp. Damage:</div><div class='progressBar'><div style='width: [occupant.getOxyLoss()]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.getOxyLoss()]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Toxin Content:</div><div class='progressBar'><div style='width: [occupant.getToxLoss()]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.getToxLoss()]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Burn Severity:</div><div class='progressBar'><div style='width: [occupant.getFireLoss()]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.getFireLoss()]%</div></div>"

		dat += "<HR><div class='line'><div class='statusLabel'>Paralysis Summary:</div><div class='statusValue'>[round(occupant.paralysis)]% [occupant.paralysis ? "([round(occupant.paralysis / 4)] seconds left)" : ""]</div></div>"
		dat += "<HR><div class='line'><div class='statusLabel'>Paralysis Summary:</div><div class='statusValue'>[round(occupant.paralysis)]% [occupant.paralysis ? "([round(occupant.paralysis / 4)] seconds left)" : ""]</div></div>"
		if(occupant.reagents.reagent_list.len)
			for(var/datum/reagent/R in occupant.reagents.reagent_list)
				dat += text("<div class='line'><div class='statusLabel'>[R.name]:</div><div class='statusValue'>[] units</div></div>", round(R.volume, 0.1))

	dat += "</div>"

	dat += "<A href='?src=\ref[src];refresh=1'>Scan</A>"

	dat += "<A href='?src=\ref[src];[state_open ? "close=1'>Close</A>" : "open=1'>Open</A>"]"

	dat += "<h3>Beaker</h3>"

	if(src.beaker)
		dat += "<A href='?src=\ref[src];removebeaker=1'>Remove Beaker</A>"
		if(filtering)
			dat += "<A href='?src=\ref[src];togglefilter=1'>Stop Dialysis</A>"
			dat += text("<BR>Output Beaker has [] units of free space remaining<BR><HR>", src.beaker.reagents.maximum_volume - src.beaker.reagents.total_volume)
		else
			dat += "<A href='?src=\ref[src];togglefilter=1'>Start Dialysis</A>"
			dat += text("<BR>Output Beaker has [] units of free space remaining", src.beaker.reagents.maximum_volume - src.beaker.reagents.total_volume)
	else
		dat += "<BR>No Dialysis Output Beaker is present."

	dat += "<h3>Injector</h3>"

	if(src.occupant)
		dat += "<A href='?src=\ref[src];inject=inaprovaline'>Inject Inaprovaline</A>"
	else
		dat += "<span class='linkOff'>Inject Inaprovaline</span>"
	if(occupant && occupant.health > min_health)
		for(var/re in injection_chems)
			var/datum/reagent/C = chemical_reagents_list[re]
			if(C)
				dat += "<BR><A href='?src=\ref[src];inject=[C.id]'>Inject [C.name]</A>"
	else
		for(var/re in injection_chems)
			var/datum/reagent/C = chemical_reagents_list[re]
			if(C)
				dat += "<BR><span class='linkOff'>Inject [C.name]</span>"

	var/datum/browser/popup = new(user, "sleeper", "Sleeper Console", 520, 540)	//Set up the popup browser window
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.set_content(dat)
	popup.open()

/obj/machinery/sleeper/Topic(href, href_list)
	if(..() || usr == occupant)
		return

	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["refresh"])
		updateUsrDialog()
		return
	if(href_list["open"])
		open_machine()
		return
	if(href_list["close"])
		close_machine()
		return
	if(href_list["removebeaker"])
		remove_beaker()
		updateUsrDialog()
		return
	if(href_list["togglefilter"])
		toggle_filter()
		updateUsrDialog()
		return
	if(occupant && occupant.stat != DEAD)
		if(href_list["inject"] == "inaprovaline" || occupant.health > min_health)
			inject_chem(usr, href_list["inject"])
		else
			usr << "<span class='notice'>ERROR: Subject is not in stable condition for auto-injection.</span>"
	else
		usr << "<span class='notice'>ERROR: Subject cannot metabolise chemicals.</span>"
	updateUsrDialog()

/obj/machinery/sleeper/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/sleeper/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/sleeper/open_machine()
	if(!state_open && !panel_open)
		..()
		if(beaker)
			beaker.loc = src

/obj/machinery/sleeper/close_machine(mob/target)
	if(state_open && !panel_open)
		target << "\blue <b>You feel cool air surround you. You go numb as your senses turn inward.</b>"
		..(target)

/obj/machinery/sleeper/proc/inject_chem(mob/user, chem)
	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount(chem) + 10 <= 20 * efficiency)
			occupant.reagents.add_reagent(chem, 10)
		var/units = round(occupant.reagents.get_reagent_amount(chem))
		user << "<span class='notice'>Occupant now has [units] unit\s of [chem] in their bloodstream.</span>"

/obj/machinery/sleeper/update_icon()
	if(state_open)
		icon_state = "sleeper-open"
	else
		icon_state = "sleeper"

/obj/machinery/atmospherics/components/unary/cryo_cell/can_crawl_through()
	return //can't ventcrawl in or out of cryo.
