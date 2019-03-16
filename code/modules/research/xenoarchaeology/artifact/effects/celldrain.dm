/datum/artifact_effect/celldrain
	effect_name = "Cell Drain"
	effect_type = EFFECT_ELECTRO

/datum/artifact_effect/celldrain/DoEffectTouch(mob/user)
	if(user)
		if(istype(user, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = user
			for(var/obj/item/weapon/stock_parts/cell/D in R.contents)
				D.charge = max(D.charge - rand() * 100, 0)
				to_chat(R, "<span class='warning'><font size='5'>SYSTEM ALERT: Energy drain detected!</font></span>")

			R.visible_message("<span class='notice'>The [R] shakes a little.</span>")

			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(3, 0, get_turf(R))
			sparks.start()
			return 1
		if(prob(40))
			var/turf/T = get_turf(holder)
			empulse(T, 1, 1)
		return 1

/datum/artifact_effect/celldrain/DoEffectItemImpact(obj/item/subjected_item)
	if(subjected_item)
		if(istype(subjected_item, /obj/item/weapon/stock_parts/cell))
			var/obj/item/weapon/stock_parts/cell/C = subjected_item
			C.charge -= rand(30, 50)
			if(holder)
				holder.visible_message(pick("<span class='notice'>The amount of energy in \the [C] suddenly falls down!</span>",
											"<span class='notice'>\The [C] suddenly drained out of power!</span>"))
			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(3, 0, get_turf(C))
			sparks.start()

/datum/artifact_effect/celldrain/DoEffectAura()
	if(holder)
		var/turf/T = get_turf(holder)

		for(var/obj/machinery/power/P in range(src.effectrange, T))
			if(istype(P, /obj/machinery/power/apc))
				for(var/obj/item/weapon/stock_parts/cell/B in P.contents)
					B.charge = max(B.charge - 50,0)
			else if(istype(P, /obj/machinery/power/smes))
				var/obj/machinery/power/smes/S = P
				S.charge = max(S.charge - 100,0)

		for(var/mob/living/silicon/robot/M in range(src.effectrange, T))
			for(var/obj/item/weapon/stock_parts/cell/D in M.contents)
				D.charge = max(D.charge - 50,0)
				to_chat(M, "<span class='warning'>SYSTEM ALERT: Energy drain detected!</span>")

		return 1

/datum/artifact_effect/celldrain/DoEffectPulse()
	if(holder)
		var/turf/T = get_turf(holder)
		for(var/obj/item/weapon/stock_parts/cell/C in range(src.effectrange, T))
			C.charge = max(C.charge - rand() * 150,0)

		for(var/obj/machinery/power/P in range(src.effectrange, T))
			if(istype(P, /obj/machinery/power/apc))
				var/apc_check = FALSE
				for(var/obj/item/weapon/stock_parts/cell/B in P.contents)
					B.charge = max(B.charge - rand() * 150,0)
					apc_check = TRUE
				if(apc_check)
					var/datum/effect/effect/system/spark_spread/sparks_apc = new /datum/effect/effect/system/spark_spread()
					sparks_apc.set_up(3, 0, get_turf(P))
					sparks_apc.start()
					P.visible_message(pick("<span class='notice'>The amount of energy in \the [P] suddenly falls down!</span>",
											"<span class='notice'>\The [P] suddenly drained out of power!</span>"))

			else if(istype(P, /obj/machinery/power/smes))
				var/obj/machinery/power/smes/S = P
				S.charge = max(S.charge - 250,0)
				var/datum/effect/effect/system/spark_spread/sparks_smes = new /datum/effect/effect/system/spark_spread()
				sparks_smes.set_up(3, 0, get_turf(S))
				sparks_smes.start()
				S.visible_message(pick("<span class='notice'>The amount of energy in \the [S] suddenly falls down!</span>",
											"<span class='notice'>\The [S] suddenly drained out of power!</span>"))

		for(var/mob/living/silicon/robot/M in range(src.effectrange, T))
			for(var/obj/item/weapon/stock_parts/cell/D in M.contents)
				D.charge = max(D.charge - rand() * 150,0)
				to_chat(M, "<span class='warning'><font size='5'>SYSTEM ALERT: Energy drain detected!</font></span>")

				M.visible_message("<span class='notice'>The [M] shakes a little.</span>")

				var/datum/effect/effect/system/spark_spread/sparks_borg = new /datum/effect/effect/system/spark_spread()
				sparks_borg.set_up(3, 0, get_turf(M))
				sparks_borg.start()
		return 1
