/obj/item/mine
	name = "mine"
	desc = "A friendly-looking pancake with a happy light on the top. Absolute opposite of libertarian - this mine BEGS to be stepped on."
	icon = 'icons/obj/mines.dmi'
	icon_state = "mine"
	layer = 3
	var/triggered = FALSE

/obj/item/mine/attack_self(mob/living/user)
	if(locate(/obj/item/mine) in get_turf(src))
		to_chat(user, "<span class='warning'>There already is a mine at this position!</span>")
		return

	if(!user.loc || user.loc.density)
		to_chat(user, "<span class='warning'>You can't plant a mine here.</span>")
		return

	user.visible_message("<span class='notice'>[user] starts deploying [src].</span>", "<span class='notice'>You start deploying [src].</span>")
	if(!do_after(user, 40, target = src))
		user.visible_message("<span class='notice'>[user] stops deploying [src].</span>", "<span class='notice'>You stop deploying \the [src].</span>")
		return
	user.visible_message("<span class='notice'>[user] finishes deploying [src].</span>", "<span class='notice'>You finish deploying [src].</span>")
	user.drop_from_inventory(src, user.loc)

	anchored = TRUE
	update_icon()

/obj/item/mine/update_icon()
	if(anchored)
		icon_state = "[icon_state]armed"
		alpha = 45
	else
		icon_state = initial(icon_state)
		alpha = 255

/obj/item/mine/Crossed(atom/movable/AM)
	Bumped(AM)

/obj/item/mine/Bumped(mob/M)
	if(triggered) return

	if(istype(M, /mob/living/carbon) || istype(M, /mob/living/silicon))
		if(anchored)
			M.visible_message("<span class='danger'>[M] steps on [src]!</span>")
			triggered = TRUE
			trigger_act(M)
		else
			return

/obj/item/mine/proc/trigger_act(obj)
	explosion(loc, 1, 1, 3, 3)
	qdel(src)

/obj/item/mine/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ismultitool(I) || !anchored)
		return

	user.visible_message("<span class='notice'>[user] starts disarming [src].</span>", "<span class='notice'>You start disarming [src].</span>")

	if(!do_after(user, 40, target = src))
		user.visible_message("<span class='warning'>[user] stops disarming [src].", "<span class='warning'>You stop disarming [src].</span>")
		return

	user.visible_message("<span class='notice'>[user] finishes disarming [src].", "<span class='notice'>You finish disarming [src].</span>")

	anchored = FALSE
	update_icon()

/obj/item/mine/stun
	name = "stun mine"
	desc = "A security-issued non-lethal mine for area-denial, this mine will stun and weaken anyone unfortunate to step on it."
	icon_state = "stunmine"

/obj/item/mine/stun/trigger_act(obj)
	if(isliving(obj))
		var/mob/living/M = obj
		M.apply_effect(150,AGONY,0)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(3, 1, src)
	s.start()
	spawn(0)
		qdel(src)

/obj/item/mine/shock
	name = "shock mine"
	desc = "A security issued less-than-lethal mine, this one will shock and stun anyone unfortunate to step on it."
	icon_state = "shockmine"

/obj/item/mine/shock/trigger_act(obj)
	if(isliving(obj))
		var/mob/living/M = obj
		M.electrocute_act(30, src) // electrocute act does a message.
		M.Weaken(5)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(3, 1, src)
	s.start()
	spawn(0)
		qdel(src)

/obj/item/mine/incendiary
	name = "incendiary mine"
	desc = "This thing definetly violates Space Geneva Convention."
	icon_state = "incendiarymine"

/obj/item/mine/incendiary/trigger_act(obj)
	if(isliving(obj))
		var/mob/living/M = obj
		M.adjust_fire_stacks(10)
		M.IgniteMob()
		qdel(src)
