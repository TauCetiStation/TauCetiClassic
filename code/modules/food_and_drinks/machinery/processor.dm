/obj/machinery/processor
	name = "Food Processor"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	layer = 2.9
	density = TRUE
	anchored = TRUE
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50
	var/broken = FALSE
	var/processing = FALSE
	var/rating_speed = 1
	var/rating_amount = 1

/obj/machinery/processor/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/processor(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/processor/RefreshParts()
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		rating_amount = B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		rating_speed = M.rating

/datum/food_processor_process
	var/input
	var/output
	var/time = 40

/datum/food_processor_process/proc/process_food(loc, what, obj/machinery/processor/processor)
	if (output && loc && processor)
		for(var/i = 0, i < processor.rating_amount, i++)
			new output(loc)
	if (what)
		qdel(what)

	/* objs */
/datum/food_processor_process/humanmeat
	input = /obj/item/weapon/reagent_containers/food/snacks/meat/human
	output = pick(/obj/item/weapon/reagent_containers/food/snacks/rawmeatball/human, /obj/item/weapon/reagent_containers/food/snacks/rawcutlet/human)

/datum/food_processor_process/meat
	input = /obj/item/weapon/reagent_containers/food/snacks/meat
	output = pick(/obj/item/weapon/reagent_containers/food/snacks/rawmeatball, /obj/item/weapon/reagent_containers/food/snacks/rawcutlet)

/datum/food_processor_process/meat2
	input = /obj/item/weapon/syntiflesh
	output =  = list(
		pick(/obj/item/weapon/reagent_containers/food/snacks/rawmeatball, /obj/item/weapon/reagent_containers/food/snacks/rawcutlet),
		pick(/obj/item/weapon/reagent_containers/food/snacks/rawmeatball, /obj/item/weapon/reagent_containers/food/snacks/rawcutlet),
	)

/datum/food_processor_process/potato
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/clenedpotato
	output = /obj/item/weapon/reagent_containers/food/snacks/rawsticks

/datum/food_processor_process/carrot
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	output = /obj/item/weapon/reagent_containers/food/snacks/carrotfries

/datum/food_processor_process/soybeans
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	output = /obj/item/weapon/reagent_containers/food/snacks/soydope

/datum/food_processor_process/wheat
	input = /obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	output = /obj/item/weapon/reagent_containers/food/condiment/flour

/datum/food_processor_process/macaroni
	input = /obj/item/weapon/reagent_containers/food/snacks/dough
	output = /obj/item/weapon/reagent_containers/food/snacks/macaroni

/datum/food_processor_process/spaghetti
	input = /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough
	output = /obj/item/weapon/reagent_containers/food/snacks/spaghetti

	/* mobs */
/datum/food_processor_process/mob/process_food(loc, what, processor)
	..()

//datum/food_processor_process/mob/slime/process_food(loc, what, obj/machinery/processor/processor)
//	var/mob/living/simple_animal/slime/S = what
//	var/C = S.cores
//	if(S.stat != DEAD)
//		S.loc = loc
//		S.visible_message("<span class='notice'>[C] crawls free of the processor!</span>")
//		return
//	for(var/i = 1, i <= C + processor.rating_amount, i++)
//		new S.coretype(loc)
//		feedback_add_details("slime_core_harvested","[replacetext(S.colour," ","_")]")
//	..()

/datum/food_processor_process/mob/slime
	input = /mob/living/carbon/slime
	output = /obj/item/weapon/reagent_containers/glass/beaker/slime

/datum/food_processor_process/mob/monkey
	input = /mob/living/carbon/monkey
	output = null

/datum/food_processor_process/mob/monkey/process_food(loc, what, processor)
	var/mob/living/carbon/monkey/O = what
	if (O.client) //grief-proof
		O.loc = loc
		O.visible_message("\blue Suddenly [O] jumps out from the processor!", \
				"You jump out from the processor", \
				"You hear chimp")
		return
	var/obj/item/weapon/reagent_containers/glass/bucket/bucket_of_blood = new(loc)
	var/datum/reagent/blood/B = new()
	B.holder = bucket_of_blood
	B.volume = 70
	//set reagent data
	B.data["donor"] = O

	for(var/datum/disease/D in O.viruses)
		if(D.spread_type != SPECIAL)
			B.data["viruses"] += D.Copy()

	B.data["blood_DNA"] = copytext(O.dna.unique_enzymes,1,0)
	if(O.resistances&&O.resistances.len)
		B.data["resistances"] = O.resistances.Copy()
	bucket_of_blood.reagents.reagent_list += B
	bucket_of_blood.reagents.update_total()
	bucket_of_blood.on_reagent_change()
	//bucket_of_blood.reagents.handle_reactions() //blood doesn't react
	..()



/obj/machinery/processor/proc/select_recipe(X)
	for (var/Type in typesof(/datum/food_processor_process) - /datum/food_processor_process - /datum/food_processor_process/mob)
		var/datum/food_processor_process/P = new Type()
		if (!istype(X, P.input))
			continue
		return P
	return 0

/obj/machinery/processor/attackby(obj/item/O, mob/user)
	if(processing)
		to_chat(user, "\red The processor is in the process of processing.")
		return 1
	if(default_deconstruction_screwdriver(user, "processor1", "processor", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		return

	default_deconstruction_crowbar(O)

	if(contents.len > 0) //TODO: several items at once? several different items?
		to_chat(user, "\red Something is already in the processing chamber.")
		return 1
	var/what = O
	if (istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		what = G.affecting

	var/datum/food_processor_process/P = select_recipe(what)
	if (!P)
		to_chat(user, "\red That probably won't blend.")
		return 1
	user.visible_message("[user] put [what] into [src].", \
		"You put the [what] into [src].")
	user.drop_item()
	what:loc = src
	return

/obj/machinery/processor/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(processing)
		to_chat(user, "\red The processor is in the process of processing.")
		return 1
	if(contents.len == 0)
		to_chat(user, "\red The processor is empty.")
		return 1
	user.SetNextMove(CLICK_CD_INTERACT)
	processing = TRUE
	user.visible_message("[user] turns on [src].", \
		"<span class='notice'>You turn on [src].</span>", \
		"<span class='italics'>You hear a food processor.</span>")
	playsound(loc, 'sound/machines/blender.ogg', 50, 1)
	use_power(500)
	var/total_time = 0
	for(var/O in contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor havent suitable recipe. How do you put it in?") //-rastaf0 // DEAR GOD THIS BURNS MY EYES HAVE YOU EVER LOOKED IN AN ENGLISH DICTONARY BEFORE IN YOUR LIFE AAAAAAAAAAAAAAAAAAAAA - Iamgoofball
			continue
		total_time += P.time
	sleep(total_time / rating_speed)
	for(var/O in contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor havent suitable recipe. How do you put it in?") //-rastaf0
			continue
		P.process_food(loc, O, src)
	processing = FALSE
	visible_message("\blue \the [src] finished processing.", \
		"You hear the food processor stopping/")
