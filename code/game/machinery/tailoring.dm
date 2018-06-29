#define TOOL_NONE 0
#define CUTTING "cutting"
#define WEAVING "weaving"
#define NEEDLING "needling"
#define KNITTING "knitting"
#define ROLLING "rolling"
#define LEATHERING "leathering"
#define MATERIAL "material"

/obj/machinery/tailoring_machine
	name = "Tailoring Machine"
	icon = 'icons/obj/tailoring.dmi'
	icon_state = "tailoring_machine_idle"
	density = 1
	anchored = TRUE
	use_power = TRUE
	idle_power_usage = 10
	active_power_usage = 2500
	var/list/operations_queue = list()
	var/list/crash_log = list()
	var/obj/item/cutting
	var/obj/item/stack/weaving
	var/obj/item/needling
	var/obj/item/knitting
	var/obj/item/rolling
	var/obj/item/stack/leathering
	var/obj/item/stack/sheet/cloth/cloth_processed/material
	var/processing = FALSE
	var/tool_insertion = FALSE
	var/screen = 1
	var/efficiency = 0

/obj/machinery/tailoring_machine/atom_init()
	. = ..()
	cutting = new /obj/item/weapon/scissors(src)
	weaving = new /obj/item/stack/stringed_needle(src)
	needling = new /obj/item/weapon/needle(src)
	knitting = new /obj/item/weapon/knitting_needles(src)
	rolling = new /obj/item/weapon/knitting_needle(src)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/tailoring_machine(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil/random(null, 1)
	RefreshParts()

/obj/machinery/tailoring_machine/Destroy()
	QDEL_NULL(cutting)
	QDEL_NULL(weaving)
	QDEL_NULL(needling)
	QDEL_NULL(knitting)
	QDEL_NULL(rolling)
	QDEL_NULL(leathering)
	return ..()

/obj/machinery/tailoring_machine/attackby(obj/item/O, mob/user)
	if(tool_insertion)
		switch(tool_insertion)
			if(CUTTING)
				if(istype(O, /obj/item))
					user.drop_from_inventory(O, src)
					cutting = O
					tool_insertion = TOOL_NONE
			if(WEAVING)
				if(istype(O, /obj/item/stack))
					user.drop_from_inventory(O, src)
					weaving = O
					tool_insertion = TOOL_NONE
			if(NEEDLING)
				if(istype(O, /obj/item))
					user.drop_from_inventory(O, src)
					needling = O
					tool_insertion = TOOL_NONE
			if(KNITTING)
				if(istype(O, /obj/item))
					user.drop_from_inventory(O, src)
					knitting = O
					tool_insertion = TOOL_NONE
			if(ROLLING)
				if(istype(O, /obj/item))
					user.drop_from_inventory(O, src)
					rolling = O
					tool_insertion = TOOL_NONE
			if(LEATHERING)
				if(istype(O, /obj/item/stack))
					user.drop_from_inventory(O, src)
					leathering = O
					tool_insertion = TOOL_NONE
			if(MATERIAL)
				if(istype(O, /obj/item/stack/sheet/cloth/cloth_processed))
					user.drop_from_inventory(O, src)
					material = O
					tool_insertion = TOOL_NONE
		if(tool_insertion) // If it's still true, the item wasn't good enough.
			to_chat(user, "<span class='warning'>[O] can not be input as the tool into [src]!</span>")
		update_icon()
		updateUsrDialog()
		return

	else if(!processing && default_deconstruction_screwdriver(user, "tailoring_machine_idle", "tailoring_machine_idle_open", O))
		cutting.forceMove(get_turf(src))
		cutting = null
		weaving.forceMove(get_turf(src))
		weaving = null
		needling.forceMove(get_turf(src))
		needling = null
		knitting.forceMove(get_turf(src))
		knitting = null
		rolling.forceMove(get_turf(src))
		rolling = null
		leathering.forceMove(get_turf(src))
		leathering = null
		return

	else if(exchange_parts(user, O))
		return

	else if(default_unfasten_wrench(user, O))
		return

	default_deconstruction_crowbar(O)

	update_icon()

/obj/machinery/tailoring_machine/update_icon()
	if(tool_insertion)
		icon_state = "tailoring_machine_tool"
	else if(processing)
		icon_state = "tailoring_machine_work"
	else if(panel_open)
		icon_state = "tailoring_machine_idle"

/obj/machinery/tailoring_machine/RefreshParts()
	var/E = initial(efficiency)
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency += E

/obj/machinery/tailoring_machine/ui_interact(mob/user)
	var/dat
	switch(screen)
		if(1)
			if(tool_insertion)
				dat += "<div class='statusDisplay'>[src] can not be manipulated with, while it is awaiting a replacement item.</div>"
			else if(processing)
				dat += "<div class='statusDisplay'>[src] is processing! Please wait...<BR>"
				dat += "<A href='?src=\ref[src];action=stop>Force Stop</A><BR></div>"
			else
				dat += "<div class='statusDisplay'><A href='?src=\ref[src];action=process'>Start Queue Processing</A><BR>"
				dat += "<A href='?src=\ref[src];action=add_operation;operation=cutting'>Add Cutting Procedure</A><BR>"
				dat += "<A href='?src=\ref[src];action=add_operation;operation=weaving'>Add Weaving Procedure</A><BR>"
				dat += "<A href='?src=\ref[src];action=add_operation;operation=needling'>Add Needling Procedure</A><BR>"
				dat += "<A href='?src=\ref[src];action=add_operation;operation=knitting'>Add Knitting Procedure</A><BR>"
				dat += "<A href='?src=\ref[src];action=add_operation;operation=rolling'>Add Rolling Procedure</A><BR>"
				dat += "<A href='?src=\ref[src];action=add_operation;operation=leathering'>Add Leathering Procedure</A></div><BR>"
				if(operations_queue.len)
					dat += "<div class='statusDisplay'>Current Operation Queue:<BR>"
					for(var/OP in 1 to operations_queue.len)
						dat += "<A href='?src=\ref[src];action=remove_operation;operation=[OP]'>[capitalize(operations_queue[OP])]</A><BR>"
					dat += "</div><BR>"

			dat += "<div class='statusDisplay'><A href='?src=\ref[src];action=choose_parts'>Open Part Replacement Menu</A><BR>"
			dat += "<A href='?src=\ref[src];action=crash_logs'>Open Crash Logs Menu</A><BR>"
			dat += "String amount: [weaving ? weaving.get_amount() : "0"].<BR>"
			dat += "Leather amount: [leathering ? leathering.get_amount() : "0"].<BR>"
			dat += "Material amount: [material ? material.get_amount() : "0"].</div>"
		if(2)
			if(processing)
				dat += "<div class='statusDisplay'>[src] is processing! Please wait...<BR>"
				dat += "<A href='?src=\ref[src];action=stop>Force Stop</A><BR></div>"
			else if(!tool_insertion)
				dat += "<div class='statusDisplay'><A href='?src=\ref[src];action=replace;item=[CUTTING]'>[cutting ? "Replace" : "Input"] Cutting Tool[cutting ? " ([cutting])" : ""]</A><BR>"
				dat += "<A href='?src=\ref[src];action=replace;item=[WEAVING]'>[weaving ? "Replace" : "Input"] Weaving Tool[weaving ? " ([weaving])" : ""])</A><BR>"
				dat += "<A href='?src=\ref[src];action=replace;item=[NEEDLING]'>[needling ? "Replace" : "Input"] Needling Tool[needling ? " ([needling])" : ""]</A><BR>"
				dat += "<A href='?src=\ref[src];action=replace;item=[KNITTING]'>[knitting ? "Replace" : "Input"] Knitting Tool[knitting ? " ([knitting])" : ""]</A><BR>"
				dat += "<A href='?src=\ref[src];action=replace;item=[ROLLING]'>[rolling ? "Replace" : "Input"] Rolling Tool[rolling ? " ([rolling])" : ""]</A><BR>"
				dat += "<A href='?src=\ref[src];action=replace;item=[LEATHERING]'>[leathering ? "Replace" : "Input"] Leathering Tool[leathering ? " ([leathering])" : ""]</A><BR>"
				dat += "<A href='?src=\ref[src];action=replace;item=[MATERIAL]'>[material ? "Replace" : "Input"] Material[material ? " ([material])" : ""]</A></div><BR>"
			else
				dat += "<div class='statusDisplay'>[src] can not be manipulated with, while it is awaiting a replacement item.</div>"
			dat += "<div class='statusDisplay'><A href='?src=\ref[src];action=choose_operations'>Open Operating Menu</A><BR>"
			dat += "<A href='?src=\ref[src];action=crash_logs'>Open Crash Logs Menu</A><BR>"
			dat += "String amount: [weaving ? weaving.get_amount() : "0"].<BR>"
			dat += "Leather amount: [leathering ? leathering.get_amount() : "0"].<BR>"
			dat += "Material amount: [material ? material.get_amount() : "0"].</div>"
		if(3)
			if(processing)
				dat += "."
			else if(!tool_insertion)
				if(crash_log.len)
					dat += "<div class='statusDisplay'>Crash Log Entires:<BR>"
					for(var/crash in 1 to crash_log.len)
						dat += "<A href='?src=\ref[src];action=clear_log;entry=[crash]'><font color='red'>X</font></a>[crash_log[crash]]<BR>"
					dat += "</div><BR>"
			else
				dat += "<div class='statusDisplay'>[src] can not be manipulated with, while it is awaiting a replacement item.</div>"
			dat += "<div class='statusDisplay'><A href='?src=\ref[src];action=choose_operations'>Open Operating Menu</A><BR>"
			dat += "<A href='?src=\ref[src];action=choose_parts'>Open Part Replacement Menu</A><BR>"
			dat += "String amount: [weaving ? weaving.get_amount() : "0"].<BR>"
			dat += "Leather amount: [leathering ? leathering.get_amount() : "0"].<BR>"
			dat += "Material amount: [material ? material.get_amount() : "0"].</div>"

	var/datum/browser/popup = new(user, "tailoring", name, 350, 520)
	popup.set_content(dat)
	popup.open()

/obj/machinery/tailoring_machine/Topic(href, href_list)
	. = ..()
	if(!. || panel_open)
		return

	switch(href_list["action"])
		if("process")
			process_queue()
		if("choose_operations")
			screen = 1
		if("choose_parts")
			screen = 2
		if("crash_logs")
			screen = 3
		if("replace")
			switch(href_list["item"])
				if(CUTTING)
					if(cutting)
						cutting.forceMove(get_turf(src))
						cutting = null
				if(WEAVING)
					if(weaving)
						weaving.forceMove(get_turf(src))
						weaving = null
				if(NEEDLING)
					if(needling)
						needling.forceMove(get_turf(src))
						needling = null
				if(KNITTING)
					if(knitting)
						knitting.forceMove(get_turf(src))
						knitting = null
				if(ROLLING)
					if(rolling)
						rolling.forceMove(get_turf(src))
						rolling = null
				if(LEATHERING)
					if(leathering)
						leathering.forceMove(get_turf(src))
						leathering = null
				if(MATERIAL)
					if(material)
						material.forceMove(get_turf(src))
						material = null
			tool_insertion = href_list["item"]
		if("add_operation")
			if(operations_queue.len > 9)
				to_chat(usr, "<span class='notice'>[src] can not process more than 10 operations.</span>")
			else
				operations_queue += href_list["operation"]

		if("remove_operation")
			var/index = text2num(href_list["operation"])
			operations_queue.Cut(index, index + 1)
		if("clear_log")
			var/index = text2num(href_list["entry"])
			crash_log.Cut(index, index + 1)
		if("stop")
			crash_log += "\[[worldtime2text()]\]<font color='blue'>NOT #001:</font> [src] was forcefully stopped by [usr].</span>"
			processing = FALSE

	update_icon()
	updateUsrDialog()

/obj/machinery/tailoring_machine/proc/process_queue()
	if(!material)
		crash_log += "\[[worldtime2text()]\]<font color='red'>ERR #404</font>(Occured while starting process queue up)<font color='red'>:</font> Material not found.</span>"
		return

	visible_message("<span class='notice'>[src] makes a lousy boop, as it starts up.</span>")
	if(processing)
		return

	processing = TRUE
	updateUsrDialog()

	while(processing)
		for(var/OP in operations_queue)
			if(!material)
				visible_message("<span class='notice'>[src] makes a lousy beep, as it stops.</span>")
				crash_log += "\[[worldtime2text()]\]<font color='red'>ERR #404</font>(Occured while atetmpting <font color='blue'>[OP]</font>)<font color='red'>:</font> Material not found.</span>"
				processing = FALSE
				updateUsrDialog()
				return
			switch(OP)
				if("cutting")
					if(cutting)
						tailor(cutting, 20 - efficiency) // We wait for the minimal amount of time minus efficiency rating.
					else
						processing = FALSE
						crash_log += "\[[worldtime2text()]\]<font color='red'>ERR #405</font>(Occured while attempting <font color='blue'>[OP]</font>)<font color='red'>:</font> Cutting tool not found.</font>"
						visible_message("<span class='warning'>[src] emits an audible boop, as it comes to a stop.</span>")
				if("weaving")
					if(weaving)
						tailor(weaving, 40 - efficiency)
					else
						processing = FALSE
						crash_log += "\[[worldtime2text()]\]<font color='red'>ERR #406</font>(Occured while attempting <font color='blue'>[OP]</font>)<font color='red'>:</font> Weaving tool not found.</font>"
						visible_message("<span class='warning'>[src] emits an audible boop, as it comes to a stop.</span>")
				if("needling")
					if(needling)
						tailor(needling, 40 - efficiency)
					else
						processing = FALSE
						crash_log += "\[[worldtime2text()]\]<font color='red'>ERR #407</font>(Occured while attempting <font color='blue'>[OP]</font>)<font color='red'>:</font> Needling tool not found.</font>"
						visible_message("<span class='warning'>[src] emits an audible boop, as it comes to a stop.</span>")
				if("knitting")
					if(knitting)
						tailor(knitting, 20 - efficiency)
					else
						processing = FALSE
						crash_log += "\[[worldtime2text()]\]<font color='red'>ERR #408</font>(Occured while attempting <font color='blue'>[OP]</font>)<font color='red'>:</font> Knitting tool not found.</font>"
						visible_message("<span class='warning'>[src] emits an audible boop, as it comes to a stop.</span>")
				if("rolling")
					if(rolling)
						tailor(rolling, 20 - efficiency)
					else
						processing = FALSE
						crash_log += "\[[worldtime2text()]\]<font color='red'>ERR #409</font>(Occured while attempting <font color='blue'>[OP]</font>)<font color='red'>:</font> Rolling tool not found.</font>"
						visible_message("<span class='warning'>[src] emits an audible boop, as it comes to a stop.</span>")
				if("leathering")
					if(leathering)
						tailor(leathering, 60 - efficiency)
					else
						processing = FALSE
						crash_log += "\[[worldtime2text()]\]<font color='red'>ERR #410</font>(Occured while attempting <font color='blue'>[OP]</font>)<font color='red'>:</font> Leathering tool not found.</font>"
						visible_message("<span class='warning'>[src] emits an audible boop, as it comes to a stop.</span>")
			if(!processing)
				visible_message("<span class='notice'>[src] makes a lousy beep, as it stops.</span>")
				updateUsrDialog()
				return

	visible_message("<span class='notice'>[src] makes a lousy beep, as it stops.</span>")
	processing = FALSE
	updateUsrDialog()

/obj/machinery/tailoring_machine/proc/tailor(obj/item/I, time_taken = 0)
	for(var/datum/tailoring_step/TS in tailoring_steps)
		if(!TS.check_tool(I))
			continue

		if(!TS.process_reagents_needed(I))
			continue

		if(istype(I, /obj/item/stack))
			var/obj/item/stack/S = I
			if(S.amount < TS.use_amount)
				crash_log += "\[[worldtime2text()]\]<font color='red'>ERR #314</font>(Occured while attempting <font color='blue'>[TS.name]</font>)<font color='red'>:</font> Not enough [I] supplies for [TS.name].</font>"
				visible_message("<span class='warning'>[src] emits an audible boop, as it comes to a stop.</span>")
				processing = FALSE
				return

		if(!prob(TS.check_tool(I)))
			visible_message("<span class='warning'>[src] emits horrible ripping noise as it is [TS.name] on [material].</span>")
			return

		sleep(time_taken)

		if(istype(I, /obj/item/stack))
			var/obj/item/stack/S = I
			S.use(TS.use_amount)
			if(!S.get_amount())
				crash_log += "\[[worldtime2text()]\]<font color='blue'>NOT #103:</font> [src] ran out of [S], as it performed [TS.name].</span>"
			if(QDELING(S))
				if(weaving == S)
					weaving = null
				else if(leathering == S)
					leathering = null

		material.tailoring.steps_made += TS.name

		if(!TS.buffing_step)
			material.tailoring.progress_made += TS.name

		TS.step_buffs(I, material) // All steps could possibly buff quality.

		for(var/datum/tailoring_recipe/TR in tailoring_recipes)
			if(TR.is_done(material))
				TR.create_done(material)
				return

		if(material.tailoring.steps_made.len > 8 || material.tailoring.progress_made.len > 5 || material.tailoring.quality < -10) // Hard coded limit. If a player made more than 5 steps on the cloth, turn it unprocessed.
			visible_message("<span class='warning'>[src] finishes [TS.name], and as it does [material] falls apart.</span>")
			var/obj/item/stack/sheet/cloth/C = new(get_turf(material), material.amount, TRUE)
			C.color = material.color
			QDEL_NULL(material)
			processing = FALSE
			return

		return
