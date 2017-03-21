/obj/item/device/assembly/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon_state = "mousetrap"
	m_amt = 100
	w_amt = 10
	origin_tech = "combat=1"
	var/armed = 0

/obj/item/device/assembly/mousetrap/examine(mob/user)
	..()
	if(armed)
		to_chat(user, "It looks like it's armed.")

/obj/item/device/assembly/mousetrap/update_icon()
	if(armed)
		icon_state = "mousetraparmed"
	else
		icon_state = "mousetrap"
	if(holder)
		holder.update_icon()

/obj/item/device/assembly/mousetrap/proc/triggered(mob/target, type = "feet")
	if(!armed)
		return
	var/obj/item/bodypart/BP = null
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		switch(type)
			if("feet")
				if(!H.shoes)
					BP = H.get_organ(pick("l_leg", "r_leg"))
					H.Weaken(3)
			if("l_arm", "r_arm")
				if(!H.gloves)
					BP = H.get_organ(type)
					H.Stun(3)
		if(BP)
			BP.take_damage(1, 0)
			H.updatehealth()
	else if(ismouse(target))
		var/mob/living/simple_animal/mouse/M = target
		visible_message("\red <b>SPLAT!</b>")
		M.splat()
	playsound(target.loc, 'sound/effects/snap.ogg', 50, 1)
	layer = MOB_LAYER - 0.2
	armed = 0
	update_icon()
	pulse(0)

/obj/item/device/assembly/mousetrap/attack_self(mob/living/user)
	if(!armed)
		to_chat(user, "<span class='notice'>You arm [src].</span>")
	else
		if(((user.getBrainLoss() >= 60 || (CLUMSY in user.mutations)) && prob(50)))
			var/which_hand = "l_arm"
			if(!user.hand)
				which_hand = "r_arm"
			triggered(user, which_hand)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			return
		to_chat(user, "<span class='notice'>You disarm [src].</span>")
	armed = !armed
	update_icon()
	playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)

/obj/item/device/assembly/mousetrap/attack_hand(mob/living/user)
	if(armed)
		if(((user.getBrainLoss() >= 60 || CLUMSY in user.mutations)) && prob(50))
			var/which_hand = "l_arm"
			if(!user.hand)
				which_hand = "r_arm"
			triggered(user, which_hand)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			return
	..()

/obj/item/device/assembly/mousetrap/Crossed(AM as mob|obj)
	if(armed)
		if(ishuman(AM))
			var/mob/living/carbon/H = AM
			if(H.m_intent == "run")
				triggered(H)
				H.visible_message("<span class='warning'>[H] accidentally steps on [src].</span>", \
								  "<span class='warning'>You accidentally step on [src]</span>")
		if(ismouse(AM))
			triggered(AM)
	..()

/obj/item/device/assembly/mousetrap/on_found(mob/finder)
	if(armed)
		finder.visible_message("<span class='warning'>[finder] accidentally sets off [src], breaking their fingers.</span>", \
							   "<span class='warning'>You accidentally trigger [src]!</span>")
		triggered(finder, finder.hand ? "l_arm" : "r_arm")
		return 1	//end the search!
	return 0

/obj/item/device/assembly/mousetrap/hitby(A)
	if(!armed)
		return ..()
	visible_message("<span class='warning'>[src] is triggered by [A].</span>")
	triggered(null)

/obj/item/device/assembly/mousetrap/armed
	icon_state = "mousetraparmed"
	armed = 1

/obj/item/device/assembly/mousetrap/verb/hide_under()
	set src in oview(1)
	set name = "Hide"
	set category = "Object"

	if(usr.stat)
		return

	layer = TURF_LAYER+0.2
	to_chat(usr, "<span class='notice'>You hide [src].</span>")
