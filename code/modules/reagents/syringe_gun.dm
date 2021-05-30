


/obj/item/weapon/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon = 'icons/obj/gun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = ITEM_SIZE_NORMAL
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/list/syringes = new/list()
	var/max_syringes = 1
	m_amt = 2000
	can_suicide_with = FALSE

/obj/item/weapon/gun/syringe/examine(mob/user)
	..()
	if(src in view(2, user))
		to_chat(user, "<span class='notice'>[syringes.len] / [max_syringes] syringes.</span>")

/obj/item/weapon/gun/syringe/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I
		if(S.mode != 2)//SYRINGE_BROKEN in syringes.dm
			if(syringes.len < max_syringes)
				user.drop_from_inventory(I, src)
				syringes += I
				to_chat(user, "<span class='notice'>You put the syringe in [src].</span>")
				to_chat(user, "<span class='notice'>[syringes.len] / [max_syringes] syringes.</span>")
			else
				to_chat(usr, "<span class='warning'>[src] cannot hold more syringes.</span>")
		else
			to_chat(usr, "<span class='warning'>This syringe is broken!</span>")

	else
		return ..()

/obj/item/weapon/gun/syringe/afterattack(atom/target, mob/user, proximity, params)
	if(target == user)
		return
	..()

/obj/item/weapon/gun/syringe/can_fire()
	return syringes.len

/obj/item/weapon/gun/syringe/can_hit(mob/living/target, mob/living/user)
	return 1		//SHOOT AND LET THE GOD GUIDE IT (probably will hit a wall anyway)

/obj/item/weapon/gun/syringe/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(syringes.len)
		fire_syringe(target, user)
	else
		to_chat(usr, "<span class='warning'>[src] is empty.</span>")

/obj/item/weapon/gun/syringe/proc/fire_syringe(atom/target, mob/user)
	set waitfor = FALSE

	if (locate (/obj/structure/table, src.loc))
		return
	var/turf/trg = get_turf(target)
	var/obj/effect/syringe_gun_dummy/D = new(get_turf(src))
	var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
	if((!S) || (!S.reagents))	//ho boy! wot runtimes!
		return
	S.reagents.trans_to(D, S.reagents.total_volume)
	syringes -= S
	qdel(S)
	D.icon_state = "syringeproj"
	D.name = "syringe"
	playsound(user, 'sound/items/syringeproj.ogg', VOL_EFFECTS_MASTER)

	for(var/i = 0 to 6)
		if(!D) break
		if(D.loc == trg) break
		step_towards(D,trg)

		if(D)
			for(var/A in D.loc)
				if(isatom(A))
					var/atom/AM = A
					if(AM.density && !ismob(A))
						qdel(D)
						break
				if(!iscarbon(A))
					continue

				var/mob/living/carbon/M = A
				var/R
				if(D.reagents)
					for(var/datum/reagent/RA in D.reagents.reagent_list)
						R += RA.id + " ("
						R += num2text(RA.volume) + "),"
				M.log_combat(user, "shot with a <b>syringegun</b>")

				if(!M.check_thickmaterial(target_zone = user.zone_sel.selecting) && !M.isSynthetic(user.zone_sel.selecting))
					if(D.reagents)
						M.visible_message("<span class='danger'>[M] is hit by the syringe!</span>")
						D.reagents.trans_to(M, 15)
				else
					M.visible_message("<span class='danger'>The syringe bounces off [M]!</span>")

				qdel(D)
				break
		sleep(1)

		if (D)
			QDEL_IN(D, 10)

/obj/item/weapon/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to four syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 4


/obj/effect/syringe_gun_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "null"
	anchored = 1
	density = 0

/obj/effect/syringe_gun_dummy/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(15)
	reagents = R
	R.my_atom = src

/obj/item/weapon/gun/syringe/syndicate
	name = "dart pistol"
	desc = "A small spring-loaded sidearm that functions identically to a syringe gun."
	icon_state = "syringe_pistol"
	item_state = "gun"
	w_class = ITEM_SIZE_SMALL
	origin_tech = "combat=2;syndicate=2;biotech=3"
	force = 2
