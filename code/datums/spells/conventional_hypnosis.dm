/obj/effect/proc_holder/spell/targeted/сonventional_hypnosis
	name = "Гипноз"
	desc = "Проводит ритуал гипноза цели."
	charge_type = "recharge"
	charge_max = 450
	charge_counter = 0
	stat_allowed = 0
	range = 1
	selection_type = "view"
	panel = "IC"
	action_icon_state = "genetic_view"
	clothes_req = 0
	var/session_started = FALSE

/obj/effect/proc_holder/spell/targeted/hypnosis/cast(list/targets, mob/user = usr)
	charge_counter = charge_max
	for(var/mob/living/carbon/human/target in targets)
		if(!in_range(user, target))
			to_chat(user, "<span class='warning'>You must be closer to the [target] for that.</span>")
			return
		if(!target.key || !target.client)
			to_chat(user, "<span class='warning'>The target has no mind.</span>")
			return
		if(target.stat != CONSCIOUS)
			to_chat(user, "<span class='warning'>The target must be conscious.</span>")
			return
		if(target.ismindprotect())
			to_chat(user, "<span class='notice'>Their mind seems to be protected!</span>")
			return
		if(session_started)
			to_chat(user, "<span class='warning'>You are already hypnotizing!</span>")
			return
		session_started = TRUE
		user.visible_message("<span class='userdanger'>[user] stares at [target]. You feel your head begin to pulse.</span>" , \
		"<span class='warning'>This target is valid. You begin the hypnosis!</span>" )

		if(!do_after(user, 50, target = target))
			to_chat(user, "<span class='warning'>The hypnosis has been interrupted - your target's mind returns to its previous state.</span>")
			to_chat(target, "<span class='userdanger'>A spike of pain drives into your head. You aren't sure what's happened, but you feel a faint sense of revulsion.</span>")
			enthralling = FALSE
			return
		user.visible_message("<span class='warning'>[user]'s eyes begin to throb a piercing red.</span>" , \
		"<span class='notice'>You begin allocating energy for the hypnosis.</span>" )

		if(!do_after(user, 100, target = target))
			to_chat(user, "<span class='warning'>The hypnosis has been interrupted - your target's mind returns to its previous state.</span>")
			to_chat(target, "<span class='userdanger'>A spike of pain drives into your head. You aren't sure what's happened, but you feel a faint sense of revulsion.</span>")
			enthralling = FALSE
			return
		user.visible_message("<span class='danger'>[user] leans over [target], their eyes glowing a deep crimson, and stares into their face.</span>" , \
		"<span class='notice'>You begin the hypnosis of [target].</span>" )
		to_chat(target, "<span class='boldannounce'>Your gaze is forcibly drawn into a blinding red light. You fall to the floor as conscious thought is wiped away.</span>")
		target.AdjustWeakened(12)

		if(!do_after(user, 100, target = target))
			to_chat(user, "<span class='warning'>The hypnosis has been interrupted - your target's mind returns to its previous state.</span>")
			to_chat(target, "<span class='userdanger'>A spike of pain drives into your head. You aren't sure what's happened, but you feel a faint sense of revulsion.</span>")
			enthralling = FALSE
			return
		user.visible_message("<span class='danger'>[user]'s eyes flare brightly, their unflinching gaze staring constantly at [target].</span>" , \
		"<span class='notice'>You begin looking through the [target]'s memories.</span>" )
		to_chat(target, "<span class='boldannounce'>Your head cries out. The veil of reality begins to crumple and something hidden bleeds through.</span>")

		enthralling = FALSE
		to_chat(user, "<span class='notice'>You have successfully completed a hypnosis session!</span>")
		target.visible_message("<span class='big'>[target]'s expression appears as if they have experienced a revelation!</span>", \
		"<span class='shadowling'><b>You see the Truth. Reality has been torn away and you realize what a fool you've been.</b></span>" )
