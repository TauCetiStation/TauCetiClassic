//Food items that are eaten normally and don't leave anything behind.
/obj/item/weapon/reagent_containers/food/snacks/glowstick
	name = "glowstick"
	desc = ""
	w_class = 2.0
	icon = 'icons/obj/glowsticks.dmi'
	icon_state = null
	item_state = null
	icon_action_button = null	//just pull it manually, neckbeard.
	slot_flags = SLOT_BELT
	light_power = 3
	var/brightness_on = 7
	var/on = 0
	var/colourName = null
	var/eaten = 0
	var/datum/reagent/liquid_fuel

/obj/item/weapon/reagent_containers/food/snacks/glowstick/New()
	name = "[colourName] glowstick"
	desc = "A Nanotrasen issued [colourName] glowstick. There are instructions on the side, it reads 'bend it, make light'."
	icon_state = "glowstick_[colourName]"
	item_state = "glowstick_[colourName]"
	..()

/obj/item/weapon/reagent_containers/food/snacks/glowstick/process()
	liquid_fuel.volume = max(liquid_fuel.volume - 0.1, 0)
	if(liquid_fuel.volume)
		if(liquid_fuel.volume < reagents.maximum_volume/3)
			if(light_range != 3) set_light(3)
		else if(liquid_fuel.volume < reagents.maximum_volume/2)
			if(light_range != 5) set_light(5)
	if(!liquid_fuel.volume || !on)
		turn_off()
		if(!liquid_fuel.volume)
			src.icon_state = "glowstick_[colourName]-over"
		processing_objects -= src

