/mob/living/carbon/xenomorph/humanoid/hunter/lone
	name = "Alien"
	icon = 'icons/mob/xenomorph_solo.dmi'
	icon_state = "alien_s"
	caste = ""
	pixel_x = -8
	ventcrawler = 0
	storedPlasma = 150
	var/estage = 1
	var/list/alien_screamer = list(
		'sound/antag/Alien_sounds/alien_screamer1.ogg',
		'sound/antag/Alien_sounds/alien_screamer2.ogg')
	var/list/alien_attack = list(
		'sound/antag/Alien_sounds/alien_attack1.ogg',
		'sound/antag/Alien_sounds/alien_attack2.ogg',
		'sound/antag/Alien_sounds/alien_attack3.ogg')
	var/scary_music_next_time = 0
	var/current_scary_music
	var/obj/effect/landmark/nostromo/ambience/ambience_player
	alien_spells = list(/obj/effect/proc_holder/spell/no_target/weeds)

/mob/living/carbon/xenomorph/humanoid/hunter/lone/atom_init()
	. = ..()
	name = "Alien"
	real_name = name
	alien_list[ALIEN_HUNTER] -= src			// ¯\_(ツ)_/¯
	alien_list[ALIEN_LONE_HUNTER] += src
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid)
	var/obj/effect/landmark/L = landmarks_list["Nostromo Ambience"][1]
	if(L)
		ambience_player = L
	playsound(src, 'sound/voice/xenomorph/big_hiss.ogg', VOL_EFFECTS_MASTER)

/mob/living/carbon/xenomorph/humanoid/hunter/Destroy()
	alien_list[ALIEN_LONE_HUNTER] -= src
	return ..()

/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/next_stage()
	to_chat(src, "<span class='notice'>Вы перешли на новую стадию эволюции!</span>")
	estage++
	maxHealth += 20
	heal_rate += 1
	max_plasma += 50
	plasma_rate += 1

/mob/living/carbon/xenomorph/humanoid/hunter/lone/Stat()
	if(statpanel("Status"))
		stat("Стадия эволюции: [estage]")

/mob/living/carbon/xenomorph/humanoid/hunter/lone/successful_leap(mob/living/L)
	for(var/mob/beholder in oview(6, src))
		beholder.playsound_local(null, pick(alien_screamer), VOL_EFFECTS_MASTER, null, FALSE)
	play_scary_music()

/mob/living/carbon/xenomorph/humanoid/hunter/lone/UnarmedAttack(atom/A)
	..()
	if(a_intent == INTENT_HARM)
		if(ishuman(A))
			var/mob/living/carbon/human/H = A
			if(H.stat != DEAD)
				play_scary_music()

/mob/living/carbon/xenomorph/humanoid/hunter/lone/proc/play_scary_music()
	if(ambience_player && world.time > scary_music_next_time)
		current_scary_music = pick(alien_attack - current_scary_music)
		ambience_player.ambience_next_time += 0.5 MINUTE
		scary_music_next_time = world.time + 1 MINUTE
		for(var/mob/M in range(7, src))
			M.playsound_music(current_scary_music, VOL_AMBIENT, null, null, CHANNEL_AMBIENT, priority = 255)
