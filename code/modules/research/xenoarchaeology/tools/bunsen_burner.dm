
/obj/machinery/bunsen_burner
	name = "bunsen burner"
	desc = "A flat, self-heating device designed for bringing chemical mixtures to boil."
	icon = 'icons/obj/xenoarchaeology/machinery.dmi'
	icon_state = "bunsen0"
	interact_offline = TRUE
	anchored = TRUE
	var/heating = 0 // whether the bunsen is turned on
	var/heated = 0 // whether the bunsen has been on long enough to let stuff react
	var/obj/item/weapon/reagent_containers/held_container
	var/heat_time = 50

/obj/machinery/bunsen_burner/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers))
		if(held_container)
			to_chat(user, "<span class='warning'>You must remove the [held_container] first.</span>")
		else
			user.drop_item(src)
			held_container = W
			held_container.loc = src
			to_chat(user, "<span class='notice'>You put \the [held_container] onto \the [src].</span>")
			var/image/I = image("icon" = W, "layer" = FLOAT_LAYER, "pixel_y" = 13 * PIXEL_MULTIPLIER)
			var/image/I2 = image("icon" = src.icon, icon_state ="bunsen_prong", "layer" = FLOAT_LAYER)
			add_overlay(I)
			add_overlay(I2)
			if(heating)
				spawn(heat_time)
					try_heating()
	else
		to_chat(user, "<span class='warning'>You can't put the [W] onto the [src].</span>")

/obj/machinery/bunsen_burner/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()

/obj/machinery/bunsen_burner/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(!held_container)
		to_chat(user, "<span class='warning'>There is nothing on the [src].</span>")
		return 1

	cut_overlays()
	to_chat(user, "<span class='notice'>You remove the [held_container] from the [src].</span>")
	held_container.loc = src.loc
	held_container.attack_hand(user)
	held_container = null

/obj/machinery/bunsen_burner/proc/try_heating()
	src.visible_message("<span class='notice'>[bicon(src)] [src] hisses.</span>")
	if(held_container && heating)
		heated = TRUE
		if(istype(held_container, /obj/item/weapon/reagent_containers/food/snacks/meat))
			src.visible_message("<span class='notice'> [bicon(held_container)] [held_container] was successfully fried on the [src].</span>")
			new /obj/item/weapon/reagent_containers/food/snacks/meatsteak(get_turf(src))
			held_container = 0
			cut_overlays()
			return
		held_container.reagents.handle_reactions()
		heated = FALSE
		spawn(heat_time)
			try_heating()

/obj/machinery/bunsen_burner/verb/toggle()
	set src in view(1)
	set name = "Toggle bunsen burner"
	set category = "IC"

	heating = !heating
	icon_state = "bunsen[heating]"
	if(heating)
		spawn(heat_time)
			try_heating()
