/obj/effect/proc_holder/spell/targeted/glare
	name = "Glare"
	desc = "Stuns and mutes a target for a decent duration."
	panel = "Shadowling Abilities"
	charge_max = 300
	clothes_req = 0

/obj/effect/proc_holder/spell/targeted/glare/cast(list/targets)
	for(var/mob/living/carbon/human/target in targets)
		if(target.species.flags[NO_SCAN] || target.species.flags[IS_SYNTHETIC])
			charge_counter = charge_max
			to_chat(usr, "<span class='warning'>Your glare does not seem to affect [target].</span>")
			return
		if(target.stat)
			charge_counter = charge_max
			return
		if(is_shadow_or_thrall(target))
			to_chat(usr, "<span class='danger'>You don't see why you would want to paralyze an ally.</span>")
			charge_counter = charge_max
			return

		usr.visible_message("<span class='warning'><b>[usr]'s eyes flash a blinding red!</b></span>")
		target.visible_message("<span class='danger'>[target] freezes in place, their eyes glazing over...</span>")
		if(in_range(target, usr))
			to_chat(target, "<span class='userdanger'>Your gaze is forcibly drawn into [src]'s eyes, and you are mesmerized by the heavenly lights...</span>")
		else //Only alludes to the shadowling if the target is close by
			to_chat(target, "<span class='userdanger'>Red lights suddenly dance in your vision, and you are mesmerized by their heavenly beauty...</span>")
		target.Stun(10)
		target.silent += 10



/obj/effect/proc_holder/spell/aoe_turf/veil
	name = "Veil"
	desc = "Extinguishes most nearby light sources."
	panel = "Shadowling Abilities"
	charge_max = 250 //Short cooldown because people can just turn the lights back on
	clothes_req = 0
	range = 5

/obj/effect/proc_holder/spell/aoe_turf/veil/cast(list/targets)
	to_chat(usr, "<span class='shadowling'>You silently disable all nearby lights.</span>")
	light_off_range(targets, usr)

/proc/light_off_range(list/targets, atom/center)
	var/list/blacklisted_lights = list(/obj/item/device/flashlight/flare, /obj/item/device/flashlight/slime, /obj/item/weapon/reagent_containers/food/snacks/glowstick)
	for(var/turf/T in targets)
		for(var/obj/item/F in T.contents)
			if(is_type_in_list(F, blacklisted_lights))
				F.visible_message("<span class='danger'>[F] goes slightly dim for a moment.</span>")
				return
			F.set_light(0)

		for(var/obj/machinery/light/L in T.contents)
			L.on = 0
			L.visible_message("<span class='danger'>[L] flickers and falls dark.</span>")
			L.update(0)

		for(var/mob/living/carbon/human/H in T.contents)
			for(var/obj/item/F in H)
				if(is_type_in_list(F, blacklisted_lights))
					F.visible_message("<span class='danger'>[F] goes slightly dim for a moment.</span>")
					return
				F.set_light(0)
			H.set_light(0) //This is required with the object-based lighting

		for(var/obj/machinery/door/airlock/A in T.contents)
			if(get_dist(center, A) <= 4)
				if(A.lights && A.hasPower())
					A.lights = 0
					A.update_icon()

		for(var/obj/effect/glowshroom/G in T.contents)
			if(get_dist(center, G) <= 2) //Very small radius
				G.visible_message("<span class='warning'>\The [G] withers away!</span>")
				qdel(G)

/obj/effect/proc_holder/spell/targeted/shadow_walk
	name = "Shadow Walk"
	desc = "Phases you into the space between worlds for a short time, allowing movement through walls and invisbility."
	panel = "Shadowling Abilities"
	charge_max = 600
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/shadow_walk/cast(list/targets)
	for(var/mob/living/user in targets)
		playsound(user, 'sound/effects/bamf.ogg', VOL_EFFECTS_MASTER)
		user.visible_message("<span class='warning'>[user] vanishes in a puff of black mist!</span>", "<span class='shadowling'>You enter the space between worlds as a passageway.</span>")
		user.SetStunned(0)
		user.SetWeakened(0)
		user.incorporeal_move = 1
		user.alpha = 0
		if(user.buckled)
			user.buckled.unbuckle_mob()
		sleep(40) //4 seconds
		user.visible_message("<span class='warning'>[user] suddenly manifests!</span>", "<span class='shadowling'>The pressure becomes too much and you vacate the interdimensional darkness.</span>")
		user.incorporeal_move = 0
		user.alpha = 255
		user.eject_from_wall(gib = TRUE)


