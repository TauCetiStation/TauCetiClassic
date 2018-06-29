var/global/list/tailoring_steps = list()

/datum/tailoring_step
	var/name                // Used to determine, which steps have been undertaken.
	var/list/tools = list() // Possible tools to accomplish this step, with their probabilities.
	var/list/quality_buff_tools = list() // The chance, that tool will buff quality(!).
	var/use_amount = 1      // If step involves an item, that can be spent, this much will be spent.
	var/min_time = 0
	var/max_time = 0
	var/quality_amplifier = 1 // By how much can this step affect quality, if it can at all.
	var/buffing_step = FALSE  // If TRUE, this step isn't counted towards the "progress", crafting steps. Such step would be armoring something up.

/datum/tailoring_step/chemistry_step // Please note, quality_buff_tools for this types are the reagents.
	tools = list(/obj/item/weapon/reagent_containers = 100)
	var/list/require_reagents = list() // Write "reagent_name" = amount

/datum/tailoring_step/chemistry_step/check_tool_buff(obj/item/I)
	for(var/A in quality_buff_tools)
		if(I.reagents.has_reagent(A, require_reagents[A]))
			I.reagents.remove_reagent(A, require_reagents[A]) // So we remove it after all the buffs.
			return quality_buff_tools[A]
	return FALSE

/datum/tailoring_step/chemistry_step/process_reagents_needed(obj/item/I)
	for(var/A in require_reagents)
		if(I.reagents.has_reagent(A, require_reagents[A]))
			return TRUE
	return FALSE

/datum/tailoring_step/proc/process_step(mob/user, obj/item/I, obj/item/stack/sheet/cloth/cloth_processed/target, custom_time = 0)
	if(!check_tool(I))
		return FALSE

	if(!process_reagents_needed(I))
		return FALSE

	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I
		if(S.amount < use_amount)
			to_chat(user, "<span class='warning'>You need more of [I] to accomplish this</span>")
			return FALSE

	if(!prob(check_tool(I)))
		user.visible_message("<span class='warning'>[user] fails horribly, while performing [name] on [target] using \his [I]</span>", "<span class='warning'>You faill horribly, while performing [name] on [target] using your [I]</span>")
		I.attack(user, user, pick(BP_CHEST, BP_GROIN, BP_L_ARM, BP_R_ARM))
		return FALSE

	user.visible_message("<span class='notice'>[user] begins [name] on [target] using \his [I]</span>", "<span class='notice'>You begin [name] on [target] using your [I]</span>")

	if(user.is_busy() || !do_after(user, rand(min_time, max_time), target = user))
		user.visible_message("<span class='warning'>[user] rips a piece of [target] while performing [name] using \his [I]</span>", "<span class='warning'>You rip a piece of [target] while performing [name] using your [I]</span>")
		target.tailoring.quality -= 1
		return FALSE

	user.visible_message("<span class='notice'>[user] finished [name] on [target] using \his [I]</span>", "<span class='notice'>You finished [name] on [target] using your [I]</span>")

	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I
		S.use(use_amount)

	return TRUE

/datum/tailoring_step/proc/step_buffs(obj/item/I, obj/item/stack/sheet/cloth/cloth_processed/target)
	if(prob(check_tool_buff(I)))
		target.tailoring.quality += quality_amplifier

/datum/tailoring_step/proc/check_tool(obj/item/I)
	for(var/T in tools)
		if(istype(I, T))
			return tools[T]
	return FALSE

/datum/tailoring_step/proc/check_tool_buff(obj/item/I)
	for(var/B in quality_buff_tools)
		if(istype(I, B))
			return quality_buff_tools[B]
	return FALSE

/datum/tailoring_step/proc/process_reagents_needed(obj/item/I)
	return TRUE

/proc/do_tailoring(mob/user, obj/item/I, obj/item/stack/sheet/cloth/cloth_processed/target)
	for(var/datum/tailoring_step/TS in tailoring_steps)
		if(!TS.process_step(user, I, target))
			continue

		target.tailoring.steps_made += TS.name

		if(!TS.buffing_step)
			target.tailoring.progress_made += TS.name

		TS.step_buffs(I, target) // All steps could possibly buff quality.

		for(var/datum/tailoring_recipe/TR in tailoring_recipes)
			if(TR.is_done(target))
				TR.create_done(target)
				return TRUE

		if(target.tailoring.steps_made.len > 8 || target.tailoring.progress_made.len > 5 || target.tailoring.quality < -10) // Hard coded limit. If a player made more than 5 steps on the cloth, turn it unprocessed.
			to_chat(user, "<span class='warning'>As you finish doing [TS.name], it seems the [target] is too garbled to keep shape. It falls apart</span>")
			var/obj/item/stack/sheet/cloth/C = new(get_turf(target), target.amount, TRUE)
			C.color = target.color
			qdel(target)
			return TRUE

		return TRUE // (sic!) It gives TRUE, if it did do the tailoring, not if it actually resulted in something.

	return FALSE

