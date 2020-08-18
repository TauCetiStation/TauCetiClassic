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

/obj/item/weapon/reagent_containers/glass/paint/afterattack(atom/target, mob/user, proximity, params)
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
	else if(paint_type && length(paint_type) > 0)
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
