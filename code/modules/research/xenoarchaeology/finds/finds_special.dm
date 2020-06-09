
// endless reagents!
/obj/item/weapon/reagent_containers/glass/replenishing
	var/spawning_id

/obj/item/weapon/reagent_containers/glass/replenishing/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	spawning_id = pick("blood", "holywater", "unholywater", "lube", "stoxin", "beer", "glycerol", "fuel", "cleaner")

/obj/item/weapon/reagent_containers/glass/replenishing/process()
	reagents.add_reagent(spawning_id, 0.3)

// a talking gas mask!
/obj/item/clothing/mask/gas/poltergeist
	var/list/heard_talk = list()
	var/last_twitch = 0
	var/max_stored_messages = 100

/obj/item/clothing/mask/gas/poltergeist/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

var/list/bad_messages = list("Never take me off, please!",
		"They all want to wear me... But I'm yours!",
		"They're all want to take me from you! Bastards!",
		"We are one",
		"I want to be only yours!",
		"Help me!")

/obj/item/clothing/mask/gas/poltergeist/process(mob/living/H)
	if(heard_talk.len && istype(src.loc, /mob/living) && prob(20))
		var/mob/living/M = src.loc
		M.say(pick(heard_talk))
	if(istype(src.loc, /mob/living) && prob(2))
		var/mob/living/M = src.loc
		to_chat(M, "A strange voice goes through your head: <font color='red' size='[num2text(rand(1,3))]'><b>[pick(bad_messages)]</b></font>")

/obj/item/clothing/mask/gas/poltergeist/hear_talk(mob/M, text)
	..()
	if(heard_talk.len > max_stored_messages)
		heard_talk.Remove(pick(heard_talk))
	heard_talk.Add(text)
	if(istype(src.loc, /mob/living) && world.time - last_twitch > 50)
		last_twitch = world.time



// a vampiric statuette
// todo: cult integration
/obj/item/weapon/vampiric
	name = "statuette"
	icon_state = "statuette"
	icon = 'icons/obj/xenoarchaeology/finds.dmi'
	var/charges = 0
	var/list/nearby_mobs = list()
	var/last_bloodcall = 0
	var/bloodcall_interval = 50
	var/last_eat = 0
	var/eat_interval = 100
	var/wight_check_index = 1
	var/list/shadow_wights = list()

/obj/item/weapon/vampiric/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/vampiric/process()
	// see if we've identified anyone nearby
	if(world.time - last_bloodcall > bloodcall_interval && nearby_mobs.len)
		var/mob/living/carbon/human/M = pop(nearby_mobs)
		if(M in view(7,src) && M.health > 20)
			if(prob(50))
				bloodcall(M)
				nearby_mobs.Add(M)

	// suck up some blood to gain power
	if(world.time - last_eat > eat_interval)
		var/obj/effect/decal/cleanable/blood/B = locate() in range(2,src)
		if(B)
			last_eat = world.time
			B.loc = null
			if(istype(B, /obj/effect/decal/cleanable/blood/drip))
				charges += 0.25
			else
				charges += 1
				playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER, null, null, -3)

	// use up stored charges
	if(charges >= 10)
		charges -= 10
		new /obj/effect/spider/eggcluster(pick(view(1,src)))

	if(charges >= 3)
		if(prob(5))
			charges -= 1
			var/spawn_type = pick(/mob/living/simple_animal/hostile/creature)
			new spawn_type(pick(view(1,src)))
			playsound(src, pick('sound/voice/growl1.ogg', 'sound/voice/growl2.ogg', 'sound/voice/growl3.ogg'), VOL_EFFECTS_MASTER, null, null, -3)

	if(charges >= 1)
		if(shadow_wights.len < 5 && prob(5))
			shadow_wights.Add(new /obj/effect/shadow_wight(src.loc))
			playsound(src, 'sound/effects/ghost.ogg', VOL_EFFECTS_MASTER, null, null, -3)
			charges -= 0.1

	if(charges >= 0.1)
		if(prob(5))
			src.visible_message("<span class='warning'>[bicon(src)] [src]'s eyes glow ruby red for a moment!</span>")
			charges -= 0.1

	// check on our shadow wights
	if(shadow_wights.len)
		wight_check_index++
		if(wight_check_index > shadow_wights.len)
			wight_check_index = 1

		var/obj/effect/shadow_wight/W = shadow_wights[wight_check_index]
		if(isnull(W))
			shadow_wights.Remove(wight_check_index)
		else if(isnull(W.loc))
			shadow_wights.Remove(wight_check_index)
		else if(get_dist(W, src) > 10)
			shadow_wights.Remove(wight_check_index)

/obj/item/weapon/vampiric/hear_talk(mob/M, text)
	..()
	if(world.time - last_bloodcall >= bloodcall_interval && (M in view(7, src)))
		bloodcall(M)

