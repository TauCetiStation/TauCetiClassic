/mob/living/carbon/xenomorph/humanoid/hunter/lone
	name = "Alien"
	icon = 'icons/mob/xenomorph_solo.dmi'
	icon_state = "alien_s"
	caste = ""
	pixel_x = -8
	ventcrawler = 0
	storedPlasma = 150
	var/epoint = 0
	var/estage = 1
	var/list/alien_screamer = list(
		'sound/antag/Alien_sounds/alien_screamer1.ogg',
		'sound/antag/Alien_sounds/alien_screamer2.ogg')
	var/list/alien_attack = list(
		'sound/antag/Alien_sounds/alien_attack1.ogg',
		'sound/antag/Alien_sounds/alien_attack2.ogg',
		'sound/antag/Alien_sounds/alien_attack3.ogg')
	var/list/alien_eat_corpse = list(
		'sound/antag/Alien_sounds/alien_eat_corpse1.ogg',
		'sound/antag/Alien_sounds/alien_eat_corpse2.ogg',
		'sound/antag/Alien_sounds/alien_eat_corpse3.ogg',
		'sound/antag/Alien_sounds/alien_eat_corpse4.ogg')
	var/list/eaten_human = list()
	var/scary_music_next_time = 0
	var/current_scary_music
	var/adrenaline_available = TRUE
	var/obj/effect/landmark/nostromo/ambience/ambience_player = null
	var/mob/living/carbon/human/hunt_target = null
	alien_spells = list(/obj/effect/proc_holder/spell/no_target/weeds)
	acid_type = /obj/effect/alien/acid/queen_acid

/mob/living/carbon/xenomorph/humanoid/hunter/lone/atom_init()
	. = ..()
	name = "Alien"
	real_name = name
	alien_list[ALIEN_HUNTER] -= src			// ¯\_(ツ)_/¯
	alien_list[ALIEN_LONE_HUNTER] += src
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid)
	var/datum/action/eat_corpse/A = new(src)
	A.Grant(src)
	if(landmarks_list["Nostromo Ambience"].len)
		var/obj/effect/landmark/L = landmarks_list["Nostromo Ambience"][1]
		if(L)
			ambience_player = L
	playsound(src, 'sound/voice/xenomorph/big_hiss.ogg', VOL_EFFECTS_MASTER)

/mob/living/carbon/xenomorph/humanoid/hunter/lone/Destroy()
	alien_list[ALIEN_LONE_HUNTER] -= src
	return ..()

/mob/living/carbon/xenomorph/humanoid/hunter/lone/Life()
	if(epoint >= 6)
		epoint -= 6
		next_stage()
	if(adrenaline_available && health < (maxHealth / 3))
		adrenaline_available = FALSE
		apply_status_effect(STATUS_EFFECT_ALIEN_ADRENALINE)
	..()

/mob/living/carbon/xenomorph/humanoid/hunter/lone/handle_fire()
	if(..())
		return
	if(fire_stacks > 0)
		adjustFireLoss(fire_stacks * 2)
		fire_stacks--
		fire_stacks = max(0, fire_stacks)
	else
		ExtinguishMob()
		return TRUE

/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/next_stage(msg_play = TRUE)
	if(msg_play)
		to_chat(src, "<span class='notice'>Вы перешли на новую стадию эволюции!</span>")
	estage++
	maxHealth += 20
	heal_rate += 1
	max_plasma += 50
	plasma_rate += 1

	if(estage == 3)
		var/datum/faction/nostromo_crew/NC = find_faction_by_type(/datum/faction/nostromo_crew)
		if(NC)
			NC.spawn_crate()
		adrenaline_available = FALSE

/mob/living/carbon/xenomorph/humanoid/hunter/lone/Stat()
	if(statpanel("Status"))
		stat("Очков эволюции: [epoint]")
		stat("Стадия эволюции: [estage]")
		stat("Съедено людей: [eaten_human.len]")

/mob/living/carbon/xenomorph/humanoid/hunter/lone/successful_leap(mob/living/L)
	for(var/mob/beholder in oview(6, src))
		beholder.playsound_local(null, pick(alien_screamer), VOL_EFFECTS_MASTER, null, FALSE)
	play_scary_music()

/mob/living/carbon/xenomorph/humanoid/hunter/lone/UnarmedAttack(atom/A)
	if(has_status_effect(STATUS_EFFECT_ALIEN_ADRENALINE))
		to_chat(src, "<span class='warning'>Вы вот-вот умрёте, нужно бежать!</span>")
		SetNextMove(CLICK_CD_MELEE)
		return
	A.attack_alien(src)
	if(a_intent == INTENT_HARM)
		if(ishuman(A))
			var/mob/living/carbon/human/H = A
			if(!H.stat)
				if(prob(30))
					say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
				play_scary_music()
				if(!hunt_target && (estage < 5)) //
					apply_status_effect(STATUS_EFFECT_ALIEN_HUNT, H)

				if(estage >= 5 || hunt_target == H)
					SetNextMove(CLICK_CD_MELEE / 2)
				else
					SetNextMove(CLICK_CD_MELEE * 5)
				return
	if(ismob(A))
		SetNextMove(CLICK_CD_MELEE)

