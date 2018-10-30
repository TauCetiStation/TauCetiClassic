//TO DO:
//*Commanded dogs from Bay
//*Allow Muhtar find all the crooks!(Beepsky mechanics)
//*Give your dog junk food - there will be consequences
//*Eating many food should make them sleepy. Well, pugs are always sleepy. Theres should be a sleeping mechanics
//
//
//	Template
//
/mob/living/simple_animal/dog
	name = "a dog"
	icon = 'icons/mob/dogs.dmi'
	health = 75
	maxHealth = 75
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "AwooOOOoo!")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps", "pants")
	emote_see = list("shakes its head", "shivers", "looks cute", "chases its tail")
	speak_chance = 13
	turns_per_move = 6
	stop_automated_movement_when_pulled = 1	//so people can drag the dog around
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/dog = 2)
	response_help  = "pets the"
	response_disarm = "bops the"
	response_harm   = "kicks the"
	see_in_dark = 6
	min_oxy = 16	//Require atleast 16kPA oxygen
	minbodytemp = 223	//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	var/facehugger

	var/belly	//Using it to find out does it want more food

	var/will_play = 1	//If TRUE then dog will be playing with a toy
	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target

	var/strong_dog = 0	//If TRUE then dog will be defending itself when delt damage
	var/dogs_anger = 0	// dog's patience counter
	var/bad_guy = null
	melee_damage_lower = 5
	melee_damage_upper = 15

/obj/item/weapon/reagent_containers/food/snacks/meat/dog
	name = "dog meat"
	desc = "Something about this meat makes you feel sorry."

/obj/item/weapon/reagent_containers/food/snacks/meat/dog/atom_init()
	.=..()
	desc = pick("It was a fun and playful doggy once...", "Something about this meat makes you feel sorry.", "Why is life so cruel?")

//Begs for food
/mob/living/simple_animal/dog/proc/beg(var/atom/thing, var/atom/holder)
	emote("me", 1, "stares at the [thing] that [holder] has with sad puppy eyes.")

/mob/living/simple_animal/dog/Life()
	..()

//Making sure its not DEAD
	if(health <= 0) return

//You Spin Me Round
	if(prob(3))
		if(!stat && !resting && !buckled && will_play)
			emote("me",1,pick("dances around","chases its tail"))
			spawn(0)
				BreatheHappily()
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)

//FOOOOD!
	if(prob(30))
		for(var/mob/living/carbon/human/H in oview(src, 5))
			var/obj/item/weapon/reagent_containers/food/snacks/F = null
			if(istype(H.l_hand, /obj/item/weapon/reagent_containers/food/snacks))
				F = H.l_hand
				src.beg(F, H)
			if(istype(H.r_hand, /obj/item/weapon/reagent_containers/food/snacks))
				F = H.r_hand
				src.beg(F, H)

//Time to play!
	if(prob(30) && will_play)
		var/obj/item/weapon/bikehorn/dogtoy/histoy = locate(/obj/item/weapon/bikehorn/dogtoy) in oview(src, 3)
 		if(histoy)
 			emote("me", 1, pick("barks!" ,"woofs loudly!" ,"eyes [histoy] joyfully."))

	if(!stat && !resting && !buckled && will_play)
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if(!movement_target || !(movement_target.loc in oview(src, 3)))
				movement_target = null
				stop_automated_movement = 0
				var/obj/item/weapon/bikehorn/dogtoy/histoy = locate(/obj/item/weapon/bikehorn/dogtoy) in oview(src, 3)
				if(isturf(histoy.loc))
					movement_target = histoy
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src, movement_target, 0,3)

	if(prob(45) && will_play)
		var/obj/item/weapon/bikehorn/dogtoy/histoy = locate(/obj/item/weapon/bikehorn/dogtoy) in oview(src, 1)
		if(histoy)
			src.visible_message(pick("[bicon(src)][src] joyfully plays with the toy!", "[bicon(src)][src] rolls the toy back and forth!", "[bicon(src)][src] happily twists and spins the toy!", "[bicon(src)][src] thoroughly sniffs the toy all around!"), 2)
			BreatheHappily()
			for(var/i in list(1,2,4,8,4,2,1,2))
				dir = i
				sleep(1)

	if(prob(15))//so food in the stomach is actually digesting
		belly --