/obj/effect/proc_holder/spell/aoe_turf/flashfreeze
	name = "Flash Freeze"
	desc = "Instantly freezes the blood of nearby people, stunning them and causing burn damage."
	panel = "Shadowling Abilities"
	range = 5
	charge_max = 1200
	clothes_req = 0

/obj/effect/proc_holder/spell/aoe_turf/flashfreeze/cast(list/targets)
	to_chat(usr, "<span class='shadowling'>You freeze the nearby air.</span>")
	playsound(usr, 'sound/effects/ghost2.ogg', VOL_EFFECTS_MASTER)

	for(var/turf/T in targets)
		for(var/mob/living/carbon/human/target in T.contents)
			if(is_shadow_or_thrall(target))
				if(target == usr) //No message for the user, of course
					continue
				else
					to_chat(target, "<span class='danger'>You feel a blast of paralyzingly cold air wrap around you and flow past, but you are unaffected!</span>")
					continue
			to_chat(target, "<span class='userdanger'>You are hit by a blast of paralyzingly cold air and feel goosebumps break out across your body!</span>")
			target.Stun(2)
			if(target.bodytemperature)
				target.bodytemperature -= 200 //Extreme amount of initial cold
			if(target.reagents)
				target.reagents.add_reagent("frostoil", 15) //Half of a cryosting



//Enthrall is the single most important spell
/obj/effect/proc_holder/spell/targeted/enthrall
	name = "Enthrall"
	desc = "Allows you to enslave a conscious, non-braindead, non-catatonic human to your will. This takes some time to cast."
	panel = "Shadowling Abilities"
	charge_max = 450
	clothes_req = 0
	range = 1 //Adjacent to user
	var/enthralling = 0

