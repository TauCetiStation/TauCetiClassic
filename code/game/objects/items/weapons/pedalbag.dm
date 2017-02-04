/obj/item/weapon/pedalbag
	name = "Strange bag"
	icon = 'icons/obj/storage.dmi'
	icon_state = "backpack"
	item_state = "backpack"
	w_class = 4.0
	slot_flags = SLOT_BACK

/obj/item/weapon/pedalbag/verb/quick_empty()
	set name = "Empty Prisoners"
	set category = "Object"

	if((!ishuman(usr) && (src.loc != usr)) || usr.stat || usr.restrained())
		return

	usr.visible_message("<font class='artefact'>[usr] shakes out the contents of \the [src]!</font>")
	playsound(usr.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

	var/turf/T = get_turf(src)

	for(var/atom/movable/A in contents)
		A.forceMove(T)

		if(ismob(A))
			var/mob/M = A
			M.status_flags ^= GODMODE

/obj/item/weapon/pedalbag/attack()
	return

/obj/item/weapon/pedalbag/afterattack(mob/target, mob/user, proximity)
	if((!proximity) || (!ismob(target)) || (user in src))
		return

	if(target == user)
		to_chat(user, "<font class='warning'>You don't want to do that.</font>")
		return

	user.do_attack_animation(target)
	user.visible_message("<font class='artefact'>[user] put \the [src] on [target]!</font>")
	playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

	target.forceMove(src)
	target.status_flags ^= GODMODE


/obj/item/weapon/pedalbag/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space in Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
