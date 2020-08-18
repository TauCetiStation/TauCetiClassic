/*
 * Gang Boss Pens
 */
/obj/item/weapon/pen/gang
	origin_tech = "materials=2;syndicate=5"
	var/cooldown

/obj/item/weapon/pen/gang/attack(mob/living/M, mob/user)
	if(!istype(M))	return
	if(!ismob(M))
		return

	M.log_combat(user, "stabbed with [name]")

	if(ishuman(M) && ishuman(user) && M.stat != DEAD)
		if(user.mind && ((user.mind in SSticker.mode.A_bosses) || (user.mind in SSticker.mode.B_bosses)))
			if(cooldown)
				to_chat(user, "<span class='warning'>[src] needs more time to recharge before it can be used.</span>")
				return
			if(M.client)
				M.mind_initialize()		//give them a mind datum if they don't have one.
				if(user.mind in SSticker.mode.A_bosses)
					var/recruitable = SSticker.mode.add_gangster(M.mind,"A")
					switch(recruitable)
						if(2)
							M.Paralyse(5)
							cooldown(max(0,SSticker.mode.B_gang.len - SSticker.mode.A_gang.len))
						if(1)
							to_chat(user, "<span class='warning'>This mind is resistant to recruitment!</span>")
						else
							to_chat(user, "<span class='warning'>This mind has already been recruited into a gang!</span>")
				else if(user.mind in SSticker.mode.B_bosses)
					var/recruitable = SSticker.mode.add_gangster(M.mind,"B")
					switch(recruitable)
						if(2)
							M.Paralyse(5)
							cooldown(max(0,SSticker.mode.A_gang.len - SSticker.mode.B_gang.len))
						if(1)
							to_chat(user, "<span class='warning'>This mind is resistant to recruitment!</span>")
						else
							to_chat(user, "<span class='warning'>This mind has already been recruited into a gang!</span>")
	return

/obj/item/weapon/pen/gang/proc/cooldown(modifier)
	cooldown = 1
	icon_state = "pen_blink"
	spawn(max(50,1800-(modifier*300)))
		cooldown = 0
		icon_state = "pen"
		var/mob/M = get(src, /mob)
		to_chat(M, "<span class='notice'>[bicon(src)] [src][(src.loc == M)?(""):(" in your [src.loc]")] vibrates softly.</span>")
