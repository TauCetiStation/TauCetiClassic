var/global/list/possible_gifts = list()

/obj/item/weapon/god_gift
	name = "God gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/new_year_gift.dmi'
	icon_state = "gift"
	item_state = "gift"

/obj/item/weapon/god_gift/atom_init()
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)

/obj/item/weapon/god_gift/ex_act()
	qdel(src)

/obj/item/weapon/god_gift/attack_self(mob/M)
	if(!global.possible_gifts.len)
		var/list/gift_types_list = subtypesof(/obj/item)
		for(var/obj/item/I as anything in gift_types_list)
			if(I.flags & ABSTRACT)
				gift_types_list -= I
			if(!initial(I.icon_state))
				gift_types_list -= I
		global.possible_gifts = gift_types_list

	var/gift_type = pick(global.possible_gifts)
	var/obj/item/I = new gift_type(M)
	M.remove_from_mob(src)
	M.put_in_hands(I)
	playsound(src, 'sound/items/misc/juskiddink_bell-jingle.ogg', VOL_EFFECTS_MASTER)
	to_chat(M, "<span class='notice'>Looks like it was from Santa!</span>")
	qdel(src)

/obj/effect/proc_holder/spell/no_target/god_gift
	name = "Make a Gift"
	desc = "Happy New Year!"

	charge_max = 2 MINUTES
	favor_cost = 100
	divine_power = 1

	clothes_req = FALSE

	action_icon_state = "spawn_bible"
	sound = 'sound/items/misc/jcookvoice_old-timey-magic.ogg'

/obj/effect/proc_holder/spell/no_target/god_gift/cast(list/targets, mob/user = usr)
	var/turf/spawn_turf = get_turf(user)

	for(var/mob/living/carbon/human/M in viewers(spawn_turf, world.view))
		if(M.mind)
			M.flash_eyes()

	new /obj/item/weapon/god_gift(spawn_turf)
