//Vox pinning weapon.

//Ammo.
/obj/item/weapon/spike
	name = "alloy spike"
	desc = "It's about a foot of weird silver metal with a wicked point."
	sharp = 1
	edge = 0
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/weapons.dmi'
	icon_state = "metal-rod"
	item_state = "bolt"

//Launcher.
/obj/item/weapon/spikethrower

	name = "Vox spike thrower"
	desc = "A vicious alien projectile weapon. Parts of it quiver gelatinously, as though the thing is insectile and alive."

	var/last_regen = 0
	var/spike_gen_time = 10 SECONDS
	var/max_spikes = 3
	var/spikes = 3
	var/obj/item/weapon/spike/spike
	var/fire_force = 30

	//Going to make an effort to get this compatible with the threat targetting system.
	var/tmp/list/mob/living/target
	var/tmp/mob/living/last_moved_mob

	icon = 'icons/obj/gun.dmi'
	icon_state = "spikethrower3"
	item_state = "spikethrower"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'

/obj/item/weapon/spikethrower/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	last_regen = world.time

/obj/item/weapon/spikethrower/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/spikethrower/process()

	if(spikes < max_spikes && world.time > last_regen + spike_gen_time)
		playsound(src, 'sound/weapons/guns/reload_newspike.ogg', VOL_EFFECTS_MASTER, 30, null, -5)
		spikes++
		last_regen = world.time
		update_icon()

/obj/item/weapon/spikethrower/examine(mob/user)
	..()
	if(src in view(1, user))
		to_chat(user, "It has [spikes] [spikes == 1 ? "spike" : "spikes"] remaining.")

/obj/item/weapon/spikethrower/update_icon()
	icon_state = "spikethrower[spikes]"

/obj/item/weapon/spikethrower/afterattack(atom/target, mob/user, proximity, params)
	if(proximity) return
	if(user && user.client && user.client.gun_mode && !(target in target))
		//TODO: Make this compatible with targetting (prolly have to actually make it a gun subtype, ugh.)
		//PreFire(A,user,params)
	else
		Fire(target,user,params)

/obj/item/weapon/spikethrower/attack(mob/living/M, mob/living/user, def_zone)
	if (M == user && def_zone == O_MOUTH)
		M.visible_message("<span class='warning'>[user] attempts without success to fit [src] into their mouth.</span>")
		return

	if (spikes > 0)
		if(user.a_intent == INTENT_HARM)
			user.visible_message("<span class='warning'><b> \The [user] fires \the [src] point blank at [M]!</b></span>")
			Fire(M,user)
			return
		else if(target && (M in target))
			Fire(M,user)
			return
	else
		return ..()

/obj/item/weapon/spikethrower/proc/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/V = H.wear_suit
			V.attack_reaction(H, REACTION_GUN_FIRE)
	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species && H.species.name != VOX)
			to_chat(user, "<span class='warning'>The weapon does not respond to you!</span>")
			return
	else
		to_chat(user, "<span class='warning'>The weapon does not respond to you!</span>")
		return

	if(spikes <= 0)
		playsound(src, 'sound/weapons/guns/outofspikes.ogg', VOL_EFFECTS_MASTER, null, null, -6)
		to_chat(user, "<span class='warning'>The weapon has nothing to fire!</span>")
		return

	if(!spike)
		spike = new(src) //Create a spike.
		spike.add_fingerprint(user)
		spikes--

	user.visible_message("<span class='warning'>[user] fires [src]!</span>", "<span class='warning'>You fire [src]!</span>")
	playsound(src, 'sound/weapons/guns/gunshot_spikethrower.ogg', VOL_EFFECTS_MASTER, null, null, -5)
	spike.loc = get_turf(src)
	spike.throw_at(target, 10, fire_force, user)
	spike = null
	update_icon()

//This gun only functions for armalis. The on-sprite is too huge to render properly on other sprites.
/obj/item/weapon/gun/energy/noisecannon

	name = "alien heavy cannon"
	desc = "It's some kind of enormous alien weapon, as long as a man is tall."

	icon = 'icons/obj/gun.dmi' //Actual on-sprite is handled by icon_override.
	icon_state = "noisecannon"
	item_state = "noisecannon"
	recoil = 1

	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/sonic)
	cell_type = "/obj/item/weapon/stock_parts/cell/super"
	fire_delay = 40


	var/mode = 1

/obj/item/weapon/gun/energy/noisecannon/attack_hand(mob/user)
	if(loc != user)
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if(H.species.name == VOX_ARMALIS)
				..()
				return
		to_chat(user, "<span class='warning'>\The [src] is far too large for you to pick up.</span>")
		return
/*
/obj/item/weapon/gun/energy/noisecannon/load_into_chamber() //Does not have ammo.
	in_chamber = new projectile_type(src)
	return 1 */

/obj/item/weapon/gun/energy/noisecannon/update_icon()
	return

//Projectile.
/obj/item/ammo_casing/energy/sonic
	projectile_type = /obj/item/projectile/energy/sonic
	select_name = "distortion"
	e_cost = 0
	fire_sound = 'sound/effects/basscannon.ogg'

/obj/item/projectile/energy/sonic
	name = "distortion"
	icon = 'icons/obj/machines/particle_accelerator2.dmi'
	icon_state = "particle"
	damage = 60
	damage_type = BRUTE
	flag = "bullet"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	embed = 0
	weaken = 5
	stun = 5

/obj/item/projectile/energy/sonic/proc/split()
	//TODO: create two more projectiles to either side of this one, fire at targets to the side of target turf.
	return
