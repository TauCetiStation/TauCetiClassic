// ENERGY DRAIN PROCS

/obj/item/clothing/gloves/space_ninja/proc/drain(target, obj/suit)
	var/obj/item/clothing/suit/space/space_ninja/S = suit
	var/mob/living/carbon/human/U = S.affecting
	var/obj/item/clothing/gloves/space_ninja/G = S.n_gloves

	var/drain = 0       //To drain from battery.
	var/maxcapacity = 0 //Safety check for full battery.
	var/totaldrain = 0  //Total energy drained.

	if (istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		if (A.cell && A.cell.charge)
			var/datum/effect/effect/system/spark_spread/spark_system = new
			spark_system.set_up(5, 0, A.loc)

			G.draining = TRUE
			while (G.candrain && A.cell.charge > 0 && !maxcapacity)
				drain = rand(G.mindrain, G.maxdrain)
				if (A.cell.charge < drain)
					drain = A.cell.charge
				if (S.cell.charge + drain > S.cell.maxcharge)
					drain = S.cell.maxcharge - S.cell.charge
					maxcapacity = 1 //Reached maximum battery capacity.

				if (do_after(U, 10, target = A))
					spark_system.start()
					playsound(A, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
					A.cell.charge -= drain
					S.cell.charge += drain
					totaldrain += drain
				else
					break
			G.draining = FALSE

			to_chat(U, "<span class='notice'>Gained <B>[totaldrain]</B> energy from the APC.</span>")

			if (!A.emagged)
				flick("apc-spark", src)
				A.emagged = TRUE
				A.locked = FALSE
				A.update_icon()
		else
			to_chat(U, "<span class='warning'>This APC has run dry of power. You must find another source.</span>")

	else if (istype(target, /obj/machinery/power/smes))
		var/obj/machinery/power/smes/A = target
		if (A.charge)
			var/datum/effect/effect/system/spark_spread/spark_system = new
			spark_system.set_up(5, 0, A.loc)

			G.draining = TRUE
			while (G.candrain && A.charge > 0 && !maxcapacity)
				drain = rand(G.mindrain,G.maxdrain)
				if (A.charge < drain)
					drain = A.charge
				if (S.cell.charge + drain > S.cell.maxcharge)
					drain = S.cell.maxcharge - S.cell.charge
					maxcapacity = 1
				if (do_after(U, 10, target = A))
					spark_system.start()
					playsound(A, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
					A.charge -= drain
					S.cell.charge += drain
					totaldrain += drain
				else
					break
			G.draining = FALSE

			to_chat(U, "<span class='notice'>Gained <B>[totaldrain]</B> energy from the SMES cell.</span>")
		else
			to_chat(U, "<span class='warning'>This SMES cell has run dry of power. You must find another source.</span>")

	else if (istype(target, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/A = target
		if(A.charge)
			if (G.candrain && do_after(U, 30, target = A))
				to_chat(U, "<span class='notice'>Gained <B>[A.charge]</B> energy from the cell.</span>")

				if (S.cell.charge + A.charge > S.cell.maxcharge)
					S.cell.charge = S.cell.maxcharge
				else
					S.cell.charge += A.charge

				A.charge = 0
				A.corrupt()
				A.updateicon()
			else
				to_chat(U, "<span class='warning'>Procedure interrupted. Protocol terminated.</span>")
		else
			to_chat(U, "<span class='warning'>This cell is empty and of no use.</span>")

	else if (istype(target, /obj/machinery/computer/rdconsole) || istype(target, /obj/machinery/r_n_d/server))
		to_chat(U, "<span class='notice'>Hacking \the [target]...</span>")

		var/turf/location = get_turf(U)
		for(var/mob/living/silicon/ai/AI in ai_list)
			to_chat(AI, "<span class='warning'><b>Network Alert: Hacking attempt detected[location?" in [location]":". Unable to pinpoint location"]</b>.</span>")

		var/datum/research/files = null

		if (istype(target, /obj/machinery/computer/rdconsole))
			var/obj/machinery/computer/rdconsole/A = target
			files = A.files
		else
			var/obj/machinery/r_n_d/server/A = target
			files = A.files

		if(files && files.tech_trees.len)
			for(var/datum/tech/current_data in S.stored_research)
				to_chat(U, "<span class='notice'>Checking \the [current_data.name] database.</span>")

				if(do_after(U, S.s_delay, target = target) && G.candrain && !isnull(target))
					var/datum/tech/analyzing_data = files.tech_trees[current_data.id]
					if(analyzing_data && analyzing_data.level > current_data.level)
						to_chat(U, "<span class='notice'>Database:</span> <b>UPDATED</b>.")
						current_data.level = analyzing_data.level
				else
					break//Otherwise, quit processing.

		to_chat(U, "<span class='notice'>Data analyzed. Process finished.</span>")

	else if (istype(target, /obj/structure/cable))
		var/obj/structure/cable/A = target
		var/datum/powernet/PN = A.get_powernet()

		G.draining = TRUE
		while(G.candrain && !maxcapacity && !isnull(A))
			drain = round(rand(G.mindrain, G.maxdrain) / 2)
			var/drained = 0
			if(PN && do_after(U, 10, target = A))
				drained = min(drain, PN.avail)
				PN.newload += drained
				if (drained < drain)//if no power on net, drain apcs
					for (var/obj/machinery/power/terminal/T in PN.nodes)
						if (istype(T.master, /obj/machinery/power/apc))
							var/obj/machinery/power/apc/AP = T.master
							if (AP.operating && AP.cell && AP.cell.charge>0)
								AP.cell.charge = max(0, AP.cell.charge - 5)
								drained += 5
			else
				break
			S.cell.charge += drained
			if(S.cell.charge > S.cell.maxcharge)
				totaldrain += (drained-(S.cell.charge - S.cell.maxcharge))
				S.cell.charge = S.cell.maxcharge
				maxcapacity = 1
			else
				totaldrain += drained
			S.spark_system.start()
			if(drained == 0)
				break
		G.draining = FALSE

		to_chat(U, "<span class='notice'>Gained <B>[totaldrain]</B> energy from the power network.</span>")

	else if (istype(target, /obj/mecha))
		var/obj/mecha/A = target
		A.occupant_message("<span class='warning'>Warning: Unauthorized access through sub-route 4, block H, detected.</span>")

		if (A.get_charge())
			G.draining = TRUE
			while (G.candrain && A.cell.charge > 0 && !maxcapacity)
				drain = rand(G.mindrain, G.maxdrain)
				if (A.cell.charge < drain)
					drain = A.cell.charge
				if (S.cell.charge + drain > S.cell.maxcharge)
					drain = S.cell.maxcharge - S.cell.charge
					maxcapacity = 1
				if (do_after(U, 10, target = A))
					A.spark_system.start()
					playsound(A, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
					A.cell.use(drain)
					S.cell.charge += drain
					totaldrain += drain
				else
					break
			G.draining = FALSE

			to_chat(U, "<span class='notice'>Gained <B>[totaldrain]</B> energy from [src].</span>")
		else
			to_chat(U, "<span class='warning'>The exosuit's battery has run dry. You must find another source of power.</span>")

	else if (istype(target, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/A = target
		to_chat(A, "<span class='warning'>Warning: Unauthorized access through sub-route 12, block C, detected.</span>")

		if(A.cell && A.cell.charge)
			G.draining = TRUE
			while(G.candrain && A.cell.charge > 0 && !maxcapacity)
				drain = rand(G.mindrain, G.maxdrain)

				if(A.cell.charge < drain)
					drain = A.cell.charge

				if(S.cell.charge + drain > S.cell.maxcharge)
					drain = S.cell.maxcharge - S.cell.charge
					maxcapacity = 1

				if (do_after(U, 10, target = A))
					A.spark_system.start()
					playsound(A, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
					A.cell.charge -= drain
					S.cell.charge += drain
					totaldrain += drain
				else
					break
			G.draining = FALSE

			to_chat(U, "<span class='notice'>Gained <B>[totaldrain]</B> energy from [A].</span>")
		else
			to_chat(U, "<span class='warning'>Their battery has run dry of power. You must find another source.</span>")

	else if (istype(target, /obj/machinery)) //Can be applied to generically to all powered machinery. I'm leaving this alone for now.
		var/obj/machinery/A = target

		if (!A.powered())
			to_chat(U, "<span class='warning'>This recharger is not providing energy. You must find another source.</span>")
			return

		var/datum/effect/effect/system/spark_spread/spark_system = new
		spark_system.set_up(5, 0, A.loc)

		var/area/current_area = get_area(A)
		var/obj/machinery/power/apc/B = current_area.get_apc()

		if (!B)
			to_chat(U, "<span class='warning'>Power network could not be found. Aborting.</span>")
			return

		var/datum/powernet/PN = B.terminal.powernet

		G.draining = TRUE
		while(G.candrain && !maxcapacity && !isnull(A)) //And start a proc similar to drain from wire.
			drain = rand(G.mindrain,G.maxdrain)
			var/drained = 0

			if(PN && do_after(U, 10, target = A))
				drained = min(drain, PN.avail)
				PN.newload += drained
				if(drained < drain)//if no power on net, drain apcs
					for(var/obj/machinery/power/terminal/T in PN.nodes)
						if(istype(T.master, /obj/machinery/power/apc))
							var/obj/machinery/power/apc/AP = T.master
							if(AP.operating && AP.cell && AP.cell.charge>0)
								AP.cell.charge = max(0, AP.cell.charge - 5)
								drained += 5
			else
				break

			S.cell.charge += drained

			if(S.cell.charge>S.cell.maxcharge)
				totaldrain += (drained-(S.cell.charge-S.cell.maxcharge))
				S.cell.charge = S.cell.maxcharge
				maxcapacity = 1
			else
				totaldrain += drained

			spark_system.start()

			if(drained == 0)
				break
		G.draining = FALSE

		to_chat(U, "<span class='notice'>Gained <B>[totaldrain]</B> energy from the power network.</span>")
