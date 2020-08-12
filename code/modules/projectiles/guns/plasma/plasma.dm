// Here's the math used for plasma weapon shot consumption.
// We balance this number over "/obj/item/weapon/stock_parts/cell/super" which is used as default cell type in magazine.
// This battery provides 20000 cell charge, and we want 25 shots for carbine (as it was before this rework).
// So we take this number and divide it by number of shots, and get charge consumption per shot
// 20000 / number_of_shots = 800, incase of carbine.
// So this if player puts another battery into magazine, different number of shots can be achieved.
// Why super battery? Because even this high tier battery still requires basic materials, and our objective is to make battery upgrade as some kind of achievement.
// But incase of next tier battery (30000), number of shots will be 37, which is alot.
#define PLASMA_SHOT_ENERGY_COST (20000 / number_of_shots)
#define PLASMA_PROJECTILE_ENERGY_COST FLOOR(PLASMA_SHOT_ENERGY_COST / max_projectile_per_fire, 1)
#define PLASMAGUN_NORMAL_TYPE "normal"
#define PLASMAGUN_OVERCHARGE_TYPE "overcharge"

/obj/item/weapon/gun/plasma // this will act as placeholder too (previously it was L10-C under projectile guns).
	name = "plasma 10-bc"
	desc = "A basic plasma-based bullpup carbine with fast rate of fire."
	icon_state = "plasma10_car"
	item_state = "plasma10_car"
	w_class = ITEM_SIZE_LARGE
	origin_tech = "combat=3;magnets=2"
	fire_sound = 'sound/weapons/guns/plasma10_shot.ogg'
	recoil = FALSE
	can_be_holstered = FALSE

	var/overcharge_fire_sound = 'sound/weapons/guns/plasma10_overcharge_shot.ogg'

	var/list/ammo_type = list(
		PLASMAGUN_NORMAL_TYPE     = /obj/item/ammo_casing/plasma,
		PLASMAGUN_OVERCHARGE_TYPE = /obj/item/ammo_casing/plasma/overcharge
		)

	var/mag_type = /obj/item/ammo_box/magazine/plasma
	var/obj/item/ammo_box/magazine/plasma/magazine
	var/number_of_shots = 25 // with 20000 battery
	var/max_projectile_per_fire = 1 // this is amount of pellets at 100% used energy required to shoot, incase of spread guns like shotguns.

/obj/item/weapon/gun/plasma/p104sass
	name = "plasma 104-sass" // its actually 10/4. 10 - because its based in some technical aspects of carbine and even shoots the same projectiles. 4 - stands for prototype number.
	desc = "A plasma-based semi-automatic short shotgun."
	icon_state = "plasma104_stg"
	item_state = "plasma104_stg"
	origin_tech = "combat=4;magnets=3"

	overcharge_fire_sound = 'sound/weapons/guns/plasma10_overcharge_massive_shot.ogg'

	ammo_type = list(
		PLASMAGUN_NORMAL_TYPE     = /obj/item/ammo_casing/plasma,
		PLASMAGUN_OVERCHARGE_TYPE = /obj/item/ammo_casing/plasma/overcharge/massive
		)

	w_class = ITEM_SIZE_HUGE
	fire_delay = 15
	number_of_shots = 7 // It can be more than that (but no more than 1 extra), if there is a bit of charge left after 7th shot.
	max_projectile_per_fire = 5

/obj/item/weapon/gun/plasma/atom_init()
	. = ..()
	magazine = new mag_type(src)
	for(var/i in ammo_type)
		var/path = ammo_type[i]
		ammo_type[i] = new path(src)
	update_icon()

/obj/item/weapon/gun/plasma/Destroy()
	QDEL_LIST_ASSOC_VAL(ammo_type)
	QDEL_NULL(magazine)
	return ..()

/obj/item/weapon/gun/plasma/special_check(mob/M, atom/target)
	. = ..()
	if(.)
		// Two-handed wielding prototype for trying.
		// Has modern codebases idea where you simply need an empty hand to shoot, while keeping old idea where it blocks shooting at all.
		if(M.get_inactive_hand())
			to_chat(M, "<span class='notice'>Your other hand must be free before firing! This weapon requires both hands to use.</span>")
			return FALSE

/obj/item/weapon/gun/plasma/Fire(atom/target, mob/living/user, params, reflex = 0)
	newshot()
	..()

