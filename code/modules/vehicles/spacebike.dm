/obj/vehicle/space/spacebike
	name = "space-bike"
	desc = "Space wheelies! Woo! "
	icon_state = "bike_off"
	dir = SOUTH

	load_item_visible = 1
	mob_offset_y = 5
	health = 300
	maxhealth = 300

	fire_dam_coeff = 0.6
	brute_dam_coeff = 0.5
	var/protection_percent = 60

	var/land_speed = 10 //if 0 it can't go on turf
	var/space_speed = 1
	var/bike_icon = "bike"
	var/obj/item/weapon/key/spacebike/key
	var/id = 0

	var/datum/effect/effect/system/ion_trail_follow/ion
	var/kickstand = 1

/obj/item/weapon/key/spacebike
	name = "key"
	desc = "A keyring with a small steel key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys_bike"
	w_class = ITEM_SIZE_TINY
	var/id = 0

/obj/item/weapon/key/spacebike/examine(mob/user)
	..()
	to_chat(user, "There is a small tag reading [id].")

/obj/vehicle/space/spacebike/atom_init()
	. = ..()
	ion = new /datum/effect/effect/system/ion_trail_follow()
	ion.set_up(src)
	turn_off()
	id = rand(1,1000)
	key = new(src)
	key.id = id
	add_overlay(image('icons/obj/vehicles.dmi', "[icon_state]_off_overlay", MOB_LAYER + 1))
	icon_state = "[bike_icon]_off"

/obj/vehicle/space/spacebike/Destroy()
	QDEL_NULL(ion)
	QDEL_NULL(key)
	return ..()

/obj/vehicle/space/spacebike/examine(mob/user)
	..()
	to_chat(user, "It has number [id].")

/obj/vehicle/space/spacebike/load(mob/living/M)
	if(!istype(M))
		return FALSE
	if(M.buckled || M.incapacitated() || M.lying || !Adjacent(M) || !M.Adjacent(src))
		return FALSE
	return ..()

/obj/vehicle/space/spacebike/MouseDrop_T(mob/living/M, mob/living/user)
	if(!istype(user) || !istype(M))
		return
	if(isessence(user))
		return
	if(user.incapacitated() || user.lying)
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return
	if(!load(M))
		to_chat(user, "<span class='warning'>You were unable to load \the [M] onto \the [src].</span>")
		return

/obj/vehicle/space/spacebike/attack_hand(mob/user)
	if(!load)
		return
	user.SetNextMove(CLICK_CD_MELEE)
	if(load != user)
		if(do_after(user, 20, target=src))
			load.visible_message(\
				"<span class='notice'>[load.name] was unbuckled by [user.name]!</span>",\
				"<span class='warning'>You were unbuckled from [src] by [user.name].</span>",\
				"<span class='notice'>You hear metal clanking.</span>")
	else
		load.visible_message(\
			"<span class='notice'>[load.name] unbuckled \himself!</span>",\
			"<span class='notice'>You unbuckle yourself from [src].</span>",\
			"<span class='notice'>You hear metal clanking.</span>")
	unload(load)

/obj/vehicle/space/spacebike/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/key/spacebike))
		var/obj/item/weapon/key/spacebike/K = W
		if(!key)
			if(K.id != src.id)
				to_chat(user, "<span class='notice'>You can't put the key into the slot.</span>")
				return
			user.drop_item()
			K.loc = src
			key = K
			user.SetNextMove(CLICK_CD_INTERACT)
			playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER, 25)
			to_chat(user, "<span class='notice'>You put the key into the slot.</span>")
			verbs += /obj/vehicle/space/spacebike/verb/remove_key
			verbs += /obj/vehicle/space/spacebike/verb/toggle_engine
		return
	return ..()

