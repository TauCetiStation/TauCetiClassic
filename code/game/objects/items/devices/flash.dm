/obj/item/device/flash
	name = "flash"
	desc = "Used for blinding and being an asshole."
	icon_state = "flash"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	throw_speed = 4
	throw_range = 10
	flags = CONDUCT
	origin_tech = "magnets=2;combat=1"

	action_button_name = "Toggle Flash"

	light_color = LIGHT_COLOR_WHITE
	light_power = FLASH_LIGHT_POWER

	var/times_used = 0 //Number of times it's been used.
	var/broken = 0     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.

/obj/item/device/flash/proc/clown_check(mob/user)
	if(user && (CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>\The [src] slips out of your hand.</span>")
		user.drop_item()
		return 0
	return 1

/obj/item/device/flash/proc/flash_recharge()
	//capacitor recharges over time
	for(var/i=0, i<3, i++)
		if(last_used+600 > world.time)
			break
		last_used += 600
		times_used -= 2
	last_used = world.time
	times_used = max(0,round(times_used)) //sanity


/obj/item/device/flash/attack(mob/living/M, mob/user)
	if(!user || !M)	return	//sanity

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='red'>You don't have the dexterity to do this!</span>")
		return

	M.log_combat(user, "flashed (attempt) with [name]")

	if(!clown_check(user))	return
	if(broken)
		to_chat(user, "<span class='warning'>\The [src] is broken.</span>")
		return

	flash_recharge()

	//spamming the flash before it's fully charged (60seconds) increases the chance of it  breaking
	//It will never break on the first use.
	switch(times_used)
		if(0 to 5)
			flash_lighting_fx(FLASH_LIGHT_RANGE, light_power, light_color)
			last_used = world.time
			if(prob(times_used))	//if you use it 5 times in a minute it has a 10% chance to break!
				broken = 1
				to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
				icon_state = "flashburnt"
				return
			times_used++
		else	//can only use it  5 times a minute
			to_chat(user, "<span class='warning'>*click* *click*</span>")
			return
	playsound(src, 'sound/weapons/flash.ogg', VOL_EFFECTS_MASTER)
	var/flashfail = 0

	if(iscarbon(M))
		var/safety = M:eyecheck()
		if(safety <= 0)
			M.confused = max(rand(6, 10), M.confused)
			M.flash_eyes()

			if(ishuman(M) && ishuman(user) && M.stat!=DEAD)

				if(user.mind && (user.mind in SSticker.mode.head_revolutionaries) && SSticker.mode.name == "revolution")
					if(M.client)
						if(M.stat == CONSCIOUS)
							M.mind_initialize()		//give them a mind datum if they don't have one.
							var/resisted
							if(!ismindshielded(M) && !jobban_isbanned(M, ROLE_REV) && !jobban_isbanned(M, "Syndicate") && !role_available_in_minutes(M, ROLE_REV))
								if(user.mind in SSticker.mode.head_revolutionaries)
									M.mind.has_been_rev = 1
									if(!SSticker.mode.add_revolutionary(M.mind))
										resisted = 1
							else
								resisted = 1

							if(resisted)
								to_chat(user, "<span class='warning'>This mind seems resistant to the flash!</span>")
		else
			flashfail = 1

	else if(issilicon(M))
		//M.Weaken(rand(5,10))
		var/power = rand(7,13)
		M.confused = min(M.confused + power, 20)
		M.eye_blind = min(M.eye_blind + power, 20)
	else
		flashfail = 1

	if(isrobot(user))
		spawn(0)
			var/atom/movable/overlay/animation = new(user.loc)
			animation.layer = user.layer + 1
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = user
			flick("blspell", animation)
			sleep(5)
			qdel(animation)

	if(!flashfail)
		flick("flash2", src)
		if(!issilicon(M))

			user.visible_message("<span class='disarm'>[user] blinds [M] with the flash!</span>")
		else

			user.visible_message("<span class='notice'>[user] overloads [M]'s sensors with the flash!</span>")
	else

		user.visible_message("<span class='notice'>[user] fails to blind [M] with the flash!</span>")

	return




/obj/item/device/flash/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!user || !clown_check(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The [src.name] is broken</span>")
		return

	flash_recharge()

	//spamming the flash before it's fully charged (60seconds) increases the chance of it  breaking
	//It will never break on the first use.
	switch(times_used)
		if(0 to 5)
			if(prob(2*times_used))	//if you use it 5 times in a minute it has a 10% chance to break!
				broken = 1
				to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
				icon_state = "flashburnt"
				return
			times_used++
		else	//can only use it  5 times a minute
			to_chat(user, "<span class='warning'>*click* *click*</span>")
			return
	playsound(src, 'sound/weapons/flash.ogg', VOL_EFFECTS_MASTER)
	flick("flash2", src)
	if(user && isrobot(user))
		spawn(0)
			var/atom/movable/overlay/animation = new(user.loc)
			animation.layer = user.layer + 1
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = user
			flick("blspell", animation)
			sleep(5)
			qdel(animation)

	for(var/mob/living/carbon/M in oviewers(6, null))
		var/safety = M:eyecheck()
		if(!safety)
			if(!M.blinded)
				M.flash_eyes()

	return

/obj/item/device/flash/emp_act(severity)
	if(broken)	return
	flash_recharge()
	switch(times_used)
		if(0 to 5)
			if(prob(2*times_used))
				broken = 1
				icon_state = "flashburnt"
				return
			times_used++
			if(istype(loc, /mob/living/carbon))
				var/mob/living/carbon/M = loc
				var/safety = M.eyecheck()
				if(safety <= 0)
					M.Weaken(10)
					M.flash_eyes()
					M.visible_message("<span class='disarm'>[M] is blinded by the flash!</span>")
	..()

/obj/item/device/flash/synthetic
	name = "synthetic flash"
	desc = "When a problem arises, SCIENCE is the solution."
	icon_state = "sflash"
	origin_tech = "magnets=2;combat=1"

/obj/item/device/flash/synthetic/attack(mob/living/M, mob/user)
	..()
	if(!broken)
		broken = 1
		to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
		icon_state = "flashburnt"

/obj/item/device/flash/synthetic/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	..()
	if(!broken)
		broken = 1
		to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
		icon_state = "flashburnt"