/obj/item/weapon/vampiric/proc/bloodcall(mob/living/carbon/human/M)
	last_bloodcall = world.time
	if(istype(M))
		playsound(src, pick('sound/hallucinations/wail.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/far_noise.ogg'), VOL_EFFECTS_MASTER, null, null, -3)
		nearby_mobs.Add(M)

		var/target = pick(BP_CHEST , BP_GROIN , BP_HEAD , BP_L_ARM , BP_R_ARM , BP_R_LEG , BP_L_LEG)
		M.apply_damage(rand(5, 10), BRUTE, target)
		to_chat(M, "<span class='warning'>The skin on your [parse_zone(target)] feels like it's ripping apart, and a stream of blood flies out.</span>")
		var/obj/effect/decal/cleanable/blood/splatter/animated/B = new(M.loc)
		B.target_turf = pick(range(1, src))
		B.blood_DNA = list()
		B.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
		M.vessel.remove_reagent("blood",rand(25,50))

// animated blood 2 SPOOKY
/obj/effect/decal/cleanable/blood/splatter/animated
	var/turf/target_turf
	var/loc_last_process

/obj/effect/decal/cleanable/blood/splatter/animated/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	loc_last_process = loc

/obj/effect/decal/cleanable/blood/splatter/animated/process()
	if(target_turf && src.loc != target_turf)
		step_towards(src,target_turf)
		if(src.loc == loc_last_process)
			target_turf = null
		loc_last_process = src.loc

		// leave some drips behind
		if(prob(50))
			var/obj/effect/decal/cleanable/blood/drip/D = new(src.loc)
			D.blood_DNA = src.blood_DNA.Copy()
			if(prob(50))
				D = new(src.loc)
				D.blood_DNA = src.blood_DNA.Copy()
				if(prob(50))
					D = new(src.loc)
					D.blood_DNA = src.blood_DNA.Copy()
	else
		..()

/obj/effect/shadow_wight
	name = "shadow wight"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	density = 1

/obj/effect/shadow_wight/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/shadow_wight/process()
	if(src.loc)
		src.loc = get_turf(pick(orange(1,src)))
		var/mob/living/carbon/M = locate() in src.loc
		if(M)
			var/list/hallsound = list('sound/hallucinations/behind_you1.ogg',
			                          'sound/hallucinations/behind_you2.ogg',
			                          'sound/hallucinations/i_see_you_1.ogg',
			                          'sound/hallucinations/i_see_you_2.ogg',
			                          'sound/hallucinations/im_here1.ogg',
			                          'sound/hallucinations/im_here2.ogg',
			                          'sound/hallucinations/look_up1.ogg',
			                          'sound/hallucinations/look_up2.ogg',
			                          'sound/hallucinations/over_here1.ogg',
			                          'sound/hallucinations/over_here2.ogg',
			                          'sound/hallucinations/over_here3.ogg',
			                          'sound/hallucinations/turn_around1.ogg',
			                          'sound/hallucinations/turn_around2.ogg')
			playsound(src, pick(hallsound), VOL_EFFECTS_MASTER, null, FALSE, -3)
			M.SetSleeping(max(M.AmountSleeping(), rand(5 SECONDS, 10 SECONDS)))
			src.loc = null
	else
		STOP_PROCESSING(SSobj, src)

/obj/effect/shadow_wight/Bump(var/atom/obstacle)
	to_chat(obstacle, "<span class='warning'>You feel a chill run down your spine!</span>")


 // healing tool
/obj/item/weapon/strangetool
	name = "strange device"
	desc = "This device is made of metal, emits a strange purple formation of unknown origin."
	icon = 'icons/obj/xenoarchaeology/finds.dmi'
	icon_state = "strange_tool"
	var/last_time_used = 0

/obj/item/weapon/strangetool/attack(mob/M, mob/user, def_zone)
	emmit_healing(M)

/obj/item/weapon/strangetool/attack_self(mob/user)
	emmit_healing(user)

/obj/item/weapon/strangetool/proc/emmit_healing(mob/M)
	if(last_time_used + 50 < world.time)
		visible_message("<span class='notice'><font color='purple'>[bicon(src)]Device blinks brightly.</font></span>")
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			to_chat(C, "<span class='notice'><font color='blue'>You feel a soothing energy invigorate you.</font></span>")
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				for(var/obj/item/organ/external/BP in H.bodyparts)
					BP.heal_damage(rand(20,30), rand(20,30))
				H.vessel.add_reagent("blood", 5)
				H.nutrition += rand(30, 40)
				H.adjustBrainLoss(rand(-10, -25))
				H.radiation -= min(H.radiation, rand(20, 30))
				H.bodytemperature = initial(H.bodytemperature)
				spawn(1)
					H.fixblood()

			C.adjustOxyLoss(rand(-40, -20))
			C.adjustToxLoss(rand(-40, -20))
			C.adjustBruteLoss(rand(-40, -20))
			C.adjustFireLoss(rand(-40, -20))

			C.regenerate_icons()

		last_time_used = world.time
	else
		visible_message("<span class='notice'><font color='red'>[bicon(src)] Device blinks faintly.</font></span>")
