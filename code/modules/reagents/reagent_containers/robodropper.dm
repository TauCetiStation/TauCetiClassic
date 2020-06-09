
/obj/item/weapon/reagent_containers/robodropper
	name = "Industrial Dropper"
	desc = "A larger dropper. Transfers 10 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dropper"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,3,4,5,6,7,8,9,10)
	volume = 10
	var/filled = 0

/obj/item/weapon/reagent_containers/robodropper/afterattack(atom/target, mob/user, proximity, params)
	if(!target.reagents) return

	if(filled)

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food)) //You can inject humans and food but you cant remove the shit.
			to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
			return


		var/trans = 0

		if(isliving(target))
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
					trans = src.reagents.trans_to(safe_thing, amount_per_transfer_from_this)

					user.visible_message("<span class='warning'><B>[user] tries to squirt something into [target]'s eyes, but fails!</B></span>")
					spawn(5)
						src.reagents.reaction(safe_thing, TOUCH)


					to_chat(user, "<span class='notice'>You transfer [trans] units of the solution.</span>")
					if (src.reagents.total_volume<=0)
						filled = 0
						icon_state = "dropper[filled]"
					return


			user.visible_message("<span class='warning'><B>[user] squirts something into [target]'s eyes!</B></span>")
			src.reagents.reaction(target, TOUCH)

			var/mob/living/M = target
			var/list/injected = list()
			for(var/datum/reagent/R in src.reagents.reagent_list)
				injected += R.name
			var/contained = english_list(injected)

			M.log_combat(user, "squirted with [name], reagents: [contained] (INTENT: [uppertext(user.a_intent)])")

		trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the solution.</span>")
		if (src.reagents.total_volume<=0)
			filled = 0
			icon_state = "dropper"

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
		icon_state = "dropper[filled]"

	return