/obj/vehicle/space/spacebike/Bump(atom/A)
	if(istype(loc, /turf/space) && isliving(load) && isliving(A))
		var/mob/living/L = A
		var/mob/living/Driver = load
		if(istype(L,/mob/living/silicon/robot))
			if(istype(L,/mob/living/silicon/robot/drone))
				visible_message("<span class='danger'>[Driver] drives over [L]!</span>")
				L.gib()
			else
				unload(Driver)
				visible_message("<span class='danger'>[Driver] crushes into [L]!</span>")
				Driver.apply_effects(8,5)
				Driver.lying = 1
		else
			if(Driver == L)
				unload(Driver)
			visible_message("<span class='danger'>[Driver] drives over [L]!</span>")

			L.log_combat(Driver, "driven over with [src]")

			playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)
			L.stop_pulling()
			L.apply_effects(8,5)
			L.lying = 1
			var/damage = rand(5,15)
			L.apply_damage(2*damage, BRUTE, BP_HEAD)
			L.apply_damage(2*damage, BRUTE, BP_CHEST)
			L.apply_damage(0.5*damage, BRUTE, BP_L_LEG)
			L.apply_damage(0.5*damage, BRUTE, BP_R_LEG)
			L.apply_damage(0.5*damage, BRUTE, BP_L_ARM)
			L.apply_damage(0.5*damage, BRUTE, BP_R_ARM)
	..()

/obj/vehicle/space/spacebike/relaymove(mob/user, direction)
	return Move(get_step(src, direction))


/obj/vehicle/space/spacebike/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	//these things like space, not turf. Dragging shouldn't weigh you down.
	if(istype(NewLoc, /turf/space) || pulledby)
		if(!space_speed)
			return FALSE
		move_delay = space_speed + slow_cooef
	else
		if(!land_speed)
			return FALSE
		move_delay = land_speed + slow_cooef
	return ..()

/obj/vehicle/space/spacebike/can_move()
	. = ..()
	if(kickstand)
		return 0
	if(buckled_mob && (buckled_mob.stat || buckled_mob.lying))
		return 0

/obj/vehicle/space/spacebike/turn_on()
	ion.start()
	anchored = 1
	update_icon()

	if(pulledby)
		pulledby.stop_pulling()

	..()

/obj/vehicle/space/spacebike/turn_off()
	ion.stop()
	anchored = kickstand
	update_icon()

	..()

/obj/vehicle/space/spacebike/verb/toggle_engine()
	set name = "Toggle engine"
	set category = "Vehicle"
	set src in view(0)

	if(!ishuman(usr))
		return

	if(!key)
		return

	if(!on)
		turn_on()
		src.visible_message("\The [src] rumbles to life.", "You hear something rumble deeply.")
	else
		turn_off()
		src.visible_message("\The [src] putters before turning off.", "You hear something putter slowly.")

/obj/vehicle/space/spacebike/verb/remove_key()
	set name = "Remove key"
	set category = "Vehicle"
	set src in view(0)

	if(!ishuman(usr))
		return

	if(!key || (load && load != usr))
		return

	if(on)
		turn_off()

	key.loc = usr.loc
	if(!usr.get_active_hand())
		usr.put_in_hands(key)
	key = null
	to_chat(usr, "<span class='notice'>You get out the key from the slot.</span>")

	verbs -= /obj/vehicle/space/spacebike/verb/remove_key
	verbs -= /obj/vehicle/space/spacebike/verb/toggle_engine

/obj/vehicle/space/spacebike/verb/kickstand()
	set name = "Toggle Kickstand"
	set category = "Vehicle"
	set src in view(0)

	if(!ishuman(usr))
		return

	if(usr.incapacitated())
		return

	if(kickstand)
		src.visible_message("[usr.name] puts up \the [src]'s kickstand.", "<span class='notice'>You put up \the [src]'s kickstand.</span>")
	else
		if(istype(src.loc,/turf/space))
			to_chat(usr, "<span class='warning'>You don't think kickstands work in space...</span>")
			return
		src.visible_message("[usr.name] puts down \the [src]'s kickstand.", "<span class='notice'>You put down \the [src]'s kickstand.</span>")
		if(pulledby)
			pulledby.stop_pulling()

	kickstand = !kickstand
	anchored = (kickstand || on)

/obj/vehicle/space/spacebike/bullet_act(obj/item/projectile/Proj)
	if(isliving(load) && prob(protection_percent))
		var/mob/living/M = load
		M.bullet_act(Proj)
		return
	..()

/obj/vehicle/space/spacebike/update_icon()
	cut_overlays()

	if(on)
		add_overlay(image('icons/obj/vehicles.dmi', "[bike_icon]_on_overlay", MOB_LAYER + 1))
		icon_state = "[bike_icon]_on"
	else
		add_overlay(image('icons/obj/vehicles.dmi', "[bike_icon]_off_overlay", MOB_LAYER + 1))
		icon_state = "[bike_icon]_off"

	..()
