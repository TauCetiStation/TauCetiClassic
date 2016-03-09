/obj/vehicle/bike
	name = "space-bike"
	desc = "Space wheelies! Woo! "
	icon = 'icons/obj/bike.dmi'
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

	var/datum/effect/effect/system/ion_trail_follow/ion
	var/kickstand = 1

/obj/vehicle/bike/New()
	..()
	ion = new /datum/effect/effect/system/ion_trail_follow()
	ion.set_up(src)
	turn_off()
	overlays += image('icons/obj/bike.dmi', "[icon_state]_off_overlay", MOB_LAYER + 1)
	icon_state = "[bike_icon]_off"

/obj/vehicle/bike/verb/toggle()
	set name = "Toggle Engine"
	set category = "Vehicle"
	set src in view(0)

	if(isobserver(usr)) //Ghost riders? Nope, never heard about them.
		return

	if(usr.incapacitated()) return

	if(!on)
		turn_on()
		src.visible_message("\The [src] rumbles to life.", "You hear something rumble deeply.")
	else
		turn_off()
		src.visible_message("\The [src] putters before turning off.", "You hear something putter slowly.")

/obj/vehicle/bike/verb/kickstand()
	set name = "Toggle Kickstand"
	set category = "Vehicle"
	set src in view(0)

	if(isobserver(usr))
		return

	if(usr.incapacitated()) return

	if(kickstand)
		src.visible_message("[usr.name] puts up \the [src]'s kickstand.", "You put up \the [src]'s kickstand.")
	else
		if(istype(src.loc,/turf/space))
			usr << "<span class='warning'>You don't think kickstands work in space...</span>"
			return
		src.visible_message("[usr.name] puts down \the [src]'s kickstand.", "You put down \the [src]'s kickstand.")
		if(pulledby)
			pulledby.stop_pulling()

	kickstand = !kickstand
	anchored = (kickstand || on)

/obj/vehicle/bike/load(var/atom/movable/C)
	var/mob/living/M = C
	if(!istype(C)) return 0
	if(M.buckled || M.restrained() || !Adjacent(M) || !M.Adjacent(src))
		return 0
	return ..(M)

/obj/vehicle/bike/MouseDrop_T(var/atom/movable/C, mob/user as mob)
	if(!load(C))
		user << "<span class='warning'> You were unable to load \the [C] onto \the [src].</span>"
		return

/obj/vehicle/bike/attack_hand(var/mob/user as mob)
	if(load != user)
		if(do_after(user, 20, target=src))
			load.visible_message(\
				"<span class='notice'>[load.name] was unbuckled by [user.name]!</span>",\
				"You were unbuckled from [src] by [user.name].",\
				"You hear metal clanking")
		else
			return
	else
		load.visible_message(\
			"<span class='notice'>[load.name] unbuckled \himself!</span>",\
			"You unbuckle yourself from [src].",\
			"You hear metal clanking")
	unload(load)

/obj/vehicle/bike/Bump(atom/A)
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

			Driver.attack_log += text("\[[time_stamp()]\] <font color='red'>drives over [L.name] ([L.ckey])</font>")
			L.attack_log += text("\[[time_stamp()]\] <font color='orange'>was driven over by [Driver.name] ([Driver.ckey])</font>")
			msg_admin_attack("[key_name(Driver)] drives over [key_name(L)] with space bike (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")

			playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
			L.stop_pulling()
			L.apply_effects(8,5)
			L.lying = 1
			var/damage = rand(5,15)
			L.apply_damage(2*damage, BRUTE, "head")
			L.apply_damage(2*damage, BRUTE, "chest")
			L.apply_damage(0.5*damage, BRUTE, "l_leg")
			L.apply_damage(0.5*damage, BRUTE, "r_leg")
			L.apply_damage(0.5*damage, BRUTE, "l_arm")
			L.apply_damage(0.5*damage, BRUTE, "r_arm")
	..()

/obj/vehicle/bike/relaymove(mob/user, direction)
	if(user != load || !on)
		return
	return Move(get_step(src, direction))

/obj/vehicle/bike/Move(var/turf/destination)
	if(kickstand) return

	//these things like space, not turf. Dragging shouldn't weigh you down.
	if(istype(destination,/turf/space) || pulledby)
		if(!space_speed)
			return 0
		move_delay = space_speed
	else
		if(!land_speed)
			return 0
		move_delay = land_speed
	return ..()

/obj/vehicle/bike/turn_on()
	ion.start()
	anchored = 1

	update_icon()

	if(pulledby)
		pulledby.stop_pulling()
	..()

/obj/vehicle/bike/turn_off()
	ion.stop()
	anchored = kickstand

	update_icon()

	..()

/obj/vehicle/bike/bullet_act(var/obj/item/projectile/Proj)
	if(istype(load, /mob/living) && prob(protection_percent))
		var/mob/living/M = load
		M.bullet_act(Proj)
		return
	..()

/obj/vehicle/bike/update_icon()
	overlays.Cut()

	if(on)
		overlays += image('icons/obj/bike.dmi', "[bike_icon]_on_overlay", MOB_LAYER + 1)
		icon_state = "[bike_icon]_on"
	else
		overlays += image('icons/obj/bike.dmi', "[bike_icon]_off_overlay", MOB_LAYER + 1)
		icon_state = "[bike_icon]_off"

	..()


/obj/vehicle/bike/Destroy()
	qdel(ion)
	..()
