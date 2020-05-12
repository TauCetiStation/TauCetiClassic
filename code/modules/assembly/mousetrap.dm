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
	var/obj/item/organ/external/BP = null
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		switch(type)
			if("feet")
				if(!H.shoes && !H.buckled)
					BP = H.bodyparts_by_name[pick(BP_L_LEG , BP_R_LEG)]
					H.Weaken(3)
			if(BP_L_ARM, BP_R_ARM)
				if(!H.gloves)
					BP = H.bodyparts_by_name[type]
					H.Stun(3)
		if(BP)
			BP.take_damage(1, 0)
			H.updatehealth()
	else if(ismouse(target))
		var/mob/living/simple_animal/mouse/M = target
		visible_message("<span class='warning'><b>SPLAT!</b></span>")
		M.splat()
	playsound(target, 'sound/effects/snap.ogg', VOL_EFFECTS_MASTER)
	layer = MOB_LAYER - 0.2
	armed = 0
	update_icon()
	pulse(0)

/obj/item/device/assembly/mousetrap/attack_self(mob/living/user)
	if(!armed)
		to_chat(user, "<span class='notice'>You arm [src].</span>")
	else
		if((user.getBrainLoss() >= 60 || (CLUMSY in user.mutations)) && prob(50))
			triggered(user, user.hand ? BP_L_ARM : BP_R_ARM)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			return
		to_chat(user, "<span class='notice'>You disarm [src].</span>")
	armed = !armed
	update_icon()
	playsound(user, 'sound/weapons/handcuffs.ogg', VOL_EFFECTS_MASTER, 30, null, -3)

/obj/item/device/assembly/mousetrap/attack_hand(mob/living/user)
	if(armed)
		if((user.getBrainLoss() >= 60 || (CLUMSY in user.mutations)) && prob(50))
			user.SetNextMove(CLICK_CD_INTERACT)
			triggered(user, user.hand ? BP_L_ARM : BP_R_ARM)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			return
	..()

/obj/item/device/assembly/mousetrap/Crossed(atom/movable/AM)
	if(armed)
		if(ishuman(AM))
			var/mob/living/carbon/H = AM
			if(H.m_intent == "run")
				triggered(H)
				H.visible_message("<span class='warning'>[H] accidentally steps on [src].</span>", \
								  "<span class='warning'>You accidentally step on [src]</span>")
		if(ismouse(AM))
			triggered(AM)
	. = ..()

/obj/item/device/assembly/mousetrap/on_found(mob/finder)
	if(armed)
		finder.visible_message("<span class='warning'>[finder] accidentally sets off [src], breaking their fingers.</span>", \
							   "<span class='warning'>You accidentally trigger [src]!</span>")
		triggered(finder, finder.hand ? BP_L_ARM : BP_R_ARM)
		return 1	//end the search!
	return 0

/obj/item/device/assembly/mousetrap/hitby(atom/movable/AM, datum/thrownthing/throwingdatum)
	if(!armed)
		return ..()
	visible_message("<span class='warning'>[src] is triggered by [AM].</span>")
	triggered(null)

/obj/item/device/assembly/mousetrap/armed
	icon_state = "mousetraparmed"
	armed = 1

/obj/item/device/assembly/mousetrap/verb/hide_under()
	set src in oview(1)
	set name = "Hide"
	set category = "Object"

	if(usr.incapacitated())
		return

	layer = TURF_LAYER+0.2
	to_chat(usr, "<span class='notice'>You hide [src].</span>")