/obj/item/weapon/reagent_containers/food/snacks/glowstick/proc/update_brightness(var/mob/user = null)
	if(on)
		icon_state = "glowstick_[colourName]-on"
		set_light(brightness_on)
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
/obj/item/weapon/reagent_containers/food/snacks/glowstick/On_Consume(var/mob/M)
	if(!usr)	return
	if(!reagents.total_volume)
		if(M == usr)
			usr << "<span class='notice'>You finish eating \the [src].</span>"
		M.visible_message("<span class='notice'>[M] finishes eating \the [src].</span>")
		usr.drop_from_inventory(src)	//so icons update :[
		del(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/glowstick/attack_self(mob/user as mob)
	// Usual checks
	if(!liquid_fuel.volume)
		user << "<span class='notice'>It's out of chemicals.</span>"
		return
	if(on)
		return

	if(!isturf(user.loc))
		user << "You cannot turn the light on while in this [user.loc]." //To prevent some lighting anomalities.
		return
	on = !on
	update_brightness(user)

	playsound(src, 'sound/weapons/glowstick_bend.ogg', 35, 0)
	user.visible_message("<span class='notice'>[user] bends the [name].</span>", "<span class='notice'>You bend the [name]!</span>")
	processing_objects += src

/obj/item/weapon/reagent_containers/food/snacks/glowstick/attack(mob/M as mob, mob/user as mob, def_zone)
	var/datum/reagent/luminophore = locate(/datum/reagent/luminophore) in reagents.reagent_list
	if(!luminophore.volume)
		user << "\red None of chemicals left in [src], oh no!"
		return 0

	if(!CanEat(user, M, src, "eat")) return	//tc code

	if(istype(M, /mob/living/carbon))
		if(M == user)								//If you're eating it yourself
			if(istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(H.species.flags & IS_SYNTHETIC)
					H << "\red You have a monitor for a head, where do you think you're going to put that?"
					return
		else
			if(istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(H.species.flags & IS_SYNTHETIC)
					H << "\red They have a monitor for a head, where do you think you're going to put that?"
					return

			if(!istype(M, /mob/living/carbon/slime))		//If you're feeding it to someone else.

				for(var/mob/O in viewers(world.view, user))
					O.show_message("\red [user] attempts to feed [M] [src].", 1)

				if(!do_mob(user, M)) return

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
				msg_admin_attack("[key_name(user)] fed [key_name(M)] with [src.name] Reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)])")

				for(var/mob/O in viewers(world.view, user))
					O.show_message("\red [user] feeds [M] [src].", 1)

			else
				user << "This creature does not seem to have a mouth!"
				return

		if(reagents)								//Handle ingestion of the reagent.
			playsound(M.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
			if(reagents.total_volume)
				var/datum/reagent/my_reagent = locate(/datum/reagent/luminophore) in reagents.reagent_list
				var/datum/reagents/list_regs = new /datum/reagents
				var/datum/reagent/luminold = new /datum/reagent/luminophore_temp
				luminold.volume = my_reagent.volume
				luminold.color = my_reagent.color
				list_regs.reagent_list += luminold

				reagents.trans_to(M, reagents.total_volume)

				var/datum/reagent/luminnew = locate(/datum/reagent/luminophore) in M.reagents.reagent_list
				if(luminnew.color == "#ffffff")
					luminnew.color = luminold.color
				list_regs.reagent_list += luminnew
				var/mixedcolor = mix_color_from_reagents(list_regs.reagent_list)
				del(list_regs)
				del(luminold)
				luminnew.color = mixedcolor
				On_Consume(M)
			return 1

	return 0

/obj/item/weapon/reagent_containers/food/snacks/glowstick/afterattack(obj/target, mob/user, proximity)
	return

/obj/item/weapon/reagent_containers/food/snacks/glowstick/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return

/obj/item/weapon/reagent_containers/food/snacks/glowstick/Del()
	if(contents)
		for(var/atom/movable/something in contents)
			something.loc = get_turf(src)
	processing_objects -= src
	..()

/obj/item/weapon/reagent_containers/food/snacks/glowstick/attack_animal(var/mob/M)
	return

/obj/item/weapon/reagent_containers/food/snacks/glowstick/proc/add_fuel()
	if(prob(95))
		src.reagents.add_reagent("luminophore", rand(18,36))
	else
		src.reagents.add_reagent("luminophore", rand(0.5,2))
	var/datum/reagents/R = reagents
	for(var/datum/reagent/luminophore/luminophore in R.reagent_list)
		if(luminophore)
			reagents.maximum_volume = luminophore.volume
			liquid_fuel = luminophore

	var/datum/reagent/lum = locate(/datum/reagent/luminophore) in R.reagent_list
	if(lum)
		if(istype(src, /obj/item/weapon/reagent_containers/food/snacks/glowstick/green))
			lum.color = "#88EBC3"
		if(istype(src, /obj/item/weapon/reagent_containers/food/snacks/glowstick/red))
			lum.color = "#EA0052"
		if(istype(src, /obj/item/weapon/reagent_containers/food/snacks/glowstick/blue))
			lum.color = "#24C1FF"
		if(istype(src, /obj/item/weapon/reagent_containers/food/snacks/glowstick/yellow))
			lum.color = "#FFFA18"
		if(istype(src, /obj/item/weapon/reagent_containers/food/snacks/glowstick/orange))
			lum.color = "#FF9318"

////////////////G L O W S T I C K - C O L O R S////////////////
/obj/item/weapon/reagent_containers/food/snacks/glowstick/green
	colourName = "green"
	light_color = "#88EBC3"
	filling_color = "#88EBC3"

	New()
		..()
		add_fuel()

/obj/item/weapon/reagent_containers/food/snacks/glowstick/red
	colourName = "red"
	light_color = "#EA0052"
	filling_color = "#EA0052"

	New()
		..()
		add_fuel()

/obj/item/weapon/reagent_containers/food/snacks/glowstick/blue
	colourName = "blue"
	light_color = "#24C1FF"
	filling_color = "#24C1FF"

	New()
		..()
		add_fuel()

/obj/item/weapon/reagent_containers/food/snacks/glowstick/yellow
	colourName = "yellow"
	light_color = "#FFFA18"
	filling_color = "#FFFA18"

	New()
		..()
		add_fuel()

/obj/item/weapon/reagent_containers/food/snacks/glowstick/orange
	colourName = "orange"
	light_color = "#FF9318"
	filling_color = "#FF9318"

	New()
		..()
		add_fuel()
