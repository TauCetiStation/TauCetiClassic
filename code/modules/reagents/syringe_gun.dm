


/obj/item/weapon/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon = 'icons/obj/gun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/list/syringes = new/list()
	var/max_syringes = 1
	m_amt = 2000

/obj/item/weapon/gun/syringe/examine(mob/user)
	..()
	if(src in view(2, user))
		to_chat(user, "<span class='notice'>[syringes.len] / [max_syringes] syringes.</span>")

/obj/item/weapon/gun/syringe/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I
		if(S.mode != 2)//SYRINGE_BROKEN in syringes.dm
			if(syringes.len < max_syringes)
				user.drop_item()
				I.loc = src
				syringes += I
				to_chat(user, "\blue You put the syringe in [src].")
				to_chat(user, "\blue [syringes.len] / [max_syringes] syringes.")
			else
				to_chat(usr, "\red [src] cannot hold more syringes.")
		else
			to_chat(usr, "\red This syringe is broken!")


/obj/item/weapon/gun/syringe/afterattack(obj/target, mob/user , flag)
	if(!isturf(target.loc) || target == user) return
	..()

/obj/item/weapon/gun/syringe/can_fire()
	return syringes.len

/obj/item/weapon/gun/syringe/can_hit(mob/living/target, mob/living/user)
	return 1		//SHOOT AND LET THE GOD GUIDE IT (probably will hit a wall anyway)

/obj/item/weapon/gun/syringe/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(syringes.len)
		fire_syringe(target, user)
	else
		to_chat(usr, "\red [src] is empty.")

/obj/item/weapon/gun/syringe/proc/fire_syringe(atom/target, mob/user)
	set waitfor = FALSE

	if (locate (/obj/structure/table, src.loc))
		return
	else
		var/turf/trg = get_turf(target)
		var/obj/effect/syringe_gun_dummy/D = new/obj/effect/syringe_gun_dummy(get_turf(src))
		var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
		if((!S) || (!S.reagents))	//ho boy! wot runtimes!
			return
		S.reagents.trans_to(D, S.reagents.total_volume)
		syringes -= S
		qdel(S)
		D.icon_state = "syringeproj"
		D.name = "syringe"
		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

		for(var/i=0, i<6, i++)
			if(!D) break
			if(D.loc == trg) break
			step_towards(D,trg)

			if(D)
				for(var/mob/living/carbon/M in D.loc)
					if(!istype(M,/mob/living/carbon)) continue
					if(M == user) continue
					//Syringe gun attack logging by Yvarov
					var/R
					if(D.reagents)
						for(var/datum/reagent/A in D.reagents.reagent_list)
							R += A.id + " ("
							R += num2text(A.volume) + "),"
					if (istype(M, /mob))
						M.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
						user.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
						msg_admin_attack("[user.name] ([user.ckey]) shot [M.name] ([M.ckey]) with a syringegun ([R]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

					else
						M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
						msg_admin_attack("UNKNOWN shot [M.name] ([M.ckey]) with a <b>syringegun</b> ([R]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

					var/mob/living/T
					if(istype(M,/mob/living))
						T = M

					M.visible_message("<span class='danger'>[M] is hit by the syringe!</span>")

					if(T && istype(T) && T.try_inject())
						if(D.reagents)
							D.reagents.trans_to(M, 15)
					else
						M.visible_message("<span class='danger'>The syringe bounces off [M]!</span>")

					qdel(D)
					break
			if(D)
				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density) qdel(D)

			sleep(1)

		if (D)
			QDEL_IN(D, 10)

		return

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
	w_class = 2
	origin_tech = "combat=2;syndicate=2;biotech=3"
	force = 2
