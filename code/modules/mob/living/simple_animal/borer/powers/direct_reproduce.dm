/obj/effect/proc_holder/borer/active/control/direct_reproduce
	name = "Direct Reproduction"
	desc = "Allows you to infest the target you are grabbing with your offspring."
	cost = 3
	var/duration = 10 SECONDS
	cooldown = 60 SECONDS
	chemicals = 100
	requires_upgrades = list(/obj/effect/proc_holder/borer/active/control/direct_transfer)

/obj/effect/proc_holder/borer/active/control/direct_reproduce/activate()
	. = FALSE
	var/mob/living/carbon/user = holder.host
	if(user.is_busy())
		return
	var/mob/living/carbon/target
	for(var/obj/item/weapon/grab/G in user.GetGrabs())
		if(G.state >= GRAB_NECK)
			target = G.affecting
			break
	if(!target)
		to_chat(user, "<span class='warning'>You need to grab your target by neck!</span>")
		return
	if(target.get_brain_worms())
		to_chat(user, "You cannot infest someone who is already infested!")
		return
	// check if we can infest it. if we can, probably, our children can too
	if(!holder.infest_check(target))	
		return
	user.visible_message("<span class='warning'>[user] leans over [target] shoulder and hugs them tightly.</span>")
	if(!do_after(holder, duration, target = target))
		return
	if(!can_activate())
		return
	. = TRUE
	var/mob/living/simple_animal/borer/baby = holder.reproduce()
	to_chat(target, "Something slimy begins probing at the opening of your ear canal...")
	to_chat(baby, "You slither up [target] and begin probing at their ear canal...")
	if(!baby.infest_check(target))
		return
	baby.infest(target)