/obj/effect/proc_holder/spell/targeted/enthrall/cast(list/targets)
	var/thrallsPresent = 0
	var/mob/living/carbon/human/user = usr
	for(var/datum/mind/mindToCount in SSticker.mode.thralls)
		thrallsPresent++
	if(thrallsPresent >= 5 && (user.dna.species != SHADOWLING))
		to_chat(user, "<span class='warning'>With your telepathic abilities suppressed, your human form will not allow you to enthrall any others. Hatch first.</span>")
		charge_counter = charge_max
		return
	for(var/mob/living/carbon/human/target in targets)
		if(!in_range(usr, target))
			to_chat(usr, "<span class='warning'>You need to be closer to enthrall [target].</span>")
			charge_counter = charge_max
			return
		if(!target.key)
			to_chat(usr, "<span class='warning'>The target has no mind.</span>")
			charge_counter = charge_max
			return
		if(target.stat)
			to_chat(usr, "<span class='warning'>The target must be conscious.</span>")
			charge_counter = charge_max
			return
		if(is_shadow_or_thrall(target))
			to_chat(usr, "<span class='warning'>You can not enthrall allies.</span>")
			charge_counter = charge_max
			return
		var/datum/species/S = all_species[target.get_species()]
		if(!ishuman(target) || (S && S.flags[NO_EMOTION]))
			to_chat(usr, "<span class='warning'>You can only enthrall humans.</span>")
			charge_counter = charge_max
			return
		if(enthralling)
			to_chat(usr, "<span class='warning'>You are already enthralling!</span>")
			charge_counter = charge_max
			return
		if(!target.client)
			to_chat(usr, "<span class='warning'>[target]'s mind is vacant of activity. Still, you may rearrange their memories in the case of their return.</span>")
		enthralling = 1
		to_chat(usr, "<span class='danger'>This target is valid. You begin the enthralling.</span>")
		to_chat(target, "<span class='userdanger'>[usr] stares at you. You feel your head begin to pulse.</span>")

		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					to_chat(usr, "<span class='notice'>You begin allocating energy for the enthralling.</span>")
					usr.visible_message("<span class='warning'>[usr]'s eyes begin to throb a piercing red.</span>")
				if(2)
					to_chat(usr, "<span class='notice'>You begin the enthralling of [target].</span>")
					usr.visible_message("<span class='danger'>[usr] leans over [target], their eyes glowing a deep crimson, and stares into their face.</span>")
					to_chat(target, "<span class='boldannounce'>Your gaze is forcibly drawn into a blinding red light. You fall to the floor as conscious thought is wiped away.</span>")
					target.Weaken(12)
					sleep(20)
					if(ismindshielded(target))
						to_chat(usr, "<span class='notice'>They are enslaved by Nanotrasen. You begin to shut down the nanobot implant - this will take some time.</span>")
						usr.visible_message("<span class='danger'>[usr] halts for a moment, then begins passing its hand over [target]'s body.</span>")
						to_chat(target, "<span class='boldannounce'>You feel your loyalties begin to weaken!</span>")
						sleep(150) //15 seconds - not spawn() so the enthralling takes longer
						to_chat(usr, "<span class='notice'>The nanobots composing the loyalty implant have been rendered inert. Now to continue.</span>")
						usr.visible_message("<span class='danger'>[usr] halts thier hand and resumes staring into [target]'s face.</span>")
						for(var/obj/item/weapon/implant/mindshield/L in target)
							if(L.implanted)
								qdel(L)
								to_chat(target, "<span class='boldannounce'>Your unwavering volition unexpectedly falters, dims, dies. You feel a sense of true terror.</span>")
				if(3)
					to_chat(usr, "<span class='notice'>You begin rearranging [target]'s memories.</span>")
					usr.visible_message("<span class='danger'>[usr]'s eyes flare brightly, their unflinching gaze staring constantly at [target].</span>")
					to_chat(target, "<span class='boldannounce'>Your head cries out. The veil of reality begins to crumple and something evil bleeds through.</span>")//Ow the edge
			if(!do_mob(usr, target, 100)) //around 30 seconds total for enthralling
				to_chat(usr, "<span class='warning'>The enthralling has been interrupted - your target's mind returns to its previous state.</span>")
				to_chat(target, "<span class='userdanger'>A spike of pain drives into your head. You aren't sure what's happened, but you feel a faint sense of revulsion.</span>")
				enthralling = 0
				return

		enthralling = 0
		to_chat(usr, "<span class='shadowling'>You have enthralled <b>[target]</b>!</span>")
		target.visible_message("<span class='big'>[target]'s expression appears as if they have experienced a revelation!</span>", \
		"<span class='shadowling'><b>You see the Truth. Reality has been torn away and you realize what a fool you've been.</b></span>")
		to_chat(target, "<span class='shadowling'><b>The shadowlings are your masters.</b> Serve them above all else and ensure they complete their goals.</span>")
		to_chat(target, "<span class='shadowling'>You may not harm other thralls or the shadowlings. However, you do not need to obey other thralls.</span>")
		to_chat(target, "<span class='shadowling'>You can communicate with the other enlightened ones by using the Hivemind Commune ability.</span>")
		target.setOxyLoss(0) //In case the shadowling was choking them out
		SSticker.mode.add_thrall(target.mind)
		target.mind.special_role = "thrall"
		//var/datum/mind/thrall_mind = target.mind
		//thrall_mind.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind //Lets thralls hive-chat



/obj/effect/proc_holder/spell/targeted/shadowling_hivemind
	name = "Hivemind Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Shadowling Abilities"
	charge_max = 0
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/shadowling_hivemind/cast(list/targets)
	for(var/mob/living/user in targets)
		var/text = sanitize(input(user, "What do you want to say to fellow thralls and shadowlings?.", "Hive Chat", ""))
		if(!text)
			return
		log_say("Shadowling Hivemind: [key_name(usr)] : [text]")
		for(var/mob/M in mob_list)
			if(is_shadow_or_thrall(M) || isobserver(M))
				to_chat(M, "<span class='shadowling'><b>\[Hive Chat\]</b><i> [usr.real_name]</i>: [text]</span>")