/mob/living/simple_animal/dog/regenerate_icons()
	overlays.Cut()
	if(facehugger)
		if(istype(src, /mob/living/simple_animal/dog/corgi/puppy))
			overlays += image('icons/mob/mask.dmi', "facehugger_corgipuppy")
		else
			overlays += image('icons/mob/mask.dmi', "facehugger_corgi")

/mob/living/simple_animal/dog/attackby(obj/item/O, mob/living/M)

	var/did_we_lost_health = src.health//We will need it later

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))//Yeah, it can consume EVERY SNACK. These dogs...
		M.SetNextMove(CLICK_CD_MELEE)
		if(!stat)
			if(belly >= 10)
				for(var/mob/G in viewers(M, null))
					if ((G.client && !( G.blinded )))
						G.show_message("\red [M.name] tries to feed [O] to the [name], but [name]'s belly is already full!")
				return
			for(var/mob/G in viewers(M, null))
				if ((G.client && !( G.blinded )))
					G.show_message("\blue [M.name] feeds [O] to the [name]")
			BreatheHappily()
			qdel(O)
			playsound(src, 'sound/items/eatfood.ogg', 50, 1, -3)
			belly ++
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					dir = i
					sleep(1)

	if(istype(O, /obj/item/weapon/newspaper))
		M.SetNextMove(CLICK_CD_MELEE)
		if(!stat)
			for(var/mob/G in viewers(M, null))
				if ((G.client && !( G.blinded )))
					G.show_message("\blue [M.name] baps [name] on the nose with the rolled up [O]")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					dir = i
					sleep(1)
	else
		..()

	if((did_we_lost_health > src.health) && strong_dog)//rrrrrRRRRR!
		if(!(stat == DEAD))
			dogs_anger ++
			emote("me", 1, pick("barks!", "woofs loudly!", "eyes [M.name] angrily."))
			if(prob(70))
				playsound(src, 'sound/voice/dogs/bark.ogg', 50, 1, -3)
			if(dogs_anger >= 2 && (M in oview(src, 2)))
				bad_guy = M
				BiteTarget()
				dogs_anger = 0
				sleep(20)
				bad_guy = null
	else
		if((did_we_lost_health > src.health) && !(stat == DEAD))
			emote("me", 1, pick("whines sadly.", "woofs!","eyes [M.name] plaintively."))//How could you...

/mob/living/simple_animal/dog/proc/BiteTarget()//Time to fuck those bad guys BACK!
	if(isliving(bad_guy))
		if(ishuman(bad_guy))
			var/mob/living/carbon/human/H = bad_guy
			var/dam_zone = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_L_LEG , BP_R_LEG)
			var/obj/item/organ/external/BP = H.bodyparts_by_name[ran_zone(dam_zone)]
			H.apply_damage(rand(melee_damage_lower,melee_damage_upper), BRUTE, BP, H.run_armor_check(BP, "melee"), DAM_SHARP | DAM_EDGE)
			H.Weaken(3)
			H.visible_message("<span class='danger'>[name] bites \the [H.name]!</span>")
		else
			var/mob/living/H = bad_guy
			H.adjustBruteLoss(rand(melee_damage_lower,melee_damage_upper))
			H.Weaken(3)
			H.visible_message("<span class='danger'>[name] bites \the [H.name]!</span>")
		playsound(src, 'sound/voice/dogs/attacks.ogg', 50, 1, -3)

/mob/living/simple_animal/dog/proc/BreatheHappily()
	var/list/breathe_snd = list('sound/voice/dogs/breathes1.ogg', 'sound/voice/dogs/breathes2.ogg')
	playsound(src, pick(breathe_snd), 50, 1, -3)

