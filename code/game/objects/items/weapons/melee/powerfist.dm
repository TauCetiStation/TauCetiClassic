/obj/item/weapon/melee/powerfist
	name = "power-fist"
	desc = "A metal gauntlet with a piston-powered ram ontop for that extra 'ompfh' in your punch. Definitely stolen from Unathi."
	icon_state = "powerfist_1"
	item_state = "powerfist"
	flags = CONDUCT
	attack_verb = list("whacked", "fisted", "power-punched")
	force = 20
	throwforce = 10
	throw_range = 7
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "combat=5;powerstorage=3;syndicate=3"
	var/base_force = 0
	var/fisto_setting = 1
	var/gasperfist = 3
	var/obj/item/weapon/tank/tank = null //Tank used for the gauntlet's piston-ram.

/obj/item/weapon/melee/powerfist/atom_init(mapload, ...)
	. = ..()
	base_force = force

/obj/item/weapon/melee/powerfist/examine(mob/user)
	..()
	if(!in_range(user, src))
		to_chat(user,"<span class='notice'>You'll need to get closer to see any more.</span>")
		return
	if(tank)
		to_chat(user,"<span class='notice'>\icon [tank] It has \the [tank] mounted onto it.</span>")


/obj/item/weapon/melee/powerfist/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/tank))
		if(!tank)
			var/obj/item/weapon/tank/IT = I
			if(IT.volume <= 3)
				to_chat(user,"<span class='warning'>\The [IT] is too small for \the [src].</span>")
				return
			updateTank(I, 0, user)
		else
			updateTank(I, 1, user)

	else if(iswrench(I))
		switch(fisto_setting)
			if(1)
				fisto_setting = 2
			if(2)
				fisto_setting = 3
			if(3)
				fisto_setting = 1
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		to_chat(user,"<span class='notice'>You tweak \the [src]'s piston valve to [fisto_setting].</span>")
		update_icon()

	else if(isscrewdriver(I))
		updateTank(tank, 1, user)

	else
		return ..()

/obj/item/weapon/melee/powerfist/proc/updateTank(obj/item/weapon/tank/thetank, removing = 0, mob/living/carbon/human/user)
	if(removing)
		if(!tank)
			to_chat(user,"<span class='notice'>\The [src] currently has no tank attached to it.</span>")
			return
		to_chat(user,"<span class='notice'>You detach \the [thetank] from \the [src].</span>")
		tank.forceMove(get_turf(user))
		user.put_in_hands(tank)
		tank = null
	else
		if(tank)
			to_chat(user,"<span class='warning'>\The [src] already has a tank.</span>")
			return
		if(!user.unEquip(thetank))
			return
		to_chat(user,"<span class='notice'>You hook \the [thetank] up to \the [src].</span>")
		tank = thetank
		thetank.forceMove(src)


/obj/item/weapon/melee/powerfist/attack(mob/living/target, mob/living/user, def_zone)
	if(!tank)
		to_chat(user,"<span class='warning'>\The [src] can't operate without a source of gas!</span>")
		return FALSE
	else if(!tank.air_contents.remove(gasperfist * fisto_setting))
		to_chat(user,"<span class='warning'>\The [src]'s piston-ram lets out a weak hiss, it needs more gas!</span>")
		playsound(src, 'sound/effects/refill.ogg', VOL_EFFECTS_MASTER)
		return FALSE
	force = base_force * fisto_setting
	var/success = ..()
	force = base_force
	if (success)
		target.visible_message("<span class='danger'>[user]'s powerfist lets out a loud hiss as they punch [target.name]!</span>",
								"<span class='userdanger'>You cry out in pain as [user]'s punch flings you backwards!</span>")
		new /obj/item/effect/kinetic_blast(target.loc)
		playsound(src, 'sound/weapons/guns/resonator_blast.ogg', VOL_EFFECTS_MASTER)
		playsound(src, 'sound/weapons/genhit2.ogg', VOL_EFFECTS_MASTER)

		var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
		target.throw_at(throw_target, 5 * fisto_setting, 1)
		return TRUE
	return FALSE

/obj/item/weapon/melee/powerfist/update_icon()
	icon_state = "powerfist_[fisto_setting]"