/obj/effect/proc_holder/spell/targeted/shadowling_regenarmor
	name = "Regenerate Chitin"
	desc = "Re-forms protective chitin that may be lost during cloning or similar processes."
	panel = "Shadowling Abilities"
	charge_max = 600
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/shadowling_regenarmor/cast(list/targets)
	for(var/mob/living/user in targets)
		user.visible_message("<span class='warning'>[user]'s skin suddenly bubbles and begins to shift around their body!</span>", \
							 "<span class='shadowling'>You regenerate your protective armor and cleanse your form of defects.</span>")
		for(var/obj/item/I in user)
			if(I.flags & ABSTRACT)
				qdel(I)
			else
				user.remove_from_mob(I)

		user.equip_to_slot_or_del(new /obj/item/clothing/under/shadowling, SLOT_W_UNIFORM)
		user.equip_to_slot_or_del(new /obj/item/clothing/shoes/shadowling, SLOT_SHOES)
		user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling, SLOT_WEAR_SUIT)
		user.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling, SLOT_HEAD)
		user.equip_to_slot_or_del(new /obj/item/clothing/gloves/shadowling, SLOT_GLOVES)
		user.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/shadowling, SLOT_WEAR_MASK)
		user.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/shadowling, SLOT_GLASSES)
		var/mob/living/carbon/human/H = usr
		H.set_species(SHADOWLING)
		H.dna.mutantrace = "shadowling"
		H.update_mutantrace()
		H.regenerate_icons()

/obj/effect/proc_holder/spell/targeted/collective_mind
	name = "Collective Hivemind"
	desc = "Gathers the power of all of your thralls and compares it to what is needed for ascendance. Also gains you new abilities."
	panel = "Shadowling Abilities"
	charge_max = 300 //30 second cooldown to prevent spam
	clothes_req = 0
	range = -1
	include_user = 1
	var/blind_smoke_acquired
	var/screech_acquired
	var/drainLifeAcquired
	var/reviveThrallAcquired

/obj/effect/proc_holder/spell/targeted/collective_mind/cast(list/targets)
	for(var/mob/living/user in targets)
		var/thralls = 0
		var/victory_threshold = 15
		var/mob/M

		to_chat(user, "<span class='shadowling'><b>You focus your telepathic energies abound, harnessing and drawing together the strength of your thralls.</b></span>")

		for(M in alive_mob_list)
			if(is_thrall(M))
				thralls++
				to_chat(M, "<span class='shadowling'>You feel hooks sink into your mind and pull.</span>")

		if(!do_after(user, 30, target = user))
			to_chat(user, "<span class='warning'>Your concentration has been broken. The mental hooks you have sent out now retract into your mind.</span>")
			return

		if(thralls >= 3 && !blind_smoke_acquired)
			blind_smoke_acquired = 1
			to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Blinding Smoke</b> ability. It will create a choking cloud that will blind any non-thralls who enter. \
			</i></span>")
			user.spell_list += new /obj/effect/proc_holder/spell/targeted/blindness_smoke

		if(thralls >= 5 && !drainLifeAcquired)
			drainLifeAcquired = 1
			to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Drain Life</b> ability. You can now drain the health of nearby humans to heal yourself.</i></span>")
			user.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/drainLife

		if(thralls >= 7 && !screech_acquired)
			screech_acquired = 1
			to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Sonic Screech</b> ability. This ability will shatter nearby windows and deafen enemies, plus stunning silicon lifeforms.</i></span>")
			user.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/unearthly_screech

		if(thralls >= 9 && !reviveThrallAcquired)
			reviveThrallAcquired = 1
			to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Black Recuperation</b> ability. This will, after a short time, bring a dead thrall completely back to life \
			with no bodily defects.</i></span>")
			user.spell_list += new /obj/effect/proc_holder/spell/targeted/reviveThrall

		if(thralls < victory_threshold)
			to_chat(user, "<span class='shadowling'>You do not have the power to ascend. You require [victory_threshold] thralls, but only [thralls] living thralls are present.</span>")

		else if(thralls >= victory_threshold)
			to_chat(usr, "<span class='shadowling'><b>You are now powerful enough to ascend. Use the Ascendance ability when you are ready. <i>This will kill all of your thralls.</i></b></span>")
			to_chat(usr, "<span class='shadowling'><b>You may find Ascendance in the Shadowling Evolution tab.</b></span>")
			for(M in alive_mob_list)
				if(is_shadow(M))
					M.mind.current.verbs -= /mob/living/carbon/human/proc/shadowling_hatch //In case a shadowling hasn't hatched
					M.mind.current.verbs += /mob/living/carbon/human/proc/shadowling_ascendance
					for(var/obj/effect/proc_holder/spell/targeted/collective_mind/spell_to_remove in M.spell_list)
						M.RemoveSpell(spell_to_remove)
					if(M == usr)
						to_chat(M, "<span class='shadowling'><i>You project this power to the rest of the shadowlings.</i></span>")
					else
						to_chat(M, "<span class='shadowling'><b>[user.real_name] has coalesced the strength of the thralls. You can draw upon it at any time to ascend. (Shadowling Evolution Tab)</b></span>")//Tells all the other shadowlings