//
//	Corgi
//

/mob/living/simple_animal/dog/corgi
	name = "Corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/corgi = 3)
	strong_dog = 1	//If TRUE then dog will be defending itself when delt damage

/obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."

/mob/living/simple_animal/dog/corgi/puppy
	name = "Corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy."
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	health = 25
	maxHealth = 25
	strong_dog = 0	//If TRUE then dog will be defending itself when delt damage

//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/dog/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "It's a corgi with a cute pink bow."
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	var/turns_since_scan_2 = 0
	var/puppies = 0
	strong_dog = 0	//If TRUE then dog will be defending itself when delt damage

/mob/living/simple_animal/dog/corgi/Lisa/Life()
	..()

	if(!stat && !resting && !buckled)
		turns_since_scan_2++
		if(turns_since_scan_2 > 15)
			turns_since_scan_2 = 0
			var/alone = 1
			var/ian = 0
			//for(var/mob/M in oviewers(7, src))
			for(var/mob/M in oview(src,7))
				if(istype(M, /mob/living/carbon/ian))
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
				new /mob/living/simple_animal/dog/corgi/puppy(loc)
				puppies++

//
//	E-N
//

/mob/living/simple_animal/dog/corgi/borgi
	name = "E-N"
	real_name = "E-N"	//Intended to hold the name without altering it.
	desc = "It's a borgi."
	icon_state = "borgi"
	icon_living = "borgi"
	icon_dead = "borgi_dead"
	butcher_results = list()
	strong_dog = 1	//If TRUE then dog will be defending itself when delt damage
	var/emagged = 0

/mob/living/simple_animal/dog/corgi/borgi/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/card/emag) && emagged < 2)
		user.SetNextMove(CLICK_CD_MELEE)
		Emag(user)
	else
		..()

/mob/living/simple_animal/dog/corgi/borgi/proc/Emag(user)
	if(!emagged)
		emagged = 1
		visible_message("<span class='warning'>[user] swipes a card through [src].</span>", "<span class='notice'>You overload [src]s internal reactor.</span>")
		sleep(1000)
		src.explode()

/mob/living/simple_animal/dog/corgi/borgi/proc/explode()
	for(var/mob/M in viewers(src, null))
		if (M.client && !( M.blinded ))
			M.show_message("\red [src] makes an odd whining noise.")
	sleep(10)
	explosion(get_turf(src), 0, 1, 4, 7)
	Die()

