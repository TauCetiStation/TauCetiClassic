#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
#define SYRINGE_BROKEN 2
// temp: Нужно делать undef в этом фале и снова делать дефайн в фале шприцов?

/var/list/reagentfillings_icon_cache = list()

/obj/item/weapon/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = SIZE_TINY
	var/amount_per_transfer_from_this = 5
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/list/list_reagents = null
	var/volume = 30

// For Sprays
	var/safety = FALSE
	var/triple_shot = FALSE
	var/spray_sound = 'sound/effects/spray2.ogg'
	var/volume_modifier = -6
	var/spray_size = 3
	var/chempuff_dense = TRUE // Whether the chempuff can pass through closets and such(and it should).
	var/space_cleaner = "cleaner"
	var/spray_cloud_move_delay = 3
	var/spray_cloud_react_delay = 2

// For Syrgines
	var/mode = SYRINGE_DRAW

// For Dropper
	var/filled = 0

/obj/item/weapon/reagent_containers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in range(0)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/item/weapon/reagent_containers/atom_init()
	. = ..()
	if (!possible_transfer_amounts)
		src.verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT
	var/datum/reagents/R = new/datum/reagents(volume)
	reagents = R
	R.my_atom = src
	add_initial_reagents()

/obj/item/weapon/reagent_containers/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/weapon/reagent_containers/attack_self(mob/user)
	return

/obj/item/weapon/reagent_containers/attack(mob/M, mob/user, def_zone)
	if(user.a_intent == INTENT_HARM) // Since we usually splash mobs or whatever, now we will also hit them.
		..()

#define PILLS 1
#define SPRAY 2
#define CANS 3
#define GLASS 4
#define DRINKS 5
#define SYRINGES 6
#define DROPPER 7

/obj/item/weapon/reagent_containers/afterattack(atom/target, mob/user, proximity, params)
	var/obj/item/weapon/reagent_containers/RC = src
	var/containerType = 0

	if(isextinguisher(target) && !RC.reagents.only_reagent("aqueous_foam"))
		return

	if(issyringe(RC))
		containerType = SYRINGES
	else if(ispill(RC))
		containerType = PILLS
	else if(isdrink(RC))
		containerType = DRINKS
	else if(isspray(RC))
		containerType = SPRAY
	else if(iscan(RC))
		containerType = CANS
	else if(isglass(RC))
		containerType = GLASS
	else if(isdropper(RC))
		containerType = DROPPER


	switch(containerType)
// For Pills
		if(PILLS)
			if(!proximity)
				return
			if(target.is_open_container() && target.reagents)
				if(!target.reagents.total_volume)
					to_chat(user, "<span class='warning'>[target] is empty. Cant dissolve pill.</span>")
					return
				to_chat(user, "<span class='notice'>You dissolve the pill in [target]</span>")

				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Spiked \a [target] with a pill. Reagents: [reagentlist(src)]</font>")
				msg_admin_attack("[user.name] ([user.ckey]) spiked \a [target] with a pill. Reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)])", user)

				reagents.trans_to(target, reagents.total_volume)
				user.visible_message("<span class='warning'>[user] puts something in \the [target].</span>", viewing_distance = 2)

				spawn(5)
					qdel(src)

			return