/obj/effect/proc_holder/spell/targeted/blindness_smoke
	name = "Blindness Smoke"
	desc = "Spews a cloud of smoke which will blind enemies."
	panel = "Shadowling Abilities"
	charge_max = 600
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/blindness_smoke/cast(list/targets) //Extremely hacky
	for(var/mob/living/user in targets)
		user.visible_message("<span class='warning'>[user] suddenly bends over and coughs out a cloud of black smoke, which begins to spread rapidly!</span>")
		to_chat(user, "<span class='shadowling'>You regurgitate a vast cloud of blinding smoke.</span>")
		playsound(user, 'sound/effects/bamf.ogg', VOL_EFFECTS_MASTER)
		var/datum/effect/effect/system/smoke_spread/chem/S = new
		var/turf/location = get_turf(user)
		create_reagents(10)
		reagents.add_reagent("blindness_smoke", 10)
		S.attach(location)
		S.set_up(reagents, 10, 0, location, 15, 5)
		S.start()

/datum/reagent/shadowling_blindness_smoke //Blinds non-shadowlings, heals shadowlings/thralls
	name = "Odd Black Liquid"
	id = "blindness_smoke"
	description = "<::ERROR::> CANNOT ANALYZE REAGENT <::ERROR::>"
	color = "#000000" //Complete black (RGB: 0, 0, 0)
	//metabolization_rate = 100 //lel
	custom_metabolism = 100

/datum/reagent/shadowling_blindness_smoke/on_general_digest(mob/living/M)
	..()
	if(!is_shadow_or_thrall(M))
		to_chat(M, "<span class='warning bold'>You breathe in the black smoke, and your eyes burn horribly!</span>")
		M.eye_blind = 5
		if(prob(25))
			M.visible_message("<b>[M]</b> claws at their eyes!")
			M.Stun(3)
	else
		to_chat(M, "<span class='notice bold'>You breathe in the black smoke, and you feel revitalized!</span>")
		M.heal_bodypart_damage(2, 2)
		M.adjustOxyLoss(-2)
		M.adjustToxLoss(-2)

/obj/effect/proc_holder/spell/aoe_turf/unearthly_screech
	name = "Sonic Screech"
	desc = "Deafens, stuns, and confuses nearby people. Also shatters windows."
	panel = "Shadowling Abilities"
	range = 7
	charge_max = 300
	clothes_req = 0

