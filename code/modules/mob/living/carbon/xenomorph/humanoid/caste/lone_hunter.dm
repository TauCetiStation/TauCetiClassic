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
	alien_spells = list(/obj/effect/proc_holder/spell/no_target/weeds)

/mob/living/carbon/xenomorph/humanoid/hunter/lone/atom_init()
	. = ..()
	name = "Alien"
	real_name = name
	alien_list[ALIEN_HUNTER] -= src			// ¯\_(ツ)_/¯
	alien_list[ALIEN_LONE_HUNTER] += src

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
			neurotoxin_icon.icon_state = "neurotoxin0"
		if (4)
			alien_spells += /obj/effect/proc_holder/spell/targeted/screech
		if (5)
			acid_type = /obj/effect/alien/acid/queen_acid

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
/mob/living/carbon/xenomorph/humanoid/hunter/lone/successful_leap()
	epoint += 200

/mob/living/carbon/xenomorph/humanoid/hunter/lone/UnarmedAttack(atom/A)
	..()
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.stat != DEAD)
			epoint += 40