// For Spray

		if(SPRAY)
			if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack) || istype(target, /obj/structure/closet) \
			|| istype(target, /obj/item/weapon/reagent_containers) || istype(target, /obj/structure/sink) || istype(target, /obj/structure/stool/bed/chair/janitorialcart))
				return FALSE

			if(istype(target, /obj/effect/proc_holder/spell))
				return FALSE

			if(istype(target, /obj/structure/reagent_dispensers) && proximity) //this block copypasted from reagent_containers/glass, for lack of a better solution
				var/obj/structure/reagent_dispensers/RD = target
				if(!is_open_container())
					to_chat(user, "<span class='notice'>[src] can't be filled right now.</span>")
					return FALSE

				if(!RD.reagents.total_volume && RD.reagents)
					to_chat(user, "<span class='notice'>[RD] does not have enough liquids.</span>")
					return FALSE

				if(reagents.total_volume >= reagents.maximum_volume)
					to_chat(user, "<span class='notice'>\The [src] is full.</span>")
					return FALSE

				if(isextinguisher(RC) && !RD.reagents.only_reagent("aqueous_foam"))
					return FALSE

				var/trans = RD.reagents.trans_to(src, RD.amount_per_transfer_from_this)
				to_chat(user, "<span class='notice'>You fill \the [src] with [trans] units of the contents of \the [RD].</span>")
				return FALSE

			if(reagents.total_volume < amount_per_transfer_from_this)
				to_chat(user, "<span class='notice'>\The [src] is empty!</span>")
				return FALSE

			if(safety)
				to_chat(usr, "<span class = 'warning'>The safety is on!</span>")
				return FALSE

			playsound(src, spray_sound, VOL_EFFECTS_MASTER, null, FALSE, null, volume_modifier)

			if(reagents.has_reagent("sacid"))
				message_admins("[key_name_admin(user)] fired sulphuric acid from \a [src]. [ADMIN_JMP(user)]")
				log_game("[key_name(user)] fired sulphuric acid from \a [src].")
			if(reagents.has_reagent("pacid"))
				message_admins("[key_name_admin(user)] fired Polyacid from \a [src]. [ADMIN_JMP(user)]")
				log_game("[key_name(user)] fired Polyacid from \a [src].")
			if(reagents.has_reagent("lube"))
				message_admins("[key_name_admin(user)] fired Space lube from \a [src]. [ADMIN_JMP(user)]")
				log_game("[key_name(user)] fired Space lube from \a [src].")

			user.SetNextMove(CLICK_CD_INTERACT * 2)

			var/turf/T = get_turf(target) // BS12 edit, with the wall spraying.
			var/turf/T_start = get_turf(src)

			if(triple_shot && reagents.total_volume >= amount_per_transfer_from_this * 3) // If it doesn't have triple the amount of reagents, but it passed the previous check, make it shoot just one tiny spray.
				var/direction = get_dir(T_start, T)

				var/turf/T1_start = get_step(T_start, turn(direction, 90))
				var/turf/T2_start = get_step(T_start, turn(direction, -90))

				var/turf/T1 = get_step(T, turn(direction, 90))
				var/turf/T2 = get_step(T, turn(direction, -90))

				INVOKE_ASYNC(src, .proc/Spray_at, T_start, T)
				INVOKE_ASYNC(src, .proc/Spray_at, T1_start, T1)
				INVOKE_ASYNC(src, .proc/Spray_at, T2_start, T2)
			else
				INVOKE_ASYNC(src, .proc/Spray_at, T_start, T)

			INVOKE_ASYNC(src, .proc/on_spray, T, user) // A proc where we do all the dirty chair riding stuff.
			return TRUE