/obj/effect/proc_holder/spell/aoe_turf/unearthly_screech/cast(list/targets)
	//usr.audible_message("<span class='warning'><b>[usr] lets out a horrible scream!</b></span>")
	usr.emote("scream", SHOWMSG_AUDIO, message = "<span class='warning'><b>lets out a horrible scream!</b></span>", auto = FALSE)
	playsound(usr, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER)

	for(var/turf/T in targets)
		for(var/mob/target in T.contents)
			if(is_shadow_or_thrall(target))
				if(target == usr) //No message for the user, of course
					continue
				else
					continue
			if(iscarbon(target))
				var/mob/living/carbon/M = target
				to_chat(M, "<span class='danger'><b>A spike of pain drives into your head and scrambles your thoughts!</b></span>")
				M.Weaken(2)
				M.confused += 10
				//M.setEarDamage(M.ear_damage + 3)
				M.ear_damage += 3
			else if(issilicon(target))
				var/mob/living/silicon/S = target
				to_chat(S, "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSOR OVERLOAD \[$(!@#</b></span>")
				playsound(S, 'sound/misc/interference.ogg', VOL_EFFECTS_MASTER)
				var/datum/effect/effect/system/spark_spread/sp = new /datum/effect/effect/system/spark_spread
				sp.set_up(5, 1, S)
				sp.start()
				S.Weaken(6)
		for(var/obj/structure/window/W in T.contents)
			W.take_damage(rand(80, 100))



/obj/effect/proc_holder/spell/aoe_turf/drainLife
	name = "Drain Life"
	desc = "Damages nearby humans, draining their life and healing your own wounds."
	panel = "Shadowling Abilities"
	range = 3
	charge_max = 250
	clothes_req = 0
	var/targetsDrained
	var/list/nearbyTargets

/obj/effect/proc_holder/spell/aoe_turf/drainLife/cast(list/targets, mob/living/carbon/human/U = usr)
	targetsDrained = 0
	nearbyTargets = list()
	for(var/turf/T in targets)
		for(var/mob/living/carbon/M in T.contents)
			targetsDrained++
			nearbyTargets.Add(M)
		for(var/mob/living/carbon/M in nearbyTargets)
			nearbyTargets.Remove(M) //To prevent someone dying like a zillion times
			U.heal_bodypart_damage(10, 10)
			U.adjustToxLoss(-10)
			U.adjustOxyLoss(-10)
			U.AdjustWeakened(-1)
			U.AdjustStunned(-1)
			M.adjustOxyLoss(20)
			to_chat(M, "<span class='boldannounce'>You feel a wave of exhaustion and a curious draining sensation directed towards [usr]!</span>")
			to_chat(usr, "<span class='shadowling'>You draw the life from [M] to heal your wounds.</span>")
	if(!targetsDrained)
		charge_counter = charge_max
		to_chat(usr, "<span class='warning'>There were no nearby humans for you to drain.</span>")



/obj/effect/proc_holder/spell/targeted/reviveThrall
	name = "Black Recuperation"
	desc = "Brings a dead thrall back to life."
	panel = "Shadowling Abilities"
	range = 1
	charge_max = 3000
	clothes_req = 0
	include_user = 0
	var/list/thralls_in_world = list()

