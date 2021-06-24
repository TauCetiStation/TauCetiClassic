/obj/effect/proc_holder/borer/active/control/direct_transfer
	name = "Direct Transfer"
	desc = "Allows you to infest the target you are grabbing."
	cost = 3
	var/duration = 10 SECONDS
	cooldown = 60 SECONDS

/obj/effect/proc_holder/borer/active/control/direct_transfer/activate(mob/living/carbon/user)
	if(user.incapacitated())
		to_chat(user, "You cannot perform direct transfer in your current state.")
		return

	var/mob/living/carbon/target
	for(var/obj/item/weapon/grab/G in user.GetGrabs())
		if(G.state >= GRAB_NECK)
			target = G.affecting
			break
	if(!target)
		to_chat(user, "<span class='warning'>You need to grab your target by neck!</span>")
		return
	if(target.has_brain_worms())
		to_chat(user, "You cannot infest someone who is already infested!")
		return
	var/mob/living/simple_animal/borer/B = user.has_brain_worms()
	if(!B?.infest_check(target))	
		return
	user.visible_message("<span class='warning'>[user] leans over [target] shoulder and hugs them tightly.</span>")

	user.release_control()
	user.Stun(duration / 10)
	put_on_cd()
	to_chat(target, "Something slimy begins probing at the opening of your ear canal...")
	to_chat(B, "You slither up [target] and begin probing at their ear canal...")
	if(!do_after(B, duration, target = target))
		return
	if(!B.infest_check(target, FALSE))
		return
	B.let_go()
	B.infest(target)

	for(var/obj/item/weapon/grab/G in user.GetGrabs())
		if(G.affecting == target)
			user.drop_from_inventory(G)
