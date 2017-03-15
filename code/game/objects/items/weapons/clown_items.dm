/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/obj/item/weapon/proc/try_slip_on_me(mob/living/carbon/victim)
	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		if(isobj(human_victim.shoes) && (human_victim.shoes.flags & NOSLIP))
			return FALSE

	victim.stop_pulling()
	to_chat(victim, "<span class='notice'>You slipped on the [src]!</span>")
	playsound(loc, 'sound/misc/slip.ogg', 50, 1, -3)
	victim.Stun(4)
	victim.Weaken(2)
	return TRUE

/*
 * Banana Peals
 */
/obj/item/weapon/bananapeel/Crossed(AM as mob|obj)
	if(iscarbon(AM))
		if(try_slip_on_me(AM))
			Move(get_step(get_turf(src), pick(cardinal)))

/*
 * Soap
 */
/obj/item/weapon/soap/Crossed(AM as mob|obj) //EXACTLY the same as bananapeel for now, so it makes sense to put it in the same dm -- Urist
	if(iscarbon(AM))
		if(try_slip_on_me(AM))
			Move(get_step(get_turf(src), pick(cardinal)))

/obj/item/weapon/soap/afterattack(atom/target, mob/user, proximity)
	if(!proximity) return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		to_chat(user, "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>")
	else if(istype(target,/obj/effect/decal/cleanable))
		to_chat(user, "<span class='notice'>You scrub \the [target.name] out.</span>")
		qdel(target)
	else
		to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
		target.clean_blood()
	return

/obj/item/weapon/soap/attack(mob/target, mob/user)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == "mouth" )
		user.visible_message("<span class='red'>\the [user] washes \the [target]'s mouth out with soap!</span>")
		return
	..()

/*
 * Bike Horns
 */
/obj/item/weapon/bikehorn/attack_self(mob/user)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return
