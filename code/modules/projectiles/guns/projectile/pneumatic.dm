#define PNEUMATIC_SPEED_CAP 40
#define PNEUMATIC_SPEED_DIVISOR 800

/obj/item/weapon/storage/pneumatic
	name = "pneumatic cannon"
	desc = "A large gas-powered cannon."
	icon = 'icons/obj/gun.dmi'
	icon_state = "pneumatic"
	item_state = "pneumatic"
	w_class = ITEM_SIZE_HUGE
	flags =  CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	max_w_class = ITEM_SIZE_NORMAL
	storage_slots = 7

	var/obj/item/weapon/tank/tank = null                // Tank of gas for use in firing the cannon.
	var/obj/item/weapon/storage/tank_container          // Something to hold the tank item so we don't accidentally fire it.
	var/pressure_setting = 10                           // Percentage of the gas in the tank used to fire the projectile.
	var/possible_pressure_amounts = list(5,10,20,25,50) // Possible pressure settings.
	var/minimum_tank_pressure = 10                      // Minimum pressure to fire the gun.
	var/cooldown = 0                                    // Whether or not we're cooling down.
	var/cooldown_time = 50                              // Time between shots.

/obj/item/weapon/storage/pneumatic/atom_init()
	. = ..()
	tank_container = new()

/obj/item/weapon/storage/pneumatic/verb/set_pressure() //set amount of tank pressure.

	set name = "Set valve pressure"
	set category = "Object"
	set src in range(0)
	var/N = input("Percentage of tank used per shot:","[src]") as null|anything in possible_pressure_amounts
	if (N)
		pressure_setting = N
		to_chat(usr, "You dial the pressure valve to [pressure_setting]%.")

/obj/item/weapon/storage/pneumatic/verb/eject_tank() //Remove the tank.

	set name = "Eject tank"
	set category = "Object"
	set src in range(0)

	if(tank)
		to_chat(usr, "You twist the valve and pop the tank out of [src].")
		tank.loc = usr.loc
		tank = null
		icon_state = "pneumatic"
		item_state = "pneumatic"
		usr.update_icons()
	else
		to_chat(usr, "There's no tank in [src].")

/obj/item/weapon/storage/pneumatic/attackby(obj/item/I, mob/user, params)
	if(!tank && istype(I, /obj/item/weapon/tank))
		user.remove_from_mob(I)
		tank = I
		tank.loc = src.tank_container
		user.visible_message("[user] jams [I] into [src]'s valve and twists it closed.","You jam [I] into [src]'s valve and twist it closed.")
		icon_state = "pneumatic-tank"
		item_state = "pneumatic-tank"
		user.update_icons()
	else
		return ..()

/obj/item/weapon/storage/pneumatic/examine(mob/user)
	..()
	if(src in view(2, user))
		to_chat(user, "The valve is dialed to [pressure_setting]%.")
		if(tank)
			to_chat(user, "The tank dial reads [tank.air_contents.return_pressure()] kPa.")
		else
			to_chat(user, "Nothing is attached to the tank valve!")

/obj/item/weapon/storage/pneumatic/afterattack(atom/target, mob/user, proximity, params)
	if (target.loc == user.loc)
		return
	else if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if (length(contents) == 0)
		to_chat(user, "There's nothing in [src] to fire!")
		return 0
	else
		spawn(0) Fire(target,user,params)

/obj/item/weapon/storage/pneumatic/attack(mob/living/M, mob/living/user, def_zone)
	if (length(contents) > 0)
		if(user.a_intent == INTENT_HARM)
			user.visible_message("<span class='warning'><b> \The [user] fires \the [src] point blank at [M]!</b></span>")
			Fire(M,user)
			return
		else
			Fire(M,user)
			return

/obj/item/weapon/storage/pneumatic/proc/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/V = H.wear_suit
			V.attack_reaction(H, REACTION_GUN_FIRE)

	if (!tank)
		to_chat(user, "There is no gas tank in [src]!")
		return 0

	if (cooldown)
		to_chat(user, "The chamber hasn't built up enough pressure yet!")
		return 0

	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	var/fire_pressure = (tank.air_contents.return_pressure()/100)*pressure_setting

	if (fire_pressure < minimum_tank_pressure)
		to_chat(user, "There isn't enough gas in the tank to fire [src].")
		return 0

	var/obj/item/object = contents[1]
	var/speed = min(PNEUMATIC_SPEED_CAP, ((fire_pressure*tank.volume)/object.w_class)/PNEUMATIC_SPEED_DIVISOR) //projectile speed.

	playsound(src, 'sound/weapons/guns/gunshot_pneumaticgun.ogg', VOL_EFFECTS_MASTER, null, null, -2)
	user.visible_message("<span class='danger'>[user] fires [src] and launches [object] at [target]!</span>","<span class='danger'>You fire [src] and launch [object] at [target]!</span>")

	src.remove_from_storage(object,user.loc)
	object.throw_at(target, speed + 1, speed, user)

	var/lost_gas_amount = tank.air_contents.total_moles*(pressure_setting/100)
	var/datum/gas_mixture/removed = tank.air_contents.remove(lost_gas_amount)
	user.loc.assume_air(removed)

	cooldown = 1
	spawn(cooldown_time)
		cooldown = 0
		to_chat(user, "[src]'s gauge informs you it's ready to be fired again.")

/obj/item/weapon/storage/pneumatic/Destroy()
	QDEL_NULL(tank)
	QDEL_NULL(tank_container)
	return ..()

// *(PNEUMATOIC GUN craft in recipes.dm)*

/obj/item/weapon/cannonframe1
	name = "pneumo-gun(1 stage)"
	desc = "To finish you need: attach the pipe; weld it all; add 5 sheets of metal; weld it all; add tank transfer valve; weld it all."
	icon_state = "pneumaticframe1"
	item_state = "pneumatic"

/obj/item/weapon/cannonframe2
	name = "pneumo-gun(2 stage)"
	desc = "To finish you need: weld it all; add 5 sheets of metal; weld it all; add tank transfer valve; weld it all."
	icon_state = "pneumaticframe2"
	item_state = "pneumatic"

/obj/item/weapon/cannonframe3
	name = "pneumo-gun(3 stage)"
	desc = "To finish you need: add 5 sheets of metal; weld it all; add tank transfer valve; weld it all."
	icon_state = "pneumaticframe3"
	item_state = "pneumatic"

/obj/item/weapon/cannonframe4
	name = "pneumo-gun(4 stage)"
	desc = "To finish you need: weld it all; add tank transfer valve; weld it all."
	icon_state = "pneumaticframe4"
	item_state = "pneumatic"

/obj/item/weapon/cannonframe5
	name = "pneumo-gun(5 stage)"
	desc = "To finish you need: add tank transfer valve; weld it all."
	icon_state = "pneumaticframe5"
	item_state = "pneumatic"

/obj/item/weapon/cannonframe6
	name = "pneumo-gun(6 stage)"
	desc = "To finish you need: weld it all."
	icon_state = "pneumaticframe6"
	item_state = "pneumatic"

#undef PNEUMATIC_SPEED_CAP
#undef PNEUMATIC_SPEED_DIVISOR