/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/play_scary_music()
	if(ambience_player && world.time > scary_music_next_time)
		current_scary_music = pick(alien_attack - current_scary_music)
		ambience_player.ambience_next_time += 0.5 MINUTE
		scary_music_next_time = world.time + 1 MINUTE
		for(var/mob/M in range(7, src))
			M.playsound_music(current_scary_music, VOL_AMBIENT, null, null, CHANNEL_AMBIENT, priority = 255)

/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/set_slaughter_mode()
	to_chat(src, "<span class='notice'>Да начнётся резня! Ваши характеристики повышены.</span>")
	for(var/i in estage to 5)
		next_stage(msg_play = FALSE)

/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/can_eat_corpse(obj/item/weapon/grab/G)
	if(incapacitated())
		to_chat(src, "<span class='warning'>Невозможно делать это в текущем состоянии.</span>")
		return FALSE

	if(!G || !istype(G))
		to_chat(src, "<span class='warning'>Сначала нужно схватить тело.</span>")
		return FALSE

	if(!ishuman(G.affecting))
		to_chat(src, "<span class='warning'>Это должен быть человек!</span>")
		return FALSE

	var/mob/living/carbon/human/H = G.affecting
	if(!H.species.flags[FACEHUGGABLE])
		to_chat(src, "<span class='warning'>Это невозможно съесть!</span>")
		return FALSE

	if(H in eaten_human)
		to_chat(src, "<span class='warning'>Это тело уже всё обглодано!</span>")
		return FALSE

	if(H.stat == DEAD && (world.time - H.timeofdeath) >= DEFIB_TIME_LIMIT)
		to_chat(src, "<span class='warning'>Уже начался процесс разложения, это тело неупотребимо в пищу!</span>")
		return FALSE

	if(G.state < GRAB_NECK)
		to_chat(src, "<span class='warning'>Нужно схватить тело покрепче!</span>")
		return FALSE

	return TRUE

/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/eat_corpse()
	var/obj/item/weapon/grab/G = locate() in src

	if(can_eat_corpse(G))
		to_chat(src, "<span class='notice'>Вы приступили к трапезе.</span>")
		var/mob/living/carbon/human/H = G.affecting
		for(var/obj/item/organ/external/BP as anything in H.bodyparts)
			do_after(src, 50, target = H)
			if(can_eat_corpse(G))
				if(prob(30))
					to_chat(src, "<span class='notice'>Вы [pick(
						"сдираете кожу с [CASE(BP, GENITIVE_CASE)]",
						"обгладываете [CASE(BP, ACCUSATIVE_CASE)]",
						"отрываете кусок мяса от [CASE(BP, GENITIVE_CASE)]")] человека.</span>")
				playsound(src, pick(alien_eat_corpse), VOL_EFFECTS_MASTER)
				H.apply_damage(50, BRUTE, BP)
				epoint++
			else
				break
		eaten_human += H

/datum/action/eat_corpse
	name = "Съесть тело."
	check_flags = AB_CHECK_ALIVE
	action_type = AB_INNATE
	button_icon_state = "eat_corpse"
	background_icon_state = "bg_alien"

/datum/action/eat_corpse/Activate()
	var/mob/living/carbon/xenomorph/humanoid/hunter/lone/L = owner
	if(L)
		L.eat_corpse()

/atom/movable/screen/alert/status_effect/alien_hunt
	name = "Охота"
	desc = "Вы избрали себе цель, цель должна умереть! Вы не можете атаковать никого кроме цели!"
	icon_state = "alien_hunt"

/datum/status_effect/alien_hunt
	id = "alien_hunt"
	duration = 3 MINUTE
	alert_type = /atom/movable/screen/alert/status_effect/alien_hunt

/datum/status_effect/alien_hunt/on_creation(mob/living/new_owner, mob/living/target)
	. = ..()
	if(!.)
		return
	if(isxenolonehunter(owner))
		var/mob/living/carbon/xenomorph/humanoid/hunter/lone/L = owner
		L.hunt_target = target

/datum/status_effect/alien_hunt/on_remove()
	if(isxenolonehunter(owner))
		var/mob/living/carbon/xenomorph/humanoid/hunter/lone/L = owner
		L.hunt_target = null

/atom/movable/screen/alert/status_effect/alien_adrenaline
	name = "Адреналин"
	desc = "Уносим ноги, пока целы!"
	icon_state = "alien_adrenaline"

/datum/status_effect/alien_adrenaline
	id = "alien_adrenaline"
	duration = 20 SECOND
	alert_type = /atom/movable/screen/alert/status_effect/alien_adrenaline

/datum/status_effect/alien_adrenaline/on_apply()
	to_chat(owner, "<span class='warning'>БЕГИТЕ ПОКА ЖИВЫ!</span>")
	owner.stat = CONSCIOUS
	owner.SetParalysis(0)
	owner.SetStunned(0)
	owner.SetWeakened(0)
	owner.speed -= 1
	. = ..()

/datum/status_effect/alien_adrenaline/on_remove()
	to_chat(owner, "<span class='notice'>Ваше сердце медленно успокаивается.</span>")
	owner.speed += 1
