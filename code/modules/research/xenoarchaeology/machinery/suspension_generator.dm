/obj/machinery/suspension_gen
	name = "suspension field generator"
	desc = "It has stubby legs bolted up against it's body for stabilising."
	icon = 'icons/obj/xenoarchaeology/machinery.dmi'
	icon_state = "suspension_closed_panel"
	density = 1
	var/obj/item/weapon/stock_parts/cell/cell
	var/locked = 1
	var/open = 0
	var/screwed = 1
	var/field_type = ""
	var/power_use = 25
	var/obj/effect/suspension_field/suspension_field
	var/list/secured_mobs = list()

/obj/machinery/suspension_gen/atom_init()
	cell = new/obj/item/weapon/stock_parts/cell/high(src)
	. = ..()

/obj/machinery/suspension_gen/attackby(obj/item/weapon/W, mob/user)
	if (isscrewdriver(W))
		if(!open)
			if(screwed)
				screwed = 0
			else
				screwed = 1
			to_chat(user, "<span class='info'>You [screwed ? "screw" : "unscrew"] the battery panel.</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
	else if (iscrowbar(W))
		if(!locked)
			if(!screwed)
				if(!suspension_field)
					if(open)
						open = 0
					else
						open = 1
					to_chat(user, "<span class='info'>You crowbar the battery panel [open ? "open" : "in place"].</span>")
					playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
					icon_state = "suspension_[open ? (cell ? "cell" : "no_cell") : "closed_panel"][anchored ? "_anchored" : ""]"
				else
					to_chat(user, "<span class='warning'>[src]'s safety locks are engaged, shut it down first.</span>")
			else
				to_chat(user, "<span class='warning'>Unscrew [src]'s battery panel first.</span>")
		else
			to_chat(user, "<span class='warning'>[src]'s security locks are engaged.</span>")
	else if (iswrench(W))
		if(!suspension_field)
			if(anchored)
				anchored = 0
			else
				anchored = 1
			icon_state = "suspension_[open ? (cell ? "cell" : "no_cell") : "closed_panel"][anchored ? "_anchored" : ""]"
			to_chat(user, "<span class='info'>You wrench the stabilising legs [anchored ? "into place" : "up against the body"].</span>")
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			if(anchored)
				desc = "It is resting securely on four stubby legs."
			else
				desc = "It has stubby legs bolted up against it's body for stabilising."
		else
			to_chat(user, "<span class='warning'>You are unable to secure [src] while it is active!</span>")
	else if (istype(W, /obj/item/weapon/stock_parts/cell))
		if(open)
			if(cell)
				to_chat(user, "<span class='warning'>There is a power cell already installed.</span>")
			else
				user.drop_item()
				W.loc = src
				cell = W
				to_chat(user, "<span class='info'>You insert the power cell.</span>")
				playsound(src, 'sound/items/Screwdriver2.ogg', VOL_EFFECTS_MASTER)
				if(anchored)
					icon_state = "suspension_cell_anchored"
				else
					icon_state = "suspension_cell"
	else if(istype(W, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/sci = W
		if(access_xenoarch in sci.access)
			src.locked = !src.locked
			to_chat(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
			updateDialog()
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/machinery/suspension_gen/emag_act(mob/user)
	if(prob(75))
		src.locked = !src.locked
		to_chat(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
		updateDialog()
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	return TRUE

/obj/machinery/suspension_gen/ui_interact(mob/user)
	var/dat = "<b>Multi-phase mobile suspension field generator MK II \"Steadfast\"</b><br>"
	if(cell)
		var/colour = "red"
		if(cell.charge / cell.maxcharge > 0.66)
			colour = "green"
		else if(cell.charge / cell.maxcharge > 0.33)
			colour = "orange"
		dat += "<b>Energy cell</b>: <font color='[colour]'>[100 * cell.charge / cell.maxcharge]%</font><br>"
	else
		dat += "<b>Energy cell</b>: None<br>"
		dat += "<hr>"
	if(locked && !isobserver(user))
		dat += "<i>Swipe your ID card to begin.</i>"
	else
		dat += "Suspension field generator is: [suspension_field ? "<font color=green>Enable</font>" : "<font color=red>Disable</font>" ] <br><b><A href='?src=\ref[src];toggle_field=1'>[suspension_field ? "\[Disable field\]" : "\[Enable field\]"]</a></b><br>"
		dat += "<b>Select field mode</b><br>"
		dat += "[field_type=="carbon"?"<b>":""			]<A href='?src=\ref[src];select_field=carbon'>Diffracted carbon dioxide laser</A></b><br>"
		dat += "[field_type=="nitrogen"?"<b>":""		]<A href='?src=\ref[src];select_field=nitrogen'>Nitrogen tracer field</A></b><br>"
		dat += "[field_type=="potassium"?"<b>":""		]<A href='?src=\ref[src];select_field=potassium'>Potassium refrigerant cloud</A></b><br>"
		dat += "[field_type=="mercury"?"<b>":""	]<A href='?src=\ref[src];select_field=mercury'>Mercury dispersion wave</A></b><br>"
		dat += "[field_type=="iron"?"<b>":""		]<A href='?src=\ref[src];select_field=iron'>Iron wafer conduction field</A></b><br>"
		dat += "[field_type=="calcium"?"<b>":""	]<A href='?src=\ref[src];select_field=calcium'>Calcium binary deoxidiser</A></b><br>"
		dat += "[field_type=="chlorine"?"<b>":""	]<A href='?src=\ref[src];select_field=chlorine'>Chlorine diffusion emissions</A></b><br>"
		dat += "[field_type=="phoron"?"<b>":""	]<A href='?src=\ref[src];select_field=phoron'>Phoron saturated field</A></b><br>"
		dat += "<hr>"
		dat += "<font color='blue'><b>Always wear safety gear and consult a field manual before operation.</b></font><br>"
		dat += "<A href='?src=\ref[src];lock=1'>Lock console</A><br>"
	dat += "<hr>"
	dat += "<A href='?src=\ref[src]'> Refresh console </A><BR>"
	dat += "<A href='?src=\ref[src];close=1'> Close console </A><BR>"
	user << browse(dat, "window=suspension;size=500x400")
	onclose(user, "suspension")

/obj/machinery/suspension_gen/process()
	//set background = 1

	if (suspension_field)
		cell.charge -= power_use

		var/turf/T = get_turf(suspension_field)
		if(field_type == "carbon")
			for(var/mob/living/carbon/M in T)
				M.weakened = max(M.weakened, 3)
				cell.charge -= power_use
				if(prob(5))
					to_chat(M, "<span class='notice'>[pick("You feel tingly.","You feel like floating.","It is hard to speak.","You can barely move.")]</span>")

		if(field_type == "iron")
			for(var/mob/living/silicon/M in T)
				M.weakened = max(M.weakened, 3)
				cell.charge -= power_use
				if(prob(5))
					to_chat(M, "<span class='notice'>[pick("You feel tingly.","You feel like floating.","It is hard to speak.","You can barely move.")]</span>")

		for(var/obj/item/I in T)
			if(!suspension_field.contents.len)
				suspension_field.icon_state = "energynet"
				suspension_field.add_overlay("shield2")
			I.loc = suspension_field

		for(var/mob/living/simple_animal/M in T)
			M.weakened = max(M.weakened, 3)
			cell.charge -= power_use
			if(prob(5))
				to_chat(M, "<span class='notice'>[pick("You feel tingly.","You feel like floating.","It is hard to speak.","You can barely move.")]</span>")

		if(cell.charge <= 0)
			deactivate()

/obj/machinery/suspension_gen/is_operational_topic()
	return TRUE

/obj/machinery/suspension_gen/Topic(href, href_list)
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=suspension")
		return FALSE

	. = ..()
	if(!.)
		return

	if(locked)
		to_chat(usr, "<span class='warning'>Console locked!</span>")
		return

	if(href_list["toggle_field"])
		if(!suspension_field)
			if(cell.charge > 0)
				if(anchored)
					activate()
					playsound(src, 'sound/items/penclick.ogg', VOL_EFFECTS_MASTER)
				else
					to_chat(usr, "<span class='warning'>You are unable to activate [src] until it is properly secured on the ground.</span>")
		else
			deactivate()
	if(href_list["select_field"])
		field_type = href_list["select_field"]

	if(href_list["lock"])
		locked = 1

	updateDialog()

/obj/machinery/suspension_gen/interact(mob/user)
	if(!open)
		..()
	else if(cell)
		cell.loc = loc
		cell.add_fingerprint(user)
		cell.updateicon()

		if(anchored)
			icon_state = "suspension_no_cell_anchored"
		else
			icon_state = "suspension_no_cell"
		cell = null
		to_chat(user, "<span class='info'>You remove the power cell</span>")

//checks for whether the machine can be activated or not should already have occurred by this point
/obj/machinery/suspension_gen/proc/activate()
	//depending on the field type, we might pickup certain items
	playsound(src, 'sound/machines/defib_zap.ogg', VOL_EFFECTS_MASTER)
	var/turf/T = get_turf(get_step(src,dir))
	var/success = 0
	var/collected = 0
	switch(field_type)
		if("carbon")
			success = 1
			for(var/mob/living/carbon/C in T)
				C.weakened += 5
				C.visible_message("<span class='notice'>[bicon(C)] [C] begins to float in the air!</span>","You feel tingly and light, but it is difficult to move.")
		if("nitrogen")
			success = 1
			//
		if("mercury")
			success = 1
			//
		if("chlorine")
			success = 1
			//
		if("potassium")
			success = 1
			//
		if("phoron")
			success = 1
			//
		if("calcium")
			success = 1
			//
		if("iron")
			success = 1
			for(var/mob/living/silicon/R in T)
				R.weakened += 5
				R.visible_message("<span class='notice'>[bicon(R)] [R] begins to float in the air!</span>","You feel tingly and light, but it is difficult to move.")
			//
	//in case we have a bad field type
	if(!success)
		return

	for(var/mob/living/simple_animal/C in T)
		C.visible_message("<span class='notice'>[bicon(C)] [C] begins to float in the air!</span>","You feel tingly and light, but it is difficult to move.")
		C.weakened += 5

	suspension_field = new(T)
	suspension_field.field_type = field_type
	src.visible_message("<span class='notice'>[bicon(src)] [src] activates with a low hum.</span>")
	icon_state = "suspension_working"

	for(var/obj/item/I in T)
		I.loc = suspension_field
		collected++

	if(collected)
		suspension_field.icon_state = "energynet"
		suspension_field.add_overlay("shield2")
		src.visible_message("<span class='notice'>[bicon(suspension_field)] [suspension_field] gently absconds [collected > 1 ? "something" : "several things"].</span>")
	else
		if(istype(T,/turf/simulated/mineral) || istype(T,/turf/simulated/wall))
			suspension_field.icon_state = "shieldsparkles"
		else
			suspension_field.icon_state = "shield2"

/obj/machinery/suspension_gen/proc/deactivate()
	//drop anything we picked up
	if(suspension_field)
		var/turf/T = get_turf(suspension_field)

		for(var/mob/M in T)
			to_chat(M, "<span class='info'>You no longer feel like floating.</span>")
			M.weakened = min(M.weakened, 3)

		src.visible_message("<span class='notice'>[bicon(src)] [src] deactivates with a gentle shudder.</span>")
		qdel(suspension_field)
		suspension_field = null
		icon_state = "suspension_[open ? (cell ? "cell" : "no_cell") : "closed_panel"][anchored ? "_anchored" : ""]"

/obj/machinery/suspension_gen/Destroy()
	//safety checks: clear the field and drop anything it's holding
	deactivate()
	return ..()

/obj/machinery/suspension_gen/verb/rotate_ccw()
	set src in view(1)
	set name = "Rotate suspension gen (counter-clockwise)"
	set category = "Object"

	if(anchored)
		to_chat(usr, "<span class='warning'>You cannot rotate [src], it has been firmly fixed to the floor.</span>")
	else
		dir = turn(dir, 90)

/obj/machinery/suspension_gen/verb/rotate_cw()
	set src in view(1)
	set name = "Rotate suspension gen (clockwise)"
	set category = "Object"

	if(anchored)
		to_chat(usr, "<span class='warning'>You cannot rotate [src], it has been firmly fixed to the floor.</span>")
	else
		dir = turn(dir, -90)

/obj/effect/suspension_field
	name = "energy field"
	icon = 'icons/effects/effects.dmi'
	anchored = 1
	density = 1
	var/field_type = "chlorine"

/obj/effect/suspension_field/Destroy()
	for(var/obj/I in src)
		I.loc = src.loc
	return ..()
