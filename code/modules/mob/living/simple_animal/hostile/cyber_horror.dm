/mob/living/simple_animal/hostile/cyber_horror
	name = "cyber horror"
	desc = "Что-то, что когда-то было человеком..."
	icon_state = "cyber_horror"
	icon_dead = "cyber_horror_dead"
	icon_gib = "cyber_horror_dead"
	speak = list("П@$%@ТЕ @#Е", "А@#А%", "КР#%Н", "УБ#$@Т# $#@Я", "@О#@#$И, ПО%#%$@Е М%#")
	speak_emote = list("кричит", "рычит")
	speak_chance = 20
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 150
	health = 150
	melee_damage = 10
	attacktext = "flail"
	move_to_delay = 5
	attack_sound = list('sound/weapons/bite.ogg')

	var/emp_damage = 0
	var/nanobot_chance = 40

	animalistic = FALSE
	has_head = TRUE
	has_arm = TRUE
	has_leg = TRUE

/mob/living/simple_animal/hostile/cyber_horror/Life(mob/living/simple_animal/hostile/cyber_horror/M)
	. = ..()
	if(!.)
		return 0
	if(prob(90) && ((health + emp_damage) < maxHealth))
		health += 4                                                                        //Created by misuse of medical nanobots, so it heals
		if(prob(15))
			visible_message("<span class='warning'>[src]'s wounds heal slightly!</span>")

/mob/living/simple_animal/hostile/cyber_horror/emp_act(severity)
	switch(severity)
		if(1)
			adjustBruteLoss(50)
			emp_damage += 50
		if(2)
			adjustBruteLoss(25)
			emp_damage += 25

/mob/living/simple_animal/hostile/cyber_horror/UnarmedAttack(atom/A)
	. = ..()
	if(!isliving(A))
		return
	var/mob/living/L = A
	if(L.reagents)
		if(prob(nanobot_chance))
			visible_message("<span class='warning'>[src] injects something from its flailing arm!</span>")
			L.reagents.add_reagent("mednanobots", 3)

/mob/living/simple_animal/hostile/cyber_horror/death()
	..()
	visible_message("<b>[src]</b> blows apart!")
	new /obj/effect/gibspawner/robot(src.loc)
	qdel(src)
