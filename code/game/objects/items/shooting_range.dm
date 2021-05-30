// Targets, the things that actually get shot!
/obj/item/target
	name = "shooting target"
	desc = "A shooting target."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_h"
	density = 0
	var/hp = 1800

/obj/item/target/Destroy()
	// if a target is deleted and associated with a stake, force stake to forget
	for(var/obj/structure/target_stake/T in view(3,src))
		if(T.pinned_target == src)
			T.pinned_target = null
			T.density = 1
			break
	return ..() // delete target

/obj/item/target/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	// After target moves, check for nearby stakes. If associated, move to target
	for(var/obj/structure/target_stake/M in view(3,src))
		if(M.density == 0 && M.pinned_target == src)
			M.loc = loc

	// This may seem a little counter-intuitive but I assure you that's for a purpose.
	// Stakes are the ones that carry targets, yes, but in the stake code we set
	// a stake's density to 0 meaning it can't be pushed anymore. Instead of pushing
	// the stake now, we have to push the target.



/obj/item/target/attackby(obj/item/I, mob/user, params)
	if(iswelder(I))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.use(0, user))
			cut_overlays()
			to_chat(usr, "<span class='notice'>You slice off [src]'s uneven chunks of aluminum and scorch marks.</span>")
			return
	else
		return ..()


/obj/item/target/attack_hand(mob/user)
	// taking pinned targets off!
	var/obj/structure/target_stake/stake
	for(var/obj/structure/target_stake/T in view(3,src))
		if(T.pinned_target == src)
			stake = T
			break

	if(stake)
		if(stake.pinned_target)
			stake.density = 1
			density = 0
			layer = OBJ_LAYER

			loc = user.loc
			if(ishuman(user))
				if(!user.get_active_hand())
					user.put_in_hands(src)
					to_chat(user, "<span class='notice'>You take the target out of the stake.</span>")
			else
				src.loc = get_turf_loc(user)
				to_chat(user, "<span class='notice'>You take the target out of the stake.</span>")

			stake.pinned_target = null
			return

	else
		..()

/obj/item/target/syndicate
	icon_state = "target_s"
	desc = "A shooting target that looks like a hostile agent."
	hp = 2600 // i guess syndie targets are sturdier?

/obj/item/target/alien
	icon_state = "target_q"
	desc = "A shooting target with a threatening silhouette."
	hp = 2350 // alium onest too kinda

/obj/item/target/bullet_act(obj/item/projectile/Proj)
	hp -= Proj.damage
	if(hp <= 0)
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				to_chat(O, "<span class='rose'>[src] breaks into tiny pieces and collapses!</span>")
		qdel(src)

