/mob/living/carbon/xenomorph/humanoid/hunter/lone
	name = "Alien"
	icon = 'icons/mob/xenomorph_solo.dmi'
	icon_state = "alien_s"
	caste = ""
	pixel_x = -8
	ventcrawler = 0
	storedPlasma = 200
	max_plasma = 200
	maxHealth = 200
	health = 200
	heal_rate = 0	// no passive regeneration
	sight = SEE_TURFS | SEE_MOBS
	alien_spells = list(/obj/effect/proc_holder/spell/no_target/weeds)
	acid_type = /obj/effect/alien/acid/queen_acid
	var/epoint = 0
	var/estage = 1
	var/list/alien_attack = list(
		'sound/antag/Alien_sounds/alien_attack1.ogg',
		'sound/antag/Alien_sounds/alien_attack2.ogg')
	var/list/alien_eat_corpse = list(
		'sound/antag/Alien_sounds/alien_eat_corpse1.ogg',
		'sound/antag/Alien_sounds/alien_eat_corpse2.ogg',
		'sound/antag/Alien_sounds/alien_eat_corpse3.ogg',
		'sound/antag/Alien_sounds/alien_eat_corpse4.ogg')
	var/list/eaten_human = list()
	var/list/alien_actions = list(
		/datum/action/innate/alien/find_human,
		/datum/action/innate/alien/eat_corpse,
		/datum/action/innate/alien/regeneration)
	var/scary_music_next_time = 0
	var/current_scary_music = null
	var/adrenaline_next_time = 0
	var/datum/map_module/alien/MM = null
	var/mob/living/carbon/human/hunt_target = null
	var/next_observation = 0
	var/list/observation_human = list()

/mob/living/carbon/xenomorph/humanoid/hunter/lone/atom_init()
	. = ..()
	MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)
	if(MM)
		MM.alien_appeared(src)
		speed = -0.8
	else
		ventcrawler = 2
	name = "Alien"
	real_name = name
	alien_list[ALIEN_HUNTER] -= src			// ¯\_(ツ)_/¯
	alien_list[ALIEN_LONE_HUNTER] += src
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid)
	for(var/action in alien_actions)
		var/datum/action/A = new action(src)
		A.Grant(src)
	playsound(src, 'sound/voice/xenomorph/big_hiss.ogg', VOL_EFFECTS_MASTER)

/mob/living/carbon/xenomorph/humanoid/hunter/lone/Life()
	..()
	if(estage == 1 && world.time > next_observation)
		for(var/mob/living/carbon/human/H in oview(6, src))
			if(!(H in observation_human) && (src in oview(6, H)))
				to_chat(src, "<span class='notice'>Человек вас заметил. Вы получили очко эволюции.</span>")
				next_observation = world.time + 30 SECONDS
				observation_human += H
				emote("hiss")
				epoint++
				break

/mob/living/carbon/xenomorph/humanoid/hunter/lone/Destroy()
	alien_list[ALIEN_LONE_HUNTER] -= src
	return ..()

//		ALIEN TAKE ADDITIONAL FIRE DAMAGE
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

//		ADRENALINE
/mob/living/carbon/xenomorph/humanoid/hunter/lone/adjustFireLoss(amount)
	..()
	try_adrenaline()
/mob/living/carbon/xenomorph/humanoid/hunter/lone/adjustBruteLoss(amount)
	..()
	try_adrenaline()
/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/try_adrenaline()
	if(estage < 5 && world.time > adrenaline_next_time && health < (maxHealth / 3))
		adrenaline_next_time = world.time + 8 MINUTE
		apply_status_effect(STATUS_EFFECT_ALIEN_ADRENALINE)
		emote("roar")
		for(var/obj/machinery/light/L in range(5, src))
			L.flicker()

//		STATISTICS
/mob/living/carbon/xenomorph/humanoid/hunter/lone/Stat()
	if(statpanel("Status"))
		stat("Очков эволюции: [epoint]")
		stat("Стадия эволюции: [estage]")
		stat("Съедено людей: [eaten_human.len]")

//			SCREAMER WHEN LEAP
/mob/living/carbon/xenomorph/humanoid/hunter/lone/successful_leap(mob/living/L)
	play_scary_music()

//		HUNT AND ADRENALINE AFFECT THE ATTACK
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

//		SCARY MUSIC WHEN ATTACK
/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/play_scary_music()
	if(MM && world.time > scary_music_next_time)
		MM.delay_ambience(30 SECONDS)
		current_scary_music = pick(alien_attack - current_scary_music)
		scary_music_next_time = world.time + 1 MINUTE
		for(var/mob/M in range(7, src))
			M.playsound_music(current_scary_music, VOL_AMBIENT, null, null, CHANNEL_AMBIENT, priority = 255)

//		SLAUGHTER MODE WHEN SHIP BREAKDOWN
/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/set_slaughter_mode()
	to_chat(src, "<span class='notice'>Да начнётся резня! Ваши характеристики повышены.</span>")
	for(var/i in estage to 5)
		next_stage(msg_play = FALSE)
	alien_spells += /obj/effect/proc_holder/spell/targeted/screech

