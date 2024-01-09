//Corgi
/mob/living/simple_animal/corgi
	name = "corgi"
	real_name = "corgi"
	desc = "Это корги."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	speak = list("Гав!", "Вуф!", "АУУУУ!")
	speak_emote = list("лает", "воет")
	emote_hear = list("лает", "воет")
	emote_see = list("виляет хвостом", "облизывается")
	speak_chance = 1
	turns_per_move = 10
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/corgi = 3)
	response_help  = "pets the"
	response_disarm = "bops the"
	response_harm   = "kicks the"
	see_in_dark = 5
	w_class = SIZE_BIG

	has_head = TRUE
	has_leg = TRUE

	var/facehugger

/obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "На вкус как... ну ты знаешь..."

/mob/living/simple_animal/corgi/regenerate_icons()
	cut_overlays()
	if(facehugger)
		if(istype(src, /mob/living/simple_animal/corgi/puppy))
			add_overlay(image('icons/mob/mask.dmi',"facehugger_corgipuppy"))
		else
			add_overlay(image('icons/mob/mask.dmi',"facehugger_corgi"))

/mob/living/simple_animal/corgi/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/newspaper))
		user.SetNextMove(CLICK_CD_MELEE)
		if(stat == CONSCIOUS)
			user.visible_message("<span class='notice'>[user] baps [name] on the nose with the rolled up [O]</span>")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					set_dir(i)
					sleep(1)
	else
		..()

/mob/living/simple_animal/corgi/puppy
	name = "corgi puppy"
	real_name = "corgi"
	desc = "Это щенок корги."
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	w_class = SIZE_SMALL

//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "Это корги с милым розовым бантиком."
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"

	default_emotes = list(
		/datum/emote/dance,
	)

	var/turns_since_scan = 0
	var/puppies = 0

/mob/living/simple_animal/corgi/Lisa/Life()
	..()

	if(stat == CONSCIOUS && !buckled)
		turns_since_scan++
		if(turns_since_scan > 15)
			turns_since_scan = 0
			var/alone = 1
			var/ian = 0
			//for(var/mob/M in oviewers(7, src))
			for(var/mob/M in oview(src,7))
				if(isIAN(M))
					if(M.client)
						alone = 0
						break
					else
						ian = M
				else
					alone = 0
					break
			if(alone && ian && puppies < 4)
				if(near_camera(src) || near_camera(ian))
					return
				new /mob/living/simple_animal/corgi/puppy(loc)
				puppies++


		if(prob(1))
			emote("dance")

ADD_TO_GLOBAL_LIST(/mob/living/simple_animal/corgi/borgi, chief_animal_list)
/mob/living/simple_animal/corgi/borgi
	name = "E-N"
	real_name = "E-N"	//Intended to hold the name without altering it.
	desc = "Это борги."
	icon_state = "borgi"
	icon_living = "borgi"
	icon_dead = "borgi_dead"
	butcher_results = list()
	var/emagged = 0

/mob/living/simple_animal/corgi/borgi/emag_act(mob/user)
	if(!emagged && emagged < 2)
		emagged = 1
		visible_message("<span class='warning'>[user] swipes a card through [src].</span>", "<span class='notice'>You overload [src]s internal reactor.</span>")
		spawn (1000)
			explode()
		return TRUE
	return FALSE

/mob/living/simple_animal/corgi/borgi/proc/explode()
	visible_message("<span class='warning'>[src] makes an odd whining noise.</span>")
	sleep(10)
	explosion(get_turf(src), 0, 1, 4, 7)
	Die()

/mob/living/simple_animal/corgi/borgi/proc/shootAt(atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if (!T || !U)
		return
	var/obj/item/projectile/beam/A = new /obj/item/projectile/beam(loc)
	A.icon = 'icons/effects/genetics.dmi'
	A.icon_state = "eyelasers"
	playsound(src, 'sound/weapons/guns/gunpulse_taser2.ogg', VOL_EFFECTS_MASTER)
	A.original = target
	A.current = T
	A.starting = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	spawn( 0 )
		A.process()
	return

/mob/living/simple_animal/corgi/borgi/Life()
	..()
	if(health <= 0) return
	if(emagged && prob(25))
		var/mob/living/carbon/target = locate() in view(10,src)
		if (target)
			shootAt(target)

	//spark for no reason
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

/mob/living/simple_animal/corgi/borgi/proc/Die()
	visible_message("<b>[src]</b> blows apart!")
	new /obj/effect/decal/cleanable/blood/gibs/robot(src.loc)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	//respawnable_list += src
	qdel(src)
	return
