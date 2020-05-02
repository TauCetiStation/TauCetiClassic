/obj/structure/closet/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon = 'icons/obj/structures/chapel.dmi'
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"

	anchored = FALSE

	can_buckle = TRUE
	buckle_lying = TRUE

	storage_capacity = 1

	var/image/coffin_side

/obj/structure/closet/coffin/atom_init()
	. = ..()
	coffin_side = image(icon, "coffin_side")
	coffin_side.layer = MOB_LAYER + 0.1
	coffin_side.loc = src

	AddComponent(/datum/component/multi_carry, 12, /datum/carry_positions/coffin_four_man)

/obj/structure/closet/coffin/AltClick(mob/user)
	if(user.incapacitated())
		return

	src.add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	src.toggle(user)

/obj/structure/closet/coffin/attack_hand(mob/user)
	user_unbuckle_mob(user)

/obj/structure/closet/coffin/dump_contents()
	var/mob/M = locate() in src
	if(M)
		M.forceMove(loc)
		M.instant_vision_update(0)
		buckle_mob(M)

/obj/structure/closet/coffin/collect_contents()
	for(var/mob/M in loc)
		if(M == buckled_mob)
			unbuckle_mob(M)
			M.forceMove(src)
			M.instant_vision_update(1, src)
			return

/obj/structure/closet/coffin/open()
	. = ..()
	if(.)
		icon_state = icon_opened

/obj/structure/closet/coffin/close()
	. = ..()
	if(.)
		icon_state = icon_closed

/obj/structure/closet/coffin/tools_interact(obj/item/I, mob/user)
	if(opened && iscrowbar(I))
		new /obj/item/stack/sheet/wood(loc, 5)
		visible_message("<span class='notice'>\The [src] has been disassembled apart by [user] with \the [I].</span>",
						"<span class='notice'>You hear splitting wood.</span>")
		qdel(src)
		return TRUE
	else if(!opened && isscrewdriver(I))
		user.SetNextMove(CLICK_CD_INTERACT)
		welded = !welded
		visible_message("<span class='warning'>[src] has been [welded?"screwed":"unscrewed"] by [user].</span>",
						"<span class='warning'>You hear screwing.</span>")
		return TRUE

/obj/structure/closet/coffin/correct_pixel_shift(mob/living/M)
	if(M == buckled_mob)
		M.pixel_x = 1
		M.pixel_y = -1

/obj/structure/closet/coffin/post_buckle_mob(mob/living/M)
	if(M != buckled_mob)
		M.pixel_x = 0
		M.pixel_y = 0
		cut_overlay(coffin_side)
	else
		update_buckle_mob(M)
		add_overlay(coffin_side)

/obj/structure/closet/coffin/update_buckle_mob(mob/living/M)
	coffin_side.layer = M.layer + 0.1
	M.dir = WEST

/obj/structure/closet/coffin/MouseDrop_T(mob/living/M, mob/living/user)
	if(M.loc == loc && can_buckle && istype(M) && !buckled_mob && istype(user))
		user_buckle_mob(M, user)
	else
		..()
