/proc/spit_prismaline(atom/holder, atom/A, amount)
	var/datum/reagents/R = new(amount)
	R.my_atom = holder
	R.add_reagent("prismaline", amount)
	R.reaction(A, TOUCH, amount)
	qdel(R)


/datum/reagent/prismaline
	name = "Prismaline"
	id = "prismaline"
	description = "A turquoise pulsating solution of liquid crystals. Emits a low energy pressure field which consumes surrounding energy."
	reagent_state = LIQUID
	color = "#40e0d0" // rgb: 64, 224, 208
	taste_message = null

	// Screw you and your armor. It's bluespace magic, I ain't gotta explain this.
	permeability_multiplier = 10.0

/datum/reagent/prismaline/reaction_mob(mob/M, method=TOUCH, volume)
	. = ..()
	if(method != TOUCH)
		return

	M.adjust_bodytemperature(-1.0 * volume * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_COLD_DAMAGE_LIMIT - 5.0, BODYTEMP_HEAT_DAMAGE_LIMIT)

	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		R.cell_use_power(1.0 * volume)
		return

	var/datum/species/S = all_species[M.get_species()]
	if(!S)
		return
	if(!S.flags[IS_SYNTHETIC])
		return

	M.nutrition -= 1.0 * volume

/datum/reagent/prismaline/reaction_obj(obj/O, volume)
	. = ..()
	if(istype(O, /obj/mecha))
		var/obj/mecha/M = O
		M.use_power(1.0 * volume)
		return

	if(ismachinery(O))
		var/obj/machinery/M = O
		M.use_power(1.0 * volume)
		return

/datum/reagent/prismaline/on_general_digest(mob/living/M)
	..()
	var/affect_amount = min(1.0, volume)
	M.nutrition -= affect_amount

	for(var/datum/reagent/R as anything in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.id, affect_amount)
