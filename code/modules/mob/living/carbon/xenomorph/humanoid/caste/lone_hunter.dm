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
	var/epoint_cap = 600
	var/list/alien_screamer = list(
		'sound/antag/Alien_sounds/alien_screamer1.ogg',
		'sound/antag/Alien_sounds/alien_screamer2.ogg')
	var/list/alien_attack = list(
		'sound/antag/Alien_sounds/alien_attack1.ogg',
		'sound/antag/Alien_sounds/alien_attack2.ogg',
		'sound/antag/Alien_sounds/alien_attack3.ogg')
	var/next_scary_music = 0
	var/obj/effect/landmark/nostromo_ambience/ambience_player
	alien_spells = list(/obj/effect/proc_holder/spell/no_target/weeds)

/mob/living/carbon/xenomorph/humanoid/hunter/lone/atom_init()
	. = ..()
	name = "Alien"
	real_name = name
	alien_list[ALIEN_HUNTER] -= src			// ¯\_(ツ)_/¯
	alien_list[ALIEN_LONE_HUNTER] += src
	if(landmarks_list["Nostromo Ambience"].len != 0)
		ambience_player = landmarks_list["Nostromo Ambience"][1]

/mob/living/carbon/xenomorph/humanoid/hunter/Destroy()
	alien_list[ALIEN_LONE_HUNTER] -= src
	return ..()

// Со временем ксенос должен становиться сильнее, чтобы экипаж не мог закрыться где-то и сидеть в обороне
/mob/living/carbon/xenomorph/humanoid/hunter/lone/Life()
	if(!invisible)
		epoint += 1
	if (epoint > epoint_cap)
		next_stage()
	. = ..()

// Чтоб не мог на траве афк инвиз стоять
/mob/living/carbon/xenomorph/humanoid/hunter/handle_environment()
	..()
	if(invisible && (locate(/obj/structure/alien/weeds) in loc))
		if(crawling)
			adjustToxLoss(plasma_rate - 1)
		else
			adjustToxLoss(plasma_rate/2 - 1)

/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/next_stage()
	to_chat(src, "<span class='notice'>Вы перешли на новую стадию эволюции!</span>")
	estage++
	maxHealth += 40
	heal_rate += 1
	max_plasma += 50
	plasma_rate += 2
	epoint -= epoint_cap
	switch(estage)
		if (2)
			verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid, /mob/living/carbon/xenomorph/humanoid/proc/neurotoxin)
		if (4)
			alien_spells += /obj/effect/proc_holder/spell/targeted/screech
		if (5)
			acid_type = /obj/effect/alien/acid/queen_acid
			epoint_cap = 2000

/mob/living/carbon/xenomorph/humanoid/hunter/lone/Stat()
	stat(null)
	if(statpanel("Status"))
		stat("Очки эволюции: [epoint]/[epoint_cap]")
		stat("Стадия эволюции: [estage]")

// Если включается одно, выключается другое
/mob/living/carbon/xenomorph/humanoid/hunter/lone/toggle_neurotoxin(message = TRUE)
	..()
	if(leap_on_click)
		leap_on_click = 0
		leap_icon.update_icon(src)
		update_icons()

/mob/living/carbon/xenomorph/humanoid/hunter/lone/toggle_leap(message = TRUE)
	..()
	if(neurotoxin_on_click)
		neurotoxin_on_click = 0
		neurotoxin_icon.icon_state = "neurotoxin0"
		update_icons()

// Ксенос должен поощряться за активную и агрессивную игру
/mob/living/carbon/xenomorph/humanoid/hunter/lone/successful_leap(mob/living/L)
	epoint += 200
	for(var/mob/living/beholder in oview(6, src))
		beholder.playsound_local(null, pick(alien_screamer), VOL_EFFECTS_MASTER, null, FALSE)
	play_scary_music()

/mob/living/carbon/xenomorph/humanoid/hunter/lone/UnarmedAttack(atom/A)
	..()
	if(a_intent == INTENT_HARM)
		if(ishuman(A))
			var/mob/living/carbon/human/H = A
			if(H.stat != DEAD)
				epoint += 40
				play_scary_music()

/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/play_scary_music()
	if(world.time > next_scary_music && ambience_player)
		ambience_player.ambience_next_time += 0.5 MINUTE
		next_scary_music = world.time + 0.5 MINUTE
		for(var/mob/living/L in range(7, src))
			L.playsound_music(pick(alien_attack), VOL_AMBIENT, null, null, CHANNEL_AMBIENT, priority = 255)