// For Cand

		if(CANS)
			if(!proximity)
				return
			if(!is_open_container())
				to_chat(user, "<span class='notice'>You need to open [src]!</span>")
				return

			if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.
				var/obj/structure/reagent_dispensers/RD = target
				if(!RD.reagents.total_volume)
					to_chat(user, "<span class='warning'>[RD] is empty.</span>")
					return

				if(reagents.total_volume >= reagents.maximum_volume)
					to_chat(user, "<span class='warning'>[src] is full.</span>")
					return

				var/trans = RD.reagents.trans_to(src, RD.amount_per_transfer_from_this)
				to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

			else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
				if(!reagents.total_volume)
					to_chat(user, "<span class='warning'>[src] is empty.</span>")
					return

				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					to_chat(user, "<span class='warning'>[target] is full.</span>")
					return
				var/datum/reagent/refill
				var/datum/reagent/refillName
				if(isrobot(user))
					refill = reagents.get_master_reagent_id()
					refillName = reagents.get_master_reagent_name()

				var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
				to_chat(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

				if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
					var/mob/living/silicon/robot/bro = user
					var/chargeAmount = max(30,4*trans)
					bro.cell.use(chargeAmount)
					to_chat(user, "Now synthesizing [trans] units of [refillName]...")
					addtimer(CALLBACK(src, .proc/refill_by_borg, user, refill, trans), 300)

			else if((user.a_intent == INTENT_HARM) && reagents.total_volume && istype(target, /turf/simulated))
				to_chat(user, "<span class = 'notice'>You splash the solution onto [target].</span>")
				reagents.standard_splash(target, user=user)

		if(GLASS)
			if(!is_open_container())
				to_chat(user, "<span class='notice'>You need to open [src]!</span>")
				return

			for(var/type in src.can_be_placed_into)
				if(istype(target, type))
					return

			if(ismob(target) && target.reagents && reagents.total_volume)
				to_chat(user, "<span class = 'notice'>You splash the solution onto [target].</span>")

				var/mob/living/M = target
				var/list/injected = list()
				for(var/datum/reagent/R in src.reagents.reagent_list)
					injected += R.name
				var/contained = get_english_list(injected)

				M.log_combat(user, "splashed with [name], reagents: [contained] (INTENT: [uppertext(user.a_intent)])")

				user.visible_message("<span class='rose'>[target] has been splashed with something by [user]!</span>")
				reagents.standard_splash(target, user=user)
				return

			else if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us. Or FROM us TO it.
				var/obj/structure/reagent_dispensers/T = target
				if(T.transfer_from)
					T.try_transfer(T, src, user)
				else
					T.try_transfer(src, T, user)
			else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
				if(!reagents.total_volume)
					to_chat(user, "<span class = 'rose'>[src] is empty.</span>")
					return

				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					to_chat(user, "<span class = 'rose'>[target] is full.</span>")
					return

				var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
				to_chat(user, "<span class = 'notice'>You transfer [trans] units of the solution to [target].</span>")
				playsound(src, 'sound/effects/Liquid_transfer_mono.ogg', VOL_EFFECTS_MASTER) // Sound taken from "Eris" build

			//Safety for dumping stuff into a ninja suit. It handles everything through attackby() and this is unnecessary.
			else if(istype(target, /obj/item/clothing/suit/space/space_ninja))
				return

			else if(istype(target, /obj/machinery/bunsen_burner))
				return

			else if(istype(target, /obj/machinery/smartfridge))
				return

			else if(istype(target, /obj/machinery/radiocarbon_spectrometer))
				return

			else if(istype(target, /obj/machinery/color_mixer))
				var/obj/machinery/color_mixer/CM = target
				if(CM.filling_tank_id)
					if(CM.beakers[CM.filling_tank_id])
						if(user.a_intent == INTENT_GRAB)
							var/obj/item/weapon/reagent_containers/glass/GB = CM.beakers[CM.filling_tank_id]
							GB.afterattack(src, user, proximity)
						else
							afterattack(CM.beakers[CM.filling_tank_id], user, proximity)
						CM.updateUsrDialog()
						CM.update_icon()
						return
					else
						to_chat(user, "<span class='warning'>You try to fill [user.a_intent == INTENT_GRAB ? "[src] up from a tank" : "a tank up"], but find it is absent.</span>")
						return

			else if(reagents && reagents.total_volume)
				to_chat(user, "<span class = 'notice'>You splash the solution onto [target].</span>")
				reagents.standard_splash(target, user=user)
				return

// Drinks

		if(DRINKS)
			if(!proximity)
				return
			if (!is_open_container())
				to_chat(user, "<span class='notice'>You need to open [src]!</span>")
				return
			if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.
				var/obj/structure/reagent_dispensers/RD = target

				if(!RD.reagents.total_volume)
					to_chat(user, "<span class='warning'>[RD] is empty.</span>")
					return
				if (!reagents.maximum_volume) // Locked or broken container
					to_chat(user, "<span class='warning'> [src] can't hold this.</span>")
					return
				if(reagents.total_volume >= reagents.maximum_volume)
					to_chat(user, "<span class='warning'>[src] is full.</span>")
					return

				var/trans = RD.reagents.trans_to(src, RD.amount_per_transfer_from_this)
				to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

			else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
				if(!reagents.total_volume)
					to_chat(user, "<span class='warning'>[src] is empty.</span>")
					return
				if(!target.reagents.maximum_volume)
					to_chat(user, "<span class='warning'> [target] can't hold this.</span>")
					return
				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					to_chat(user, "<span class='warning'>[target] is full.</span>")
					return

				var/datum/reagent/refill
				var/datum/reagent/refillName
				if(isrobot(user))
					refill = reagents.get_master_reagent_id()
					refillName = reagents.get_master_reagent_name()

				var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
				to_chat(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

				if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
					var/mob/living/silicon/robot/bro = user
					var/chargeAmount = max(30,4*trans)
					bro.cell.use(chargeAmount)
					to_chat(user, "Now synthesizing [trans] units of [refillName]...")
					addtimer(CALLBACK(src, .proc/refill_by_borg, user, refill, trans), 300)

			else if((user.a_intent == INTENT_HARM) && reagents.total_volume && istype(target, /turf/simulated))
				to_chat(user, "<span class = 'notice'>You splash the solution onto [target].</span>")

				reagents.standard_splash(target, user=user)

	// Syrgines

		if(SYRINGES)
			if(!proximity)
				return
			if(!target.reagents)
				return
			if(mode == SYRINGE_BROKEN)
				to_chat(user, "<span class='warning'>This syringe is broken!</span>")
				return

			if (user.a_intent == INTENT_HARM && ismob(target))
				if(user.ClumsyProbabilityCheck(50))
					target = user
				syringestab(target, user)
				return

			switch(mode)
				if(SYRINGE_DRAW)

					if(reagents.total_volume >= reagents.maximum_volume)
						to_chat(user, "<span class='warning'>The syringe is full.</span>")
						return

					if(ismob(target))//Blood!
						if(isslime(target))
							to_chat(user, "<span class='warning'>You are unable to locate any blood.</span>")
							return
						if(reagents.has_reagent("blood"))
							to_chat(user, "<span class='warning'>There is already a blood sample in this syringe</span>")
							return
						if(iscarbon(target))//maybe just add a blood reagent to all mobs. Then you can suck them dry...With hundreds of syringes. Jolly good idea.
							var/amount = src.reagents.maximum_volume - src.reagents.total_volume
							var/mob/living/carbon/T = target
							if(!T.dna)
								to_chat(usr, "You are unable to locate any blood. (To be specific, your target seems to be missing their DNA datum)")
								return
							if(NOCLONE in T.mutations) //target done been et, no more blood in him
								to_chat(user, "<span class='warning'>You are unable to locate any blood.</span>")
								return

							if(ishuman(T))
								var/mob/living/carbon/human/H = T
								if(H.species && H.species.flags[NO_BLOOD])
									H.reagents.trans_to(src,amount)
								else
									T.take_blood(src,amount)
							else
								T.take_blood(src,amount)

							infect_limb(user, target)
							user.visible_message("<span class='warning'>[user] takes a blood sample from [target].</span>", self_message = "<span class='notice'>You take a blood sample from [target]</span>", viewing_distance = 4)
							if(HAS_TRAIT_FROM(target, TRAIT_SYRINGE_FEAR, QUALITY_TRAIT))
								cause_syringe_fear(target)

					else //if not mob
						if(!target.reagents.total_volume)
							to_chat(user, "<span class='warning'>[target] is empty.</span>")
							return

						if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers) && !istype(target,/obj/item/slime_extract))
							to_chat(user, "<span class='warning'>You cannot directly remove reagents from this object.</span>")
							return

						var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

						to_chat(user, "<span class='notice'>You fill the syringe with [trans] units of the solution.</span>")
					if (reagents.total_volume >= reagents.maximum_volume)
						mode=!mode
						update_icon()

				if(SYRINGE_INJECT)
					if(!reagents.total_volume)
						to_chat(user, "<span class='warning'>The Syringe is empty.</span>")
						return
					if(istype(target, /obj/item/weapon/implantcase/chem))
						return

					if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food) && !istype(target, /obj/item/slime_extract) && !istype(target, /obj/item/clothing/mask/cigarette) && !istype(target, /obj/item/weapon/storage/fancy/cigarettes) && !istype(target, /obj/item/weapon/changeling_test))
						to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
						return
					if(target.reagents.total_volume >= target.reagents.maximum_volume)
						to_chat(user, "<span class='warning'>[target] is full.</span>")
						return

					if(isliving(target))
						var/mob/living/L = target
						var/list/injected = list()
						for(var/datum/reagent/R in src.reagents.reagent_list)
							injected += R.name
						var/contained = get_english_list(injected)
						if(target != user)

							if(!L.try_inject(user, TRUE))
								return

							var/mob/living/M = target
							infect_limb(user, target)

							M.log_combat(user, "injected with [name], reagents: [contained] (INTENT: [uppertext(user.a_intent)])")

							reagents.reaction(target, INGEST)
							if(HAS_TRAIT_FROM(target, TRAIT_SYRINGE_FEAR, QUALITY_TRAIT))
								cause_syringe_fear(target)
						else
							if(!L.try_inject(user, TRUE, TRUE))
								return
							SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "self_tending", /datum/mood_event/self_tending)
							user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to inject self ([user.ckey]). Reagents: [contained]</font>")
							reagents.reaction(target, INGEST)
							infect_limb(user, target)
					var/datum/reagent/blood/B
					for(var/datum/reagent/blood/d in src.reagents.reagent_list)
						B = d
						break
					var/trans = 5
					if(B && iscarbon(target))
						var/list/virus2 = B.data["virus2"]
						if(virus2 && virus2.len)
							message_admins("<font color='red'>Injected blood with virus to [target] by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) [ADMIN_JMP(user)]</font>",0,1)
							log_game("Injected blood with virus to [target] by [key_name(user)] in [COORD(user)]")
						var/mob/living/carbon/C = target
						C.inject_blood(src, 5)
					else
						trans = reagents.trans_to(target, amount_per_transfer_from_this)
					to_chat(user, "<span class='notice'>You inject [trans] units of the solution. The syringe now contains [src.reagents.total_volume] units.</span>")
					if(HAS_TRAIT_FROM(target, TRAIT_SYRINGE_FEAR, QUALITY_TRAIT))
						cause_syringe_fear(target)
					if (reagents.total_volume <= 0 && mode == SYRINGE_INJECT)
						mode = SYRINGE_DRAW
						update_icon()
		if(DROPPER)
			if(!target.reagents || !proximity) return

			if(filled)

				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					to_chat(user, "<span class='warning'>[target] is full.</span>")
					return

				if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food) && !istype(target, /obj/item/clothing/mask/cigarette)) //You can inject humans and food but you cant remove the shit.
					to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
					return

				var/trans = 0

				if(ismob(target))

					var/time = 20 //2/3rds the time of a syringe
					user.visible_message("<span class='warning'><B>[user] is trying to squirt something into [target]'s eyes!</B></span>")

					if(!do_mob(user, target, time)) return

					if(istype(target , /mob/living/carbon/human))
						var/mob/living/carbon/human/victim = target

						var/obj/item/safe_thing = null
						if( victim.wear_mask )
							if ( victim.wear_mask.flags & MASKCOVERSEYES )
								safe_thing = victim.wear_mask
						if( victim.head )
							if ( victim.head.flags & MASKCOVERSEYES )
								safe_thing = victim.head
						if(victim.glasses)
							if ( !safe_thing )
								safe_thing = victim.glasses

						if(safe_thing)
							if(!safe_thing.reagents)
								safe_thing.create_reagents(100)
							trans = reagents.trans_to(safe_thing, amount_per_transfer_from_this)

							user.visible_message("<span class='warning'><B>[user] tries to squirt something into [target]'s eyes, but fails!</B></span>")
							spawn(5)
								reagents.reaction(safe_thing, TOUCH)

							to_chat(user, "<span class='notice'>You transfer [trans] units of the solution.</span>")
							if (src.reagents.total_volume<=0)
								filled = 0
								icon_state = "[initial(icon_state)]"
							return

					user.visible_message("<span class='warning'><B>[user] squirts something into [target]'s eyes!</B></span>")
					reagents.reaction(target, TOUCH)

					var/mob/living/M = target

					var/list/injected = list()
					for(var/datum/reagent/R in src.reagents.reagent_list)
						injected += R.name
					var/contained = get_english_list(injected)
					M.log_combat(user, "squirted with [name], reagents: [contained]")

				trans = reagents.trans_to(target, amount_per_transfer_from_this)
				to_chat(user, "<span class='notice'>You transfer [trans] units of the solution.</span>")
				if (src.reagents.total_volume<=0)
					filled = 0
					icon_state = "[initial(icon_state)]"

			else

				if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
					to_chat(user, "<span class='warning'>You cannot directly remove reagents from [target].</span>")
					return

				if(!target.reagents.total_volume)
					to_chat(user, "<span class='warning'>[target] is empty.</span>")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)

				to_chat(user, "<span class='notice'>You fill the dropper with [trans] units of the solution.</span>")

				filled = 1
				icon_state = "[initial(icon_state)][filled]"

			return


