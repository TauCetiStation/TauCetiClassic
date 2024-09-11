/mob/living/simple_animal/hostile/bot
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	speed = 4
	typing_indicator_type = "machine"
	speak_emote = list("пищит")

	animalistic = FALSE
	has_arm = TRUE
	has_leg = TRUE
	faction = "bots"

/mob/living/simple_animal/hostile/bot/death()
	..()
	new /obj/effect/gibspawner/robot(loc)
	visible_message("<span class='warning'>[src] blows apart!</span>")
	qdel(src)

/mob/living/simple_animal/hostile/bot/emp_act(severity)
	new /obj/effect/effect/sparks(loc)
	health -= rand(10, 20)

/mob/living/simple_animal/hostile/bot/secbot
	name = "Securitron"
	desc = "Маленький робот-охранник. Похоже, он не в восторге увидев вас."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "secbot1"
	health = 40
	maxHealth = 40
	melee_damage = 10
	attacktext = "harmbaton"
	attack_sound = 'sound/weapons/genhit1.ogg'

/mob/living/simple_animal/hostile/bot/secbot/UnarmedAttack(atom/target)
	. = ..()
	if(prob(20))
		playsound(src, pick(SOUNDIN_BEEPSKY), VOL_EFFECTS_MASTER, null, FALSE)