/mob/living/simple_animal/dog/corgi/borgi/proc/shootAt(atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if (!T || !U)
		return
	var/obj/item/projectile/beam/A = new /obj/item/projectile/beam(loc)
	A.icon = 'icons/effects/genetics.dmi'
	A.icon_state = "eyelasers"
	playsound(src.loc, 'sound/weapons/taser2.ogg', 75, 1)
	A.original = target
	A.current = T
	A.starting = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	spawn(0)
		A.process()
	return

/mob/living/simple_animal/dog/corgi/borgi/Life()
	..()

	if(emagged && prob(25))
		var/mob/living/carbon/target = locate() in view(10,src)
		if (target)
			shootAt(target)

	//spark for no reason
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

/mob/living/simple_animal/dog/corgi/borgi/proc/Die()
	..()
	visible_message("<b>[src]</b> blows apart!")
	new /obj/effect/decal/cleanable/blood/gibs/robot(src.loc)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	//respawnable_list += src
	qdel(src)
	return

//
//	Pug
//

/mob/living/simple_animal/dog/pug
	name = "Pug"
	real_name = "pug"
	desc = "It has a wrinkly, short-muzzled face, and a curled tail."
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	health = 25
	maxHealth = 25
	strong_dog = 1	//If TRUE then dog will be defending itself when delt damage

/mob/living/simple_animal/dog/pug/Life()
	..()
	if(prob(15))
		emote("me", 1, "farts")
		new	/obj/effect/effect/smoke/mustard/dog_fart(src.loc)
	if(prob(10))
		emote("me", 1, "sneezes")
//What a life

/obj/effect/effect/smoke/mustard/dog_fart
	name = "fart cloud"
	icon_state = "dog_fart"
	time_to_live = 30

/obj/effect/effect/smoke/mustard/dog_fart/affect(mob/living/carbon/human/R)
	if (!..())
		return 0
	if (R.wear_suit != null)
		return 0
	to_chat(R, pick("<span class='warning'>Oh my god! the smell!</span>", "<span class='warning'>Smells horrible.</span>", "<span class='warning'>This dog is a demon...</span>"))
	R.burn_skin(0.75)
	if (R.coughedtime != 1)
		R.coughedtime = 1
		R.emote("gasp")
		sleep(20)
		R.coughedtime = 0
	R.updatehealth()
	return

//
//	Shiba
//

/mob/living/simple_animal/dog/shiba
	name = "Shiba Inu"
	real_name = "shiba inu"
	desc = "It's a small, agile cute doggy."
	icon_state = "shiba"
	icon_living = "shiba"
	icon_dead = "shiba_dead"
	speak = list("Kyan!","Van!", "Woof!", "Bark!", "AUUUUUU", "Yap!")
	emote_hear = list("barks", "woofs", "pants", "vans")
	speak_chance = 20
	turns_per_move = 3
	strong_dog = 1	//If TRUE then dog will be defending itself when delt damage

//
//	German Shepherd
//

/mob/living/simple_animal/dog/german_shepherd
	name = "German shepherd"
	real_name = "german shepherd"
	desc = "Smart and easily trained, the ever-popular German shepherd is quite active and likes to have something to do."
	icon_state = "german_shepherd"
	icon_living = "german_shepherd"
	icon_dead = "german_shepherd_dead"
	strong_dog = 1	//If TRUE then dog will be defending itself when delt damage

/mob/living/simple_animal/dog/german_shepherd/muhtar
	name = "Muhtar"
	real_name = "Muhtar"
	desc = "A dog trained to listen and obey its owner commands. This one looks about three days from retirement."
	melee_damage_lower = 10
	melee_damage_upper = 30
	health = 110
	maxHealth = 110
	speak_chance = 5
	icon_state = "muhtar"
	icon_living = "muhtar"
	icon_dead = "muhtar_dead"
	will_play = 0//He's only about working. What a dog.

/*
	Muhtar will find all the crooks!
	var/oldtarget_name = 0
	var/last_found = 0

	var/check_arrest = TRUE
	var/check_records = TRUE
	var/check_weapons = TRUE

/mob/living/simple_animal/dog/german_shepherd/muhtar/Life()
	..()
	if(prob(70))
		for(var/mob/living/L in view(7, src)) //Let's find us a criminal
			if(L.stat)
				return

			if(iscarbon(L))
				var/mob/living/carbon/C = L
				if(C.handcuffed)
					return

			if((L.name == oldtarget_name) && (world.time < last_found + 100))
				return


			if(assess_perp(L) >= 4)
				oldtarget_name = L.name
				playsound(src, 'sound/voice/dogs/bark.ogg', 50, 1, -3)
				src.emote("me",1,"[src.name] barks at [oldtarget_name]! He is a criminal!")
				src.last_found = world.time

/mob/living/simple_animal/dog/german_shepherd/muhtar/assess_perp(mob/living/carbon/human/H)
	if(!H || !istype(H))
		return FALSE

	return H.assess_perp(src, FALSE, check_weapons, check_records, check_arrest)
*/
//
//	Tamaskan
//

/mob/living/simple_animal/dog/tamaskan
	name = "Tamaskan"
	real_name = "tamaskan"
	desc = "It's a large, athletic intelligent dog, slightly taller than German Shepherd."
	icon_state = "tamaskan"
	icon_living = "tamaskan"
	icon_dead = "tamaskan_dead"
	health = 90
	maxHealth = 90
	strong_dog = 1	//If TRUE then dog will be defending itself when delt damage
