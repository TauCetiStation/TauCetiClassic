/obj/effect/proc_holder/spell/targeted/fakehypnosis
	name = "Гипноз"
	desc = "Проводит ритуал гипноза цели."
	charge_type = "recharge"
	charge_max = 450
	charge_counter = 0
	stat_allowed = 0
	range = 1
	selection_type = "view"
	panel = "Spells"
	action_icon_state = "genetic_view"
	clothes_req = 0

/obj/effect/proc_holder/spell/targeted/fakehypnosis/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/human/target in targets)
		if(!target.key || !target.client)
			to_chat(user, "<span class='warning'>The target has no mind.</span>")
			return
		if(target.stat != CONSCIOUS)
			to_chat(user, "<span class='warning'>The target must be conscious.</span>")
			return
		if(target.ismindprotect())
			to_chat(user, "<span class='notice'>Their mind seems to be protected!</span>")
			return
		//beginning
		user.visible_message("<span class='userdanger'>[user] stares at [target]. You feel your head begin to pulse.</span>" , \
		"<span class='warning'>This target is valid. You begin the hypnosis!</span>" )
		//stage 1
		if(!do_after(user, 50, target = target))
			to_chat(user, "<span class='warning'>The hypnosis has been interrupted - your target's mind returns to its previous state.</span>")
			to_chat(target, "<span class='userdanger'>A spike of pain drives into your head. You aren't sure what's happened, but you feel a faint sense of revulsion.</span>")
			return
		user.visible_message("<span class='warning'>[user]'s eyes begin to throb a piercing red.</span>" , \
		"<span class='notice'>You begin allocating energy for the hypnosis.</span>" )
		//stage 2
		if(!do_after(user, 100, target = target))
			to_chat(user, "<span class='warning'>The hypnosis has been interrupted - your target's mind returns to its previous state.</span>")
			to_chat(target, "<span class='userdanger'>A spike of pain drives into your head. You aren't sure what's happened, but you feel a faint sense of revulsion.</span>")
			return
		user.visible_message("<span class='danger'>[user] leans over [target], their eyes glowing a deep crimson, and stares into their face.</span>" , \
		"<span class='notice'>You begin the hypnosis of [target].</span>" )
		to_chat(target, "<span class='boldannounce'>Your gaze is forcibly drawn into a blinding red light. You fall to the floor as conscious thought is wiped away.</span>")
		target.AdjustWeakened(12)
		//stage 3
		if(!do_after(user, 100, target = target))
			to_chat(user, "<span class='warning'>The hypnosis has been interrupted - your target's mind returns to its previous state.</span>")
			to_chat(target, "<span class='userdanger'>A spike of pain drives into your head. You aren't sure what's happened, but you feel a faint sense of revulsion.</span>")
			return
		user.visible_message("<span class='danger'>[user]'s eyes flare brightly, their unflinching gaze staring constantly at [target].</span>" , \
		"<span class='notice'>You begin looking through the [target]'s memories.</span>" )
		to_chat(target, "<span class='boldannounce'>Your head cries out. The veil of reality begins to crumple and something hidden bleeds through.</span>")
		//ending
		if(!do_after(user, 50, target = target))
			to_chat(user, "<span class='warning'>The hypnosis has been interrupted - your target's mind returns to its previous state.</span>")
			to_chat(target, "<span class='userdanger'>A spike of pain drives into your head. You aren't sure what's happened, but you feel a faint sense of revulsion.</span>")
			return
		to_chat(user, "<span class='notice'>You have successfully completed a hypnosis session!</span>")
		target.visible_message("<span class='big'>[target]'s expression appears as if they have experienced a revelation!</span>", \
		"<span class='shadowling'><b>You see the Truth. Reality has been torn away and you realize what a fool you've been.</b></span>" )
