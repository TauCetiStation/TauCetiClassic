#define POWERFIST_MIN_PRESSURE 10 // kPa

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
	w_class = SIZE_SMALL
	origin_tech = "combat=5;powerstorage=3;syndicate=3"
	can_embed = FALSE
	var/base_force = 0
	var/fisto_setting = 1
	var/damage_mult_per_stage = 3
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
			insertTank(IT, user)
		else
			removeTank(user)

	else if(iswrenching(I))
		fisto_setting = 1 + (fisto_setting % 3)
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		to_chat(user,"<span class='notice'>You tweak \the [src]'s piston valve to [fisto_setting].</span>")
		update_icon()

	else if(isscrewing(I))
		removeTank(user)

	else
		return ..()

/obj/item/weapon/melee/powerfist/proc/removeTank(mob/living/carbon/human/user)
	if(!tank)
		to_chat(user,"<span class='notice'>\The [src] currently has no tank attached to it.</span>")
		return
	to_chat(user,"<span class='notice'>You detach \the [tank] from \the [src].</span>")
	user.put_in_hands(tank)
	tank = null

/obj/item/weapon/melee/powerfist/proc/insertTank(obj/item/weapon/tank/thetank, mob/living/carbon/human/user)
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
	var/initial_pressure = tank.air_contents.return_pressure()
	var/consumed_pressure = 0
	if(initial_pressure >= POWERFIST_MIN_PRESSURE)
#define K0 0.3
#define K1 0.115
#define K2 0.105
		// fixed ratio pressure removal for balance I guess, corresponds to 30%, 50%, 90%
		// to find coefficients use quadratic fit
		var/datum/gas_mixture/M = tank.air_contents.remove_ratio(fisto_setting ** 2 * K2 - fisto_setting * K1 + K0)
#undef K0
#undef K1
#undef K2
		// this is bogus, but real physics is too hard, this will do
		consumed_pressure = M.return_pressure()

	if(consumed_pressure < POWERFIST_MIN_PRESSURE)
		to_chat(user,"<span class='warning'>\The [src]'s piston-ram lets out a weak hiss, it needs more gas!</span>")
		playsound(src, 'sound/effects/refill.ogg', VOL_EFFECTS_MASTER)
		return FALSE

#define PRACTICAL_MAX_CONSUMED (10 * ONE_ATMOSPHERE * 0.9)
	// punch is the damage multiplier, under normal circumstances,
	// when player hits PRACTICAL_MAX_CONSUMED (approx 910 kPa)
	// punch will be 3, so we deal 3x base damage (20 -> 60)
	var/punch = consumed_pressure / PRACTICAL_MAX_CONSUMED * damage_mult_per_stage
#undef  PRACTICAL_MAX_CONSUMED

	force = base_force * punch
	var/success = ..()
	force = base_force
	if (success)
		target.visible_message("<span class='danger'>[user]'s powerfist lets out a loud hiss as they punch [target.name]!</span>",
								"<span class='userdanger'>You cry out in pain as [user]'s punch flings you backwards!</span>")
		new /obj/item/effect/kinetic_blast(target.loc)
		playsound(src, 'sound/weapons/guns/resonator_blast.ogg', VOL_EFFECTS_MASTER)
		playsound(src, 'sound/weapons/genhit2.ogg', VOL_EFFECTS_MASTER)

		var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
		target.throw_at(throw_target, 5 * punch, 1)
		return TRUE
	return FALSE

/obj/item/weapon/melee/powerfist/update_icon()
	icon_state = "powerfist_[fisto_setting]"

#undef POWERFIST_MIN_PRESSURE