#undef PILLS
#undef SPRAY
#undef CANS
#undef GLASS
#undef DRINKS
#undef SYRINGES
#undef DROPPER

/obj/item/weapon/reagent_containers/proc/on_spray(turf/T, mob/user)
	if(!triple_shot) // Currently only the big baddies have this mechanic.
		return

	var/movementdirection = turn(get_dir(get_turf(src), T), 180)
	if(istype(get_turf(src), /turf/simulated) && istype(user.buckled, /obj/structure/stool/bed/chair) && !user.buckled.anchored)
		var/obj/structure/stool/bed/chair/buckled_to = user.buckled
		if(!buckled_to.flipped)
			if(buckled_to)
				buckled_to.propelled = 4
			step(buckled_to, movementdirection)
			sleep(1)
			step(buckled_to, movementdirection)
			if(buckled_to)
				buckled_to.propelled = 3
			sleep(1)
			step(buckled_to, movementdirection)
			sleep(1)
			step(buckled_to, movementdirection)
			if(buckled_to)
				buckled_to.propelled = 2
			sleep(2)
			step(buckled_to, movementdirection)
			if(buckled_to)
				buckled_to.propelled = 1
			sleep(2)
			step(buckled_to, movementdirection)
			if(buckled_to)
				buckled_to.propelled = 0
			sleep(3)
			step(buckled_to, movementdirection)
			sleep(3)
			step(buckled_to, movementdirection)
			sleep(3)
			step(buckled_to, movementdirection)
	else if (loc && istype(loc, /obj/item/mecha_parts/mecha_equipment/extinguisher))
		var/obj/item/mecha_parts/mecha_equipment/extinguisher/ext = loc
		if (ext.chassis)
			ext.chassis.newtonian_move(movementdirection)
	else
		user.newtonian_move(movementdirection)