/obj/effect/proc_holder/spell/targeted/reviveThrall/cast(list/targets)
	for(var/mob/living/carbon/human/thrallToRevive in targets)
		if(!is_thrall(thrallToRevive))
			to_chat(usr, "<span class='warning'>[thrallToRevive] is not a thrall.</span>")
			charge_counter = charge_max
			return
		if(thrallToRevive.stat != DEAD)
			to_chat(usr, "<span class='warning'>[thrallToRevive] is not dead.</span>")
			charge_counter = charge_max
			return
		usr.visible_message("<span class='danger'>[usr] kneels over [thrallToRevive], placing their hands on \his chest.</span>", \
							"<span class='shadowling'>You crouch over the body of your thrall and begin gathering energy...</span>")
		var/mob/dead/observer/ghost = thrallToRevive.get_ghost()
		if(ghost)
			to_chat(ghost, "<span class='ghostalert'>Your masters are resuscitating you! Return to your corpse if you wish to be brought to life.</span> (Verbs -> Ghost -> Re-enter corpse)")
			ghost.playsound_local(null, 'sound/effects/genetics.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)
		if(!do_mob(usr, thrallToRevive, 100))
			to_chat(usr, "<span class='warning'>Your concentration snaps. The flow of energy ebbs.</span>")
			charge_counter= charge_max
			return
		to_chat(usr, "<span class='shadowling'><b><i>You release a massive surge of energy into [thrallToRevive]!</b></i></span>")
		usr.visible_message("<span class='boldannounce'><i>Red lightning surges from [usr]'s hands into [thrallToRevive]'s chest!</i></span>")
		playsound(thrallToRevive, 'sound/weapons/Egloves.ogg', VOL_EFFECTS_MASTER)
		playsound(thrallToRevive, 'sound/machines/defib_zap.ogg', VOL_EFFECTS_MASTER)
		sleep(20)
		thrallToRevive.revive()
		thrallToRevive.timeofdeath = 0
		thrallToRevive.tod = null
		thrallToRevive.visible_message("<span class='boldannounce'>[thrallToRevive] draws in a huge breath, blinding violet light shining from their eyes.</span>", \
									   "<span class='shadowling'><b><i>You have returned. One of your masters has brought you from the darkness beyond.</b></i></span>")
		thrallToRevive.Weaken(4)
		thrallToRevive.emote("gasp")
		playsound(thrallToRevive, pick(SOUNDIN_BODYFALL), VOL_EFFECTS_MASTER)

// ASCENDANT ABILITIES BEYOND THIS POINT //

/obj/effect/proc_holder/spell/targeted/annihilate
	name = "Annihilate"
	desc = "Gibs a human after a short time."
	panel = "Ascendant"
	range = 7
	charge_max = 50
	clothes_req = 0

/obj/effect/proc_holder/spell/targeted/annihilate/cast(list/targets)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = usr
	if(SHA.phasing)
		to_chat(usr, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		charge_counter = charge_max
		return

	for(var/mob/boom in targets)
		if(is_shadow_or_thrall(boom))
			to_chat(usr, "<span class='warning'>Making an ally explode seems unwise.</span>")
			charge_counter = charge_max
			return
		usr.visible_message("<span class='danger'>[usr]'s eyes flare as they gesture at [boom]!</span>", \
							"<span class='shadowling'>You direct a lance of telekinetic energy at [boom].</span>")
		to_chat(boom, "<span class='userdanger'><font size=3>You feel an immense pressure building all across your body!</span></font>")
		boom.Stun(10)
		//boom.audible_message("<b>[boom]</b> screams!")
		boom.emote("scream")
		sleep(20)
		if(istype(boom,/mob/living/simple_animal/hostile/carp/dog))
			to_chat(SHA,"<span class='shadowling'>Probably, trying to explode [boom] wasn't good idea....</span>")
			boom = usr
		playsound(boom, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)
		boom.visible_message("<span class='userdanger'>[boom] explodes!</span>")
		boom.gib()



/obj/effect/proc_holder/spell/targeted/hypnosis
	name = "Hypnosis"
	desc = "Instantly enthralls a human."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = 0

/obj/effect/proc_holder/spell/targeted/hypnosis/cast(list/targets)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = usr
	if(SHA.phasing)
		charge_counter = charge_max
		to_chat(usr, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		return

	for(var/mob/living/carbon/human/target in targets)
		if(is_shadow_or_thrall(target))
			to_chat(usr, "<span class='warning'>You cannot enthrall an ally.</span>")
			charge_counter = charge_max
			return
		if(!target.ckey)
			to_chat(usr, "<span class='warning'>The target has no mind.</span>")
			charge_counter = charge_max
			return
		if(target.stat)
			to_chat(usr, "<span class='warning'>The target must be conscious.</span>")
			charge_counter = charge_max
			return
		var/datum/species/S = all_species[target.get_species()]
		if(!ishuman(target) || (S && S.flags[NO_EMOTION]))
			to_chat(usr, "<span class='warning'>You can only enthrall humans.</span>")
			charge_counter = charge_max
			return

		to_chat(usr, "<span class='shadowling'>You instantly rearrange <b>[target]</b>'s memories, hyptonitizing them into a thrall.</span>")
		to_chat(target, "<span class='userdanger'><font size=3>An agonizing spike of pain drives into your mind, and--</font></span>")
		to_chat(target, "<span class='shadowling'><b>And you see the Truth. Reality has been torn away and you realize what a fool you've been.</b></span>")
		to_chat(target, "<span class='shadowling'><b>The shadowlings are your masters.</b> Serve them above all else and ensure they complete their goals.</span>")
		to_chat(target, "<span class='shadowling'>You may not harm other thralls or the shadowlings. However, you do not need to obey other thralls.</span>")
		to_chat(target, "<span class='shadowling'>You can communicate with the other enlightened ones by using the Hivemind Commune ability.</span>")
		SSticker.mode.add_thrall(target.mind)
		target.mind.special_role = "thrall"
		target.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind



/obj/effect/proc_holder/spell/targeted/shadowling_phase_shift
	name = "Phase Shift"
	desc = "Phases you into the space between worlds at will, allowing you to move through walls and become invisible."
	panel = "Ascendant"
	range = -1
	include_user = 1
	charge_max = 15
	clothes_req = 0

/obj/effect/proc_holder/spell/targeted/shadowling_phase_shift/cast(list/targets)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = usr
	for(SHA in targets)
		SHA.phasing = !SHA.phasing
		if(SHA.phasing)
			SHA.visible_message("<span class='danger'>[SHA] suddenly vanishes!</span>", \
			"<span class='shadowling'>You begin phasing through planes of existence. Use the ability again to return.</span>")
			SHA.incorporeal_move = 1
			SHA.alpha = 0
		else
			SHA.visible_message("<span class='danger'>[SHA] suddenly appears from nowhere!</span>", \
			"<span class='shadowling'>You return from the space between worlds.</span>")
			SHA.incorporeal_move = 0
			SHA.alpha = 255



/obj/effect/proc_holder/spell/aoe_turf/glacial_blast
	name = "Glacial Blast"
	desc = "Extremely empowered version of Flash Freeze."
	panel = "Ascendant"
	range = 5
	charge_max = 100
	clothes_req = 0

/obj/effect/proc_holder/spell/aoe_turf/glacial_blast/cast(list/targets)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = usr
	if(SHA.phasing)
		to_chat(usr, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		return

	to_chat(usr, "<span class='shadowling'>You freeze the nearby air.</span>")
	playsound(usr, 'sound/effects/ghost2.ogg', VOL_EFFECTS_MASTER)

	for(var/turf/T in targets)
		for(var/mob/living/carbon/human/target in T.contents)
			if(is_shadow_or_thrall(target))
				if(target == usr) //No message for the user, of course
					continue
				else
					to_chat(target, "<span class='danger'>You feel a blast of paralyzingly cold air wrap around you and flow past, but you are unaffected!</span>")
					continue
			to_chat(target, "<span class='userdanger'>You are hit by a blast of cold unlike anything you have ever felt. Your limbs instantly lock in place and you feel ice burns across your body!</span>")
			target.Weaken(15)
			if(target.bodytemperature)
				target.bodytemperature -= INFINITY //:^)
			target.take_bodypart_damage(0, 80)



/obj/effect/proc_holder/spell/targeted/shadowling_hivemind_ascendant
	name = "Ascendant Commune"
	desc = "Allows you to LOUDLY communicate with all other shadowlings and thralls."
	panel = "Ascendant"
	charge_max = 0
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/shadowling_hivemind_ascendant/cast(list/targets)
	for(var/mob/living/user in targets)
		var/text = sanitize(input(user, "What do you want to say to fellow thralls and shadowlings?.", "Hive Chat", ""))
		if(!text)
			return
		for(var/mob/M in mob_list)
			if(is_shadow_or_thrall(M) || (M in dead_mob_list))
				to_chat(M, "<font size=4><span class='shadowling'><b>\[Hive Chat\]<i> [usr.real_name] (ASCENDANT)</i>: [sanitize(text)]</b></font></span>")//Bigger text for ascendants.



/obj/effect/proc_holder/spell/targeted/shadowlingAscendantTransmit
	name = "Ascendant Broadcast"
	desc = "Sends a message to the whole wide world."
	panel = "Ascendant"
	charge_max = 200
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/shadowlingAscendantTransmit/cast(list/targets)
	for(var/mob/living/user in targets)
		var/text = sanitize(input(user, "What do you want to say to everything on and near [station_name()]?.", "Transmit to World", ""))
		if(!text)
			return
		to_chat(world, "<font size=4><span class='shadowling'><b>\"[sanitize(text)]\"</b></font></span>")
