//Food items that are eaten normally and don't leave anything behind.
/obj/item/weapon/reagent_containers/food/snacks/glowstick
	name = "glowstick"
	desc = ""
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/glowsticks.dmi'
	icon_state = null
	item_state = null
	action_button_name = null	//just pull it manually, neckbeard.
	slot_flags = SLOT_FLAGS_BELT
	light_power = 2
	var/on = 0
	var/colourName = null
	var/eaten = 0
	var/datum/reagent/liquid_fuel
	var/start_brightness = 4
	action_button_name = "Break Glowstick"

/obj/item/weapon/reagent_containers/food/snacks/glowstick/atom_init()
	name = "[colourName] glowstick"
	desc = "A Nanotrasen issued [colourName] glowstick. There are instructions on the side, it reads 'bend it, make light'."
	icon_state = "glowstick_[colourName]"
	item_state = "glowstick_[colourName]"
	. = ..()
	add_fuel()

/obj/item/weapon/reagent_containers/food/snacks/glowstick/process()
	liquid_fuel.volume = max(liquid_fuel.volume - 0.1, 0)
	check_volume()
	if(!liquid_fuel.volume || !on)
		turn_off()
		if(!liquid_fuel.volume)
			src.icon_state = "glowstick_[colourName]-over"
		STOP_PROCESSING(SSobj, src)

/obj/item/weapon/reagent_containers/food/snacks/glowstick/proc/check_volume()
	if(liquid_fuel.volume)
		if(liquid_fuel.volume < reagents.maximum_volume/3)
			if(light_range == 3)
				set_light(2,1)
			return
		else if(liquid_fuel.volume < reagents.maximum_volume/2)
			if(light_range == 4)
				set_light(3)
			return

/obj/item/weapon/reagent_containers/food/snacks/glowstick/proc/update_brightness(mob/user = null)
	if(on)
		icon_state = "glowstick_[colourName]-on"
		set_light(start_brightness)
	else
		icon_state = "glowstick_[colourName]"
		set_light(0)

/obj/item/weapon/reagent_containers/food/snacks/glowstick/proc/turn_off()
	on = 0
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness(null)

	//Placeholder for effect that trigger on eating that aren't tied to reagents.