/obj/item/weapon/gun/plasma/proc/newshot()
	if (!magazine || !magazine.power_supply || magazine.power_supply.charge <= 0 || chambered)
		return

	var/obj/item/ammo_casing/energy/shot
	var/overcharged = magazine.has_overcharge()
	var/max_projectile_per_fire = src.max_projectile_per_fire

	if(!overcharged)
		shot = ammo_type[PLASMAGUN_NORMAL_TYPE]
		fire_delay = initial(fire_delay)
		fire_sound = initial(fire_sound)
	else
		shot = ammo_type[PLASMAGUN_OVERCHARGE_TYPE]
		fire_delay = 0
		fire_sound = overcharge_fire_sound
		max_projectile_per_fire = 1

	chambered = shot
	chambered.newshot()

	if(!overcharged && max_projectile_per_fire > 1) // for now it means that we use shotgun.
		chambered.BB.dispersion = 1.6 // this number is not random, does so that every "pellet" hits at range(2) excluding natural miss chance.
		// less pellets if there is not enough power for full shot.
		chambered.pellets = min(max_projectile_per_fire, magazine.power_supply.charge / PLASMA_PROJECTILE_ENERGY_COST)

	// 50% less damage if there is not enough power for one projectile.
	if (magazine.power_supply.charge < PLASMA_PROJECTILE_ENERGY_COST)
		chambered.BB.damage *= 0.5
		chambered.BB.alpha = 127

/obj/item/weapon/gun/plasma/can_fire()
	newshot()
	if(chambered && chambered.BB)
		return TRUE

/obj/item/weapon/gun/plasma/process_chamber()
	if (chambered) // incase its out of energy - since then this will be null.
		magazine.power_supply.use(PLASMA_SHOT_ENERGY_COST)
		chambered = null

/obj/item/weapon/gun/plasma/afterattack(atom/target, mob/user, proximity, params)
	..()
	update_icon()

/obj/item/weapon/gun/plasma/attack_self(mob/user)
	if(magazine && magazine.get_charge())
		playsound(user, 'sound/weapons/guns/plasma10_unload.ogg', VOL_EFFECTS_MASTER) // yes, no overcharge sound for unload.
	if(chambered)
		QDEL_NULL(chambered)
	if (magazine)
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine.update_icon()
		magazine = null
		to_chat(user, "<span class='notice'>You pull the magazine out of \the [src]!</span>")
	else
		to_chat(user, "<span class='notice'>There's no magazine in \the [src].</span>")
	update_icon(user)
	return

/obj/item/weapon/gun/plasma/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box/magazine/plasma))
		var/obj/item/ammo_box/magazine/plasma/AB = I
		if(!magazine && istype(AB, mag_type))
			user.drop_from_inventory(AB, src)
			magazine = AB
			to_chat(user, "<span class='notice'>You load a new magazine into \the [src].</span>")
			if(AB.get_charge())
				if(!AB.has_overcharge())
					playsound(user, 'sound/weapons/guns/plasma10_load.ogg', VOL_EFFECTS_MASTER)
				else
					playsound(user, 'sound/weapons/guns/plasma10_overcharge_load.ogg', VOL_EFFECTS_MASTER)
			AB.update_icon()
			update_icon(user)
			return TRUE

		else if (magazine)
			to_chat(user, "<span class='notice'>There's already a magazine in \the [src].</span>")
			return

	return ..()

/obj/item/weapon/gun/plasma/update_icon()
	if(!magazine)
		icon_state = "[initial(icon_state)]-e"
		item_state = "[initial(item_state)]-e"
	else if(magazine && magazine.get_charge())
		var/overcharged = magazine.has_overcharge() ? "-oc" : ""
		icon_state = "[initial(icon_state)][overcharged]"
		item_state = "[initial(item_state)][overcharged]"
	else
		icon_state = "[initial(icon_state)]-0"
		item_state = "[initial(item_state)]-0"
	update_inv_mob()

/obj/item/weapon/gun/plasma/p104sass/update_icon() // this one has no difference in item_states.
	if(!magazine)
		icon_state = "[initial(icon_state)]-e"
	else if(magazine && magazine.get_charge())
		var/overcharged = magazine.has_overcharge() ? "-oc" : ""
		icon_state = "[initial(icon_state)][overcharged]"
	else
		icon_state = "[initial(icon_state)]-0"
	update_inv_mob()

#undef PLASMA_PROJECTILE_ENERGY_COST
#undef PLASMAGUN_NORMAL_TYPE
#undef PLASMAGUN_OVERCHARGE_TYPE
