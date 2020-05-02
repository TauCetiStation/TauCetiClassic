#define LYING_ANIM_COOLDOWN 4

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
	buckle_delay = 0

	storage_capacity = 1

	// When we can open this again.
	var/next_open = 0

	var/image/coffin_side

/obj/structure/closet/coffin/atom_init()
	. = ..()
	coffin_side = image(icon, "coffin_side")
	coffin_side.appearance_flags |= KEEP_APART
	coffin_side.layer = MOB_LAYER + 0.1
	coffin_side.loc = src

	AddComponent(/datum/component/multi_carry, 12, /datum/carry_positions/coffin_four_man)

/obj/structure/closet/coffin/can_open()
	if(next_open > world.time)
		return FALSE
	return ..()

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
		// So nobody sees M slowly rotate into the coffin.
		M.forceMove(loc)
		buckle_mob(M)
		M.instant_vision_update(0)

/obj/structure/closet/coffin/collect_contents()
	for(var/mob/M in loc)
		if(M == buckled_mob)
			unbuckle_mob(M)
			M.forceMove(src)
			M.lying = TRUE
			M.update_transform()
			M.instant_vision_update(1, src)
			return

/obj/structure/closet/coffin/open()
	. = ..()
	if(.)
		next_open = world.time + LYING_ANIM_COOLDOWN

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
	return

/obj/structure/closet/coffin/post_buckle_mob(mob/living/M)
	if(M != buckled_mob)
		M.pixel_x = 0
		M.pixel_y = 0
		cut_overlay(coffin_side)
	else
		M.pixel_x = 1
		M.pixel_y = -1
		update_buckle_mob(M)
		cut_overlay(coffin_side)
		add_overlay(coffin_side)

/obj/structure/closet/coffin/update_buckle_mob(mob/living/M)
	coffin_side.layer = M.layer + 0.05
	M.dir = WEST
	// Is needed to update the overlay.
	cut_overlay(coffin_side)
	add_overlay(coffin_side)

/obj/structure/closet/coffin/MouseDrop_T(mob/living/M, mob/living/user)
	if(M.loc == loc && can_buckle && istype(M) && !buckled_mob && istype(user))
		user_buckle_mob(M, user)
	else
		..()

// This bootleg is here so mob in a moving coffin won't spin.
/obj/structure/closet/coffin/handle_buckled_mob_movement(newloc,direct)
	var/saved_dir = buckled_mob.dir
	. = ..()
	if(.)
		buckled_mob.dir = saved_dir

#undef LYING_ANIM_COOLDOWN
