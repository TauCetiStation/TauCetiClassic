/mob/living/carbon/xenomorph/humanoid/hunter/alien
	icon = 'icons/mob/xenomorph_solo.dmi'
	icon_state = "alien_s"
	caste = ""
	pixel_x = -8
	ventcrawler = 0
	storedPlasma = 150
	var/epoint = 0
	var/estage = 1
	var/epoint_cap = 500
	alien_spells = list(/obj/effect/proc_holder/spell/no_target/weeds)

/mob/living/carbon/xenomorph/humanoid/hunter/alien/atom_init()
	. = ..()
	name = "Alien"
	real_name = name
	alien_list[ALIEN_HUNTER] += src

// Со временем ксенос должен становиться сильнее, чтобы экипаж не мог закрыться где-то и сидеть в обороне
/mob/living/carbon/xenomorph/humanoid/hunter/alien/Life()
	if(!invisible)
		epoint += 1
	if (epoint > epoint_cap)
		next_stage()
	. = ..()

/mob/living/carbon/xenomorph/humanoid/hunter/alien/proc/next_stage()
	to_chat(src, "<span class='notice'>Вы перешли на новую стадию эволюции!</span>")
	estage++
	epoint -= epoint_cap
	switch(estage)
		if (2)
			maxHealth = 240
			heal_rate = 4
			verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid, /mob/living/carbon/xenomorph/humanoid/proc/neurotoxin)
			update_icons()
		if (3)
			plasma_rate = 10
			max_plasma = 200
			alien_spells += /obj/effect/proc_holder/spell/no_target/resin
		if (4)
			maxHealth = 300
			heal_rate = 5
			plasma_rate = 15
			max_plasma = 300
		if (5)
			var/mob/living/carbon/xenomorph/humanoid/alien = /mob/living/carbon/xenomorph/humanoid/queen
			var/mob/new_xeno = new alien(src.loc)
			src.mind.transfer_to(new_xeno)
			new_xeno.mind.name = new_xeno.real_name
			qdel(src)

/mob/living/carbon/xenomorph/humanoid/hunter/alien/Stat()
	..()
	stat(null)
	if(statpanel("Status"))
		stat("Очки эволюции: [epoint]/[epoint_cap]")
		stat("Стадия эволюции: [estage]/5")

// Если включается одно, выключается другое
/mob/living/carbon/xenomorph/humanoid/hunter/alien/toggle_neurotoxin(message = TRUE)
	..()
	if(leap_on_click)
		leap_on_click = 0
		leap_icon.update_icon(src)
		update_icons()

/mob/living/carbon/xenomorph/humanoid/hunter/alien/toggle_leap(message = TRUE)
	..()
	if(neurotoxin_on_click)
		neurotoxin_on_click = 0
		neurotoxin_icon.icon_state = "neurotoxin0"
		update_icons()

// Ксенос должен поощряться за активную и агрессивную игру
/mob/living/carbon/xenomorph/humanoid/hunter/alien/successful_leap()
	epoint += 100

/mob/living/carbon/xenomorph/humanoid/hunter/alien/UnarmedAttack(atom/A)
	..()
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.stat != DEAD)
			epoint += 20