/datum/tailoring_step/cutting
	name = "cutting"
	tools = list(/obj/item/weapon/scissors = 100,
	             /obj/item/weapon/wirecutters = 100,
	             /obj/item/weapon/kitchenknife = 80,
	             /obj/item/weapon/hatchet = 60,
	             /obj/item/weapon/shard = 40)
	quality_buff_tools = list(/obj/item/weapon/scissors = 50)
	min_time = 20
	max_time = 40

/datum/tailoring_step/weaving
	name = "weaving"
	tools = list(/obj/item/stack/stringed_needle = 100,
	             /obj/item/stack/string = 80,
	             /obj/item/stack/cable_coil = 60)
	quality_buff_tools = list(/obj/item/stack/stringed_needle = 50)
	min_time = 40
	max_time = 60
	use_amount = 3

/datum/tailoring_step/needling
	name = "needling"
	tools = list(/obj/item/weapon/needle = 100,
	             /obj/item/weapon/screwdriver = 60)
	quality_buff_tools = list(/obj/item/weapon/needle = 50)
	min_time = 40
	max_time = 60

/datum/tailoring_step/knitting
	name = "knitting"
	tools = list(/obj/item/weapon/knitting_needles = 100, // Needles - knit, needle - rolls.
	             /obj/item/weapon/kitchen/utensil/fork/sticks = 80,
	             /obj/item/stack/rods = 60)
	quality_buff_tools = list(/obj/item/weapon/knitting_needles = 50)
	min_time = 20
	max_time = 40

/datum/tailoring_step/rolling
	name = "rolling"
	tools = list(/obj/item/weapon/knitting_needle = 100,
	             /obj/item/weapon/kitchen/rollingpin = 80,
	             /obj/item/weapon/crowbar = 60)
	quality_buff_tools = list(/obj/item/weapon/knitting_needle = 50)
	min_time = 20
	max_time = 40

/datum/tailoring_step/leathering
	name = "leathering"
	tools = list(/obj/item/stack/sheet/leather = 100,
	             /obj/item/stack/sheet/animalhide = 10)
	quality_buff_tools = list(/obj/item/stack/sheet/leather = 100)
	min_time = 60
	max_time = 80

/datum/tailoring_step/chemistry_step/softening
	name = "softening"
	require_reagents = list("lube" = 1,
	                        "wine" = 10,
	                        "water" = 15)
	quality_buff_tools = list("lube" = 100,
	                          "wine" = 50,
	                          "water" = 25)
	min_time = 20
	max_time = 40
	buffing_step = TRUE

/datum/tailoring_step/armoring
	name = "armoring"
	tools = list(/obj/item/stack/sheet/metal = 100,
	             /obj/item/stack/sheet/plasteel = 100,
	             /obj/item/stack/sheet/cardboard = 10)
	quality_buff_tools = list(/obj/item/stack/sheet/metal = 100,
	                          /obj/item/stack/sheet/plasteel = 80,
	                          /obj/item/stack/sheet/cardboard = 100)
	min_time = 80
	max_time = 100
	quality_amplifier = -2
	buffing_step = TRUE

/datum/tailoring_step/armoring/step_buffs(obj/item/I, obj/item/stack/sheet/cloth/cloth_processed/target)
	..()
	target.tailoring.armor_buff_modify(melee_m = rand(3, 10), bullet_m = rand(3, 10), laser_m = rand(3, 10))

/datum/tailoring_step/ragging
	name = "ragging"
	tools = list(/obj/item/stack/medical/bruise_pack = 100, // This includes the rags themselves.
	             /obj/item/weapon/reagent_containers/glass/rag = 80,
	             /obj/item/stack/tile/carpet = 60)
	quality_buff_tools = list(/obj/item/stack/medical/bruise_pack = 100,                 // A 100% chance quality will be lowered.
	                          /obj/item/weapon/reagent_containers/glass/rag = 100,
	                          /obj/item/stack/tile/carpet = 100)
	min_time = 20
	max_time = 40
	quality_amplifier = -1
	buffing_step = TRUE

/datum/tailoring_step/ragging/step_buffs(obj/item/I, obj/item/stack/sheet/cloth/cloth_processed/target)
	..()
	target.tailoring.armor_buff_modify(melee_m = rand(1, 3))