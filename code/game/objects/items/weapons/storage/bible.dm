/obj/item/weapon/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	var/mob/affecting = null
	var/deity_name = "Christ"

/obj/item/weapon/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/weapon/storage/bible/booze/atom_init()
	. = ..()
	for (var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/food/drinks/bottle/beer(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/spacecash(src)

/obj/item/weapon/storage/bible/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		if(A.reagents && A.reagents.has_reagent("water")) //blesses/curses all the water in the holder
			var/water2convert = A.reagents.get_reagent_amount("water")
			A.reagents.del_reagent("water")
			if(icon_state == "necronomicon")
				to_chat(user, "<span class='warning'>You curse [A].</span>")
				A.reagents.add_reagent("unholywater",water2convert)
			else if(icon_state == "bible" && prob(10))
				to_chat(user, "<span clas='notice'>You have just created wine!")
				A.reagents.add_reagent("wine",water2convert)
			else
				to_chat(user, "<span class='notice'>You bless [A].</span>")
				A.reagents.add_reagent("holywater",water2convert)

/obj/item/weapon/storage/bible/attackby(obj/item/weapon/W, mob/user)
	if (src.use_sound)
		playsound(src.loc, src.use_sound, 50, 1, -5)
	..()
