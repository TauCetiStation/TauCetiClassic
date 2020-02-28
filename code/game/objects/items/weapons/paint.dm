//NEVER USE THIS IT SUX	-PETETHEGOAT

var/global/list/cached_icons = list()

/obj/item/weapon/reagent_containers/glass/paint
	desc = "It's a paint bucket."
	name = "paint bucket"
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_neutral"
	item_state = "paintcan"
	m_amt = 200
	g_amt = 0
	w_class = ITEM_SIZE_NORMAL
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10,20,30,50,70)
	volume = 70
	flags = OPENCONTAINER
	var/paint_type = ""

/obj/item/weapon/reagent_containers/glass/paint/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /turf/simulated) && reagents.total_volume > 0)
		user.visible_message("<span class='notice'>[target] has been splashed by [user] with [src].</span>", "<span class='notice'>You splash [target] with [src].</span>")
		reagents.reaction(target, TOUCH)
		reagents.remove_any(5)
		log_game("[key_name(usr)] splashed [src.reagents.get_reagents()] on [target], location ([target.x],[target.y],[target.z])")
	else 
		..()

/obj/item/weapon/reagent_containers/glass/paint/atom_init()
	if(paint_type == "remover")
		name = "paint remover bucket"
	else if(paint_type && lentext(paint_type) > 0)
		name = paint_type + " " + name
	. = ..()
	reagents.add_reagent("paint_[paint_type]", volume)

/obj/item/weapon/reagent_containers/glass/paint/on_reagent_change() //Until we have a generic "paint", this will give new colours to all paints in the can
	var/mixedcolor = mix_color_from_reagents(reagents.reagent_list)
	for(var/datum/reagent/paint/P in reagents.reagent_list)
		P.color = mixedcolor
		P.data["r_color"] = hex2num(copytext(mixedcolor, 2, 4))
		P.data["g_color"] = hex2num(copytext(mixedcolor, 4, 6))
		P.data["b_color"] = hex2num(copytext(mixedcolor, 6, 8))

/obj/item/weapon/reagent_containers/glass/paint/red
	icon_state = "paint_red"
	paint_type = "red"

/obj/item/weapon/reagent_containers/glass/paint/green
	icon_state = "paint_green"
	paint_type = "green"

/obj/item/weapon/reagent_containers/glass/paint/blue
	icon_state = "paint_blue"
	paint_type = "blue"

/obj/item/weapon/reagent_containers/glass/paint/yellow
	icon_state = "paint_yellow"
	paint_type = "yellow"

/obj/item/weapon/reagent_containers/glass/paint/violet
	icon_state = "paint_violet"
	paint_type = "violet"

/obj/item/weapon/reagent_containers/glass/paint/black
	icon_state = "paint_black"
	paint_type = "black"

/obj/item/weapon/reagent_containers/glass/paint/white
	icon_state = "paint_white"
	paint_type = "white"

/obj/item/weapon/reagent_containers/glass/paint/remover
	paint_type = "remover"

/*
/obj/item/weapon/paint
	gender= PLURAL
	name = "paint"
	desc = "Used to recolor floors and walls. Can not be removed by the janitor."
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_neutral"
	color = "FFFFFF"
	item_state = "paintcan"
	w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/paint/red
	name = "red paint"
	color = "FF0000"
	icon_state = "paint_red"

/obj/item/weapon/paint/green
	name = "green paint"
	color = "00FF00"
	icon_state = "paint_green"

/obj/item/weapon/paint/blue
	name = "blue paint"
	color = "0000FF"
	icon_state = "paint_blue"

/obj/item/weapon/paint/yellow
	name = "yellow paint"
	color = "FFFF00"
	icon_state = "paint_yellow"

/obj/item/weapon/paint/violet
	name = "violet paint"
	color = "FF00FF"
	icon_state = "paint_violet"

/obj/item/weapon/paint/black
	name = "black paint"
	color = "333333"
	icon_state = "paint_black"

/obj/item/weapon/paint/white
	name = "white paint"
	color = "FFFFFF"
	icon_state = "paint_white"


/obj/item/weapon/paint/anycolor
	gender= PLURAL
	name = "any color"
	icon_state = "paint_neutral"

/obj/item/weapon/paint/anycolor/attack_self(mob/user)
	var/t1 = input(user, "Please select a color:", "Locking Computer", null) in list( "red", "blue", "green", "yellow", "black", "white")
	if ((user.get_active_hand() != src || user.stat || user.restrained()))
		return
	switch(t1)
		if("red")
			color = "FF0000"
		if("blue")
			color = "0000FF"
		if("green")
			color = "00FF00"
		if("yellow")
			color = "FFFF00"
		if("violet")
			color = "FF00FF"
		if("white")
			color = "FFFFFF"
		if("black")
			color = "333333"
	icon_state = "paint_[t1]"
	add_fingerprint(user)
	return


/obj/item/weapon/paint/afterattack(turf/target, mob/user, proximity)
	if(!proximity) return
	if(!istype(target) || istype(target, /turf/space))
		return
	var/ind = "[initial(target.icon)][color]"
	if(!cached_icons[ind])
		var/icon/overlay = new/icon(initial(target.icon))
		overlay.Blend("#[color]",ICON_MULTIPLY)
		overlay.SetIntensity(1.4)
		target.icon = overlay
		cached_icons[ind] = target.icon
	else
		target.icon = cached_icons[ind]
	return

/obj/item/weapon/paint/paint_remover
	gender =  PLURAL
	name = "paint remover"
	icon_state = "paint_neutral"

/obj/item/weapon/paint/paint_remover/afterattack(turf/target, mob/user)
	if(istype(target) && target.icon != initial(target.icon))
		target.icon = initial(target.icon)
	return
*/