//		EAT CORPSE
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
		emote("growl")
		apply_status_effect(STATUS_EFFECT_ALIEN_REGENERATION)

		var/mob/living/carbon/human/H = G.affecting
		for(var/obj/item/organ/external/BP as anything in H.bodyparts)
			do_after(src, 5 SECOND, target = H)
			if(can_eat_corpse(G))
				if(prob(30))
					to_chat(src, "<span class='notice'>Вы [pick(
						"сдираете кожу с [CASE(BP, GENITIVE_CASE)]",
						"обгладываете [CASE(BP, ACCUSATIVE_CASE)]",
						"отрываете кусок мяса от [CASE(BP, GENITIVE_CASE)]")] человека.</span>")
				playsound(src, pick(alien_eat_corpse), VOL_EFFECTS_MASTER)
				H.apply_damage(50, BRUTE, BP)
				give_epoint(1)
			else
				break
		remove_status_effect(STATUS_EFFECT_ALIEN_REGENERATION)
		eaten_human += H

//		EVOLUTION POINT
/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/give_epoint(amount)
	epoint += amount
	if(epoint >= 6)
		epoint -= 6
		next_stage()

//		NEXT STAGE
/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/next_stage(msg_play = TRUE)
	if(msg_play)
		to_chat(src, "<span class='notice'>Вы перешли на новую стадию эволюции!</span>")
	estage++
	maxHealth += 20
	max_plasma += 20

//		ACTIONS
/datum/action/innate/alien
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_ALIVE

/datum/action/innate/alien/Grant(mob/T)
	if(!isxeno(T))
		qdel(src)
		return
	. = ..()

//		FIND HUMAN
/datum/action/innate/alien/find_human
	name = "Найти одиночку."
	button_icon_state = "find_human"
	cooldown = 1 MINUTE

/datum/action/innate/alien/find_human/Activate()
	var/mob/living/carbon/human/target = null
	var/list/checked_human = list()

	for(var/mob/living/carbon/human/H as anything in human_list)
		if(H.stat == DEAD || (H in checked_human) || !is_station_level(H.z) || !H.species.flags[FACEHUGGABLE])
			checked_human += H
			continue
		var/list/around = range(7, get_turf(H))
		var/list/human_around = list()
		for(var/mob/living/carbon/human/H2 in around)
			if(H.stat)
				human_around += H2
		if(human_around.len < 3) // 2 humans
			target = H
			break
		else
			checked_human += human_around

	if(target)
		var/atom/movable/screen/arrow/arrow_hud = new
		arrow_hud.color = COLOR_DARK_PURPLE
		arrow_hud.add_hud(owner, target)
	else
		to_chat(owner, "<span class='warning'>Вы не смогли учуять одинокого человека.</span>")

	owner.emote("hiss")
	StartCooldown()

//		EAT CORPSE
/datum/action/innate/alien/eat_corpse
	name = "Съесть тело."
	button_icon_state = "eat_corpse"
	cooldown = 3 MINUTE

/datum/action/innate/alien/eat_corpse/Grant(mob/T)
	if(!isxenolonehunter(T))
		qdel(src)
		return
	. = ..()

/datum/action/innate/alien/eat_corpse/Activate()
	var/mob/living/carbon/xenomorph/humanoid/hunter/lone/L = owner
	if(L)
		L.eat_corpse()
		StartCooldown()

//		REGENERATION
/datum/action/innate/alien/regeneration
	name = "Залечить раны."
	button_icon_state = "alien_regeneration"
	cooldown = 3 MINUTE

/datum/action/innate/alien/regeneration/Activate()
	var/mob/living/carbon/xenomorph/X = owner

	if(!(locate(/obj/structure/alien/weeds) in X.loc) || !X.crawling)
		to_chat(X, "<span class='warning'>Вы должны лежать на траве.</span>")
		return

	X.apply_status_effect(STATUS_EFFECT_ALIEN_REGENERATION)
	StartCooldown()
	if(!do_after(X, 10 SECONDS, target = X))
		X.remove_status_effect(STATUS_EFFECT_ALIEN_REGENERATION)

//		STATUS EFFECTS
//		HUNT
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

//		ADRENALINE
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
	owner.fire_stacks = 0
	. = ..()

/datum/status_effect/alien_adrenaline/on_remove()
	to_chat(owner, "<span class='notice'>Ваше сердце медленно успокаивается.</span>")
	owner.speed += 1

//		REGENERATION
/atom/movable/screen/alert/status_effect/alien_regeneration
	name = "Регенерация"
	desc = "Ваши раны заживают."
	icon_state = "alien_regeneration"

/datum/status_effect/alien_regeneration
	id = "alien_adrenaline"
	duration = 10 SECOND
	alert_type = /atom/movable/screen/alert/status_effect/alien_regeneration

/datum/status_effect/alien_regeneration/tick()
	var/regen = -12
	var/damage_count = 0
	if(isxenolonehunter(owner))
		var/mob/living/carbon/xenomorph/humanoid/hunter/lone/alien = owner
		regen -= alien.estage

	if(owner.getBruteLoss())
		damage_count++
	if(owner.getFireLoss())
		damage_count++
	if(owner.getOxyLoss())
		damage_count++

	if(damage_count)
		owner.adjustBruteLoss(regen / damage_count) // regenerate 120 + 10*estage damage
		owner.adjustFireLoss(regen / damage_count)
		owner.adjustOxyLoss(regen / damage_count)
