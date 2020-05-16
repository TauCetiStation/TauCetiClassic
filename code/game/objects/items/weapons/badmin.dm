/* PEDAL BAG */

/obj/item/weapon/pedalbag
	name = "Strange bag"
	icon = 'icons/obj/storage.dmi'
	icon_state = "backpack"
	item_state = "backpack"
	w_class = ITEM_SIZE_LARGE
	slot_flags = SLOT_FLAGS_BACK

/obj/item/weapon/pedalbag/verb/quick_empty()
	set name = "Empty Prisoners"
	set category = "Object"

	if((!ishuman(usr) && (src.loc != usr)) || usr.incapacitated())
		return

	usr.visible_message("<font class='artefact'>[usr] shakes out the contents of \the [src]!</font>")
	playsound(usr, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)

	var/turf/T = get_turf(src)

	for(var/atom/movable/A in contents)
		A.forceMove(T)

		if(ismob(A))
			var/mob/M = A
			M.status_flags ^= GODMODE

/obj/item/weapon/pedalbag/attack()
	return

/obj/item/weapon/pedalbag/afterattack(atom/target, mob/user, proximity, params)
	if((!proximity) || (!ismob(target)) || (user in src))
		return
	var/mob/M = target
	if(M == user)
		to_chat(user, "<font class='warning'>You don't want to do that.</font>")
		return

	user.do_attack_animation(target)
	user.visible_message("<font class='artefact'>[user] put \the [src] on [M]!</font>")
	playsound(user, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)

	M.forceMove(src)
	M.status_flags ^= GODMODE


/obj/item/weapon/pedalbag/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space in Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"

/* MAGIC HAT */

/obj/item/clothing/head/collectable/tophat/badmin_magic_hat
	name = "Hat"
	desc = "A magic hat that can break the world."

/obj/item/clothing/head/collectable/tophat/badmin_magic_hat/atom_init()
	. = ..()
	var/turf/T = get_turf(src)
	if(T)
		log_admin("Badmin [src] spawned on [T.x]:[T.y]:[T.z]")
		message_admins("<span class='notice'>Badmin [src] spawned on [T.x]:[T.y]:[T.z] [ADMIN_JMP(T)]</span>")
	else
		log_admin("Badmin [src] spawned somewhere")
		message_admins("<span class='notice'>Badmin [src] spawned somewhere</span>")

/obj/item/clothing/head/collectable/tophat/badmin_magic_hat/attack_self(mob/user)
	if(user.is_busy(src))
		return FALSE

	to_chat(user, "<span class='notice'>You start fumble in search...</span>")
	if(do_after(user, 100, target = src))
		if(prob(1) && prob(1)) // world.contents content only entitys, but I like this joke
			to_chat(user, "<span class='italic'>You really don't think this is a good idea to take <span class='bold'>a Master controller</span> from \a [src.name] and quickly put that back.</span>")
			return

		var/atom/movable/A = pick_entity()

		if(!A)
			to_chat(user, "<span class='italic'>Nothing. Try again.</span>")
			return


		user.visible_message("<span class='notice'>\the [user] takes <span class='bold'>\a [A]</span> from \a [src]!</span>")

		if (istype(A, /obj/item))
			user.put_in_hands(A)
		else
			A.forceMove(get_turf(user))

/obj/item/clothing/head/collectable/tophat/badmin_magic_hat/proc/pick_entity()
	var/attempt = 0
	var/atom/movable/entity

	while(attempt++ < 100)
		stoplag()

		entity = pick(world.contents)

		if(QDELETED(entity)) // not a really problem I think, can we comment out this?
			continue

		if(!istype(entity)) // turfs
			continue
		if(entity.flags & (NODROP | ABSTRACT) || !entity.simulated) // not real things
			continue
		if(istype(entity, /obj/effect) || istype(entity, /obj/screen)) // service things (eh)
			continue
		if(istype(entity, /mob/living/carbon/human/dummy)) // also service things
			continue
		if(istype(entity, /obj/machinery/atmospherics) && entity.anchored) // too many pipes, not interesting
			continue
		if(istype(entity, /obj/structure/cable) && entity.anchored) // same
			continue

		return entity