/obj/item/weapon/reagent_containers/food/snacks/glowstick/On_Consume(mob/M)
	if(!usr)	return
	if(!reagents.total_volume)
		if(M == usr)
			to_chat(usr, "<span class='notice'>You finish eating \the [src].</span>")
		M.visible_message("<span class='notice'>[M] finishes eating \the [src].</span>")
		qdel(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/glowstick/attack_self(mob/user)
	// Usual checks
	if(!liquid_fuel)	//it shouldn't happen but if it will we have save from runtime errors
		to_chat(user, "<span class='info'>[src] is defective.</span>")
		return
	if(!liquid_fuel.volume)
		to_chat(user, "<span class='notice'>It's out of chemicals.</span>")
		return
	if(on)
		return

	if(!isturf(user.loc))
		to_chat(user, "<span class='info'>You cannot turn the light on while in this [user.loc].</span>")//To prevent some lighting anomalities.
		return
	on = !on
	update_brightness(user)
	action_button_name = null
	playsound(src, 'sound/weapons/glowstick_bend.ogg', VOL_EFFECTS_MASTER, 35, FALSE)
	user.visible_message("<span class='notice'>[user] bends the [name].</span>", "<span class='notice'>You bend the [name]!</span>")
	START_PROCESSING(SSobj, src)

/obj/item/weapon/reagent_containers/food/snacks/glowstick/attack(mob/living/M, mob/user, def_zone)
	var/datum/reagent/luminophore = locate(/datum/reagent/luminophore) in reagents.reagent_list
	if(!luminophore)	//it shouldn't happen but if it will we have save from runtime errors
		to_chat(user, "<span class='info'>[src] is defective.</span>")
		return
	if(!luminophore.volume)
		to_chat(user, "<span class='rose'>None of chemicals left in [src]!</span>")
		return 0

	if(!CanEat(user, M, src, "eat")) return	//tc code

	if(istype(M, /mob/living/carbon))
		if(M == user)								//If you're eating it yourself
			if(istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(H.species.flags[IS_SYNTHETIC])
					to_chat(H, "<span class='rose'>You have a monitor for a head, where do you think you're going to put that?</span>")
					return
		else
			if(istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(H.species.flags[IS_SYNTHETIC])
					to_chat(H, "<span class='rose'>They have a monitor for a head, where do you think you're going to put that?</span>")
					return

			if(!istype(M, /mob/living/carbon/slime))		//If you're feeding it to someone else.

				user.visible_message("<span class='rose'>[user] attempts to feed [M] [src].</span>")

				if(!do_mob(user, M)) return

				M.log_combat(user, "fed [name], reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)])")

				user.visible_message("<span class='danger'>[user] feeds [M] [src].</span>")

			else
				to_chat(user, "<span class='warning'>This creature does not seem to have a mouth!</span>")
				return

		if(reagents)								//Handle ingestion of the reagent.
			playsound(M, 'sound/items/eatfood.ogg', VOL_EFFECTS_MASTER, rand(10, 50))
			if(reagents.total_volume)
				var/datum/reagent/my_reagent = locate(/datum/reagent/luminophore) in reagents.reagent_list
				var/list/list_regs = list()
				var/datum/reagent/luminold = new /datum/reagent/luminophore_temp
				luminold.volume = my_reagent.volume
				luminold.color = my_reagent.color
				list_regs += luminold

				reagents.trans_to(M, reagents.total_volume)

				var/datum/reagent/luminnew = locate(/datum/reagent/luminophore) in M.reagents.reagent_list
				if(luminnew.color == "#ffffff")
					luminnew.color = luminold.color
				list_regs += luminnew
				var/mixedcolor = mix_color_from_reagents(list_regs)
				qdel(luminold)
				luminnew.color = mixedcolor
				On_Consume(M)
			return 1

	return 0

/obj/item/weapon/reagent_containers/food/snacks/glowstick/afterattack(atom/target, mob/user, proximity, params)
	return

/obj/item/weapon/reagent_containers/food/snacks/glowstick/Destroy()
	liquid_fuel = null // as long as this is in reagent_list, no need to qdel, will be handled by parent's reagent cleaning process.
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/glowstick/attack_animal(mob/M)
	return

/obj/item/weapon/reagent_containers/food/snacks/glowstick/proc/add_fuel()
	if(prob(95))
		src.reagents.add_reagent("luminophore", rand(18,36))
	else
		src.reagents.add_reagent("luminophore", rand(1,2))
	var/datum/reagents/R = reagents
	for(var/datum/reagent/luminophore/luminophore in R.reagent_list)
		if(luminophore)
			reagents.maximum_volume = luminophore.volume
			liquid_fuel = luminophore

	var/datum/reagent/lum = locate(/datum/reagent/luminophore) in R.reagent_list
	lum.color = filling_color

////////////////G L O W S T I C K - C O L O R S////////////////
/obj/item/weapon/reagent_containers/food/snacks/glowstick/regular/green
	colourName = "green"
	light_color = "#88ebc3"
	filling_color = "#88ebc3"

/obj/item/weapon/reagent_containers/food/snacks/glowstick/regular/red
	colourName = "red"
	light_color = "#ea0052"
	filling_color = "#ea0052"

/obj/item/weapon/reagent_containers/food/snacks/glowstick/regular/blue
	colourName = "blue"
	light_color = "#24c1ff"
	filling_color = "#24c1ff"

/obj/item/weapon/reagent_containers/food/snacks/glowstick/regular/yellow
	colourName = "yellow"
	light_color = "#fffa18"
	filling_color = "#fffa18"

/obj/item/weapon/reagent_containers/food/snacks/glowstick/regular/orange
	colourName = "orange"
	light_color = "#ff9318"
	filling_color = "#ff9318"

/obj/effect/spawner/lootdrop/glowstick
	name = "random colored glowstick"
	icon = 'icons/obj/glowsticks.dmi'
	icon_state = "random_glowstick"

/obj/effect/spawner/lootdrop/glowstick/atom_init()
	loot = typesof(/obj/item/weapon/reagent_containers/food/snacks/glowstick/regular)
	. = ..()

///////////////////// POWER GLOWSTICK //////////////////////

/obj/item/weapon/reagent_containers/food/snacks/glowstick/power
	start_brightness = 7

/obj/item/weapon/reagent_containers/food/snacks/glowstick/power/atom_init()
	name = "Advanset [colourName] glowstick"
	. = ..()

/obj/item/weapon/reagent_containers/food/snacks/glowstick/power/check_volume()
	if(liquid_fuel.volume)
		if(liquid_fuel.volume < reagents.maximum_volume/3)
			if(light_range == 5)
				set_light(3)
			return
		else if(liquid_fuel.volume < reagents.maximum_volume/2)
			if(light_range == 7)
				set_light(5)
			return

/obj/item/weapon/reagent_containers/food/snacks/glowstick/power/green
	colourName = "green"
	light_color = "#88ebc3"
	filling_color = "#88ebc3"

/obj/item/weapon/reagent_containers/food/snacks/glowstick/power/red
	colourName = "red"
	light_color = "#ea0052"
	filling_color = "#ea0052"

/obj/item/weapon/reagent_containers/food/snacks/glowstick/power/blue
	colourName = "blue"
	light_color = "#24c1ff"
	filling_color = "#24c1ff"

/obj/item/weapon/reagent_containers/food/snacks/glowstick/power/yellow
	colourName = "yellow"
	light_color = "#fffa18"
	filling_color = "#fffa18"

/obj/item/weapon/reagent_containers/food/snacks/glowstick/power/orange
	colourName = "orange"
	light_color = "#ff9318"
	filling_color = "#ff9318"