/obj/item/weapon/reagent_containers/proc/Spray_at(turf/start, turf/target)
	var/spray_size_current = spray_size // This ensures, that a player doesn't switch to another mode mid-fly.
	var/obj/effect/decal/chempuff/D = reagents.create_chempuff(amount_per_transfer_from_this, 1/spray_size, name_from_reagents = FALSE)

	if(!chempuff_dense)
		D.pass_flags |= PASSBLOB | PASSMOB | PASSCRAWL

	step_towards(D, start)
	sleep(spray_cloud_move_delay)

	var/max_steps = spray_size_current
	for(var/i in 1 to max_steps)
		step_towards(D, target)
		var/turf/T = get_turf(D)
		D.reagents.reaction(T)
		var/turf/next_T = get_step(T, get_dir(T, target))
		// When spraying against the wall, also react with the wall, but
		// not its contents. BS12
		if(next_T.density)
			D.reagents.reaction(next_T)
			sleep(spray_cloud_react_delay)
		else
			for(var/atom/A in T)
				D.reagents.reaction(A)
				sleep(spray_cloud_react_delay)
		sleep(spray_cloud_move_delay)
	qdel(D)

/obj/item/weapon/reagent_containers/proc/infect_limb(mob/living/carbon/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/target_zone = user.get_targetzone()
		var/obj/item/organ/external/BP = H.get_bodypart(target_zone)

		if (!BP)
			return
		if(crit_fail)
			BP.germ_level += germ_level / 7
		else
			BP.germ_level += min(germ_level, 3)
		H.bad_bodyparts |= BP

/obj/item/weapon/reagent_containers/proc/syringestab(mob/living/carbon/target, mob/living/carbon/user)
	if(target.try_inject(user, FALSE, TRUE))
		target.log_combat(user, "stabbed with [name] (INTENT: [uppertext(user.a_intent)])")

		if((user != target) && target.check_shields(src, 7, "the [src.name]", get_dir(user,target)))
			return

		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/target_zone = ran_zone(check_zone(user.get_targetzone(), target))
			var/obj/item/organ/external/BP = H.get_bodypart(target_zone)

			if (!BP)
				return

			var/hit_area = BP.name

			if (target != user && target.getarmor(target_zone, MELEE) > 5 && prob(50))
				visible_message("<span class='warning'><B>[user] tries to stab [target] in \the [hit_area] with [name], but the attack is deflected by armor!</B></span>")
				qdel(src)
				return
			infect_limb(user, target)
			BP.take_damage(3)
		else
			target.take_bodypart_damage(3)// 7 is the same as crowbar punch

		reagents.reaction(target, INGEST)
		var/syringestab_amount_transferred = rand(0, (reagents.total_volume - 5)) //nerfed by popular demand
		reagents.trans_to(target, syringestab_amount_transferred)

	playsound(target, 'sound/items/tools/screwdriver-stab.ogg', VOL_EFFECTS_MASTER)
	user.visible_message("<span class='warning'><B>[user] stabs [target] with [src.name]!</B></span>")

	desc += " It is broken."
	mode = SYRINGE_BROKEN
	add_blood(target)
	add_fingerprint(usr)
	update_icon()
	if(HAS_TRAIT_FROM(target, TRAIT_SYRINGE_FEAR, QUALITY_TRAIT))
		cause_syringe_fear(target)

/obj/item/weapon/reagent_containers/proc/refill_by_borg(user, refill, trans)
	reagents.add_reagent(refill, trans)
	to_chat(user, "Cyborg [src] refilled.")


/obj/item/weapon/reagent_containers/proc/reagentlist(obj/item/weapon/reagent_containers/snack) //Attack logs for regents in pills
	var/data
	if(snack.reagents.reagent_list && snack.reagents.reagent_list.len) //find a reagent list if there is and check if it has entries
		for (var/datum/reagent/R in snack.reagents.reagent_list) //no reagents will be left behind
			data += "[R.id]([R.volume] units); " //Using IDs because SOME chemicals(I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
		return data
	else return "No reagents"

/obj/item/weapon/reagent_containers/proc/show_filler_on_icon(filler_margin_y, filler_height, current_offset)
/*
	Show containers content on icon
	filler_icon_y_position - Y-indent. Array in Byond start at 1.
	filler_margin_y - height of a liquid column
*/
	if(reagents.total_volume == 0)
		underlays.Cut()
		return

	var/offset = round((reagents.total_volume / volume) * filler_height) + filler_margin_y
	if(offset == current_offset)	// If height of a liquid column isn't changed
		return current_offset

	if (offset == filler_margin_y)		// if content exist, but not it is enough to 1 pixel
		offset++		// let it will be 1 pixel

	var/icon/filler = get_filler(offset)	 // get height of a liquid column from cache or generate it

	underlays.Cut()
	underlays += filler

	current_offset = offset
	return current_offset

/obj/item/weapon/reagent_containers/proc/get_filler(offset)
/*
	Get height of a liquid column from cache or generate it
	We get 2 sprites for drawing : the transparent places of a container and pink square.
	The pink square crop a liquid column using offset.
*/
	var/cached_icon_string = "[src.icon_state]||[offset]"
	var/image/filler

	if(cached_icon_string in reagentfillings_icon_cache)
		filler = reagentfillings_icon_cache[cached_icon_string]
	else
		var/icon/I = new('icons/obj/reagentfillings.dmi',src.icon_state)		// transparent places sprite
		var/icon/cut = new('icons/obj/reagentfillings.dmi', "cut")		//  pink square sprite

		I.Blend(cut, ICON_OVERLAY, 1, offset)		// We superimpose a pink square offsetting it
		I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))		// delete pink
		reagentfillings_icon_cache[cached_icon_string] = image(I, icon_state)		// Save to cache
		filler = reagentfillings_icon_cache[cached_icon_string]

	var/list/mc = ReadRGB(mix_color_from_reagents(reagents.reagent_list))
	filler.color = RGB_CONTRAST(mc[1], mc[2], mc[3])		// paint in color of drink
	return filler

//Quality proc. Because the cyanide-syringe is not a child class of the /syringe
/obj/item/weapon/reagent_containers/proc/cause_syringe_fear(mob/living/carbon/human/user)
	to_chat(user, "<span class='userdanger'>IT'S A SYRINGE!!!</span>")
	if(prob(5))
		user.eye_blind = 20
		user.blurEyes(40)
		to_chat(user, "<span class='warning'>Darkness closes in...</span>")
	if(prob(5))
		user.hallucination = max(user.hallucination, 200)
		to_chat(user, "<span class='warning'>Ringing in your ears...</span>")
	if(prob(10))
		user.SetSleeping(40 SECONDS)
		to_chat(user, "<span class='warning'>Your will to fight wavers.</span>")
	if(prob(15))
		var/bodypart_name = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_GROIN)
		var/obj/item/organ/external/BP = user.get_bodypart(bodypart_name)
		if(BP)
			BP.take_damage(8, used_weapon = "Syringe") 	//half kithen-knife damage
			to_chat(user, "<span class='warning'>You got a cut with a syringe.</span>")
	if(prob(30))
		user.Paralyse(20)
	if(prob(40))
		user.make_dizzy(150)
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "scared", /datum/mood_event/scared)
