/mob/living/carbon/slime
	name = "baby slime"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE
	speak_emote = list("hums")

	layer = 5

	maxHealth = 150
	health = 150
	gender = NEUTER

	update_icon = 0
	nutrition = 700 // 1000 = max

	see_in_dark = 8
	update_slimes = 0

	ventcrawler = 2

	// canstun and canweaken don't affect slimes because they ignore stun and weakened variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANPARALYSE|CANPUSH

	var/cores = 1 // the number of /obj/item/slime_extract's the slime has left inside

	var/powerlevel = 0 	// 1-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the slime has been overfed, if 10, grows into an adult
	var/max_grown = 10		// if adult: if 10: reproduces


	var/mob/living/Victim = null // the person the slime is currently feeding on
	var/mob/living/Target = null // AI variable - tells the slime to hunt this down
	var/mob/living/ATarget = null

	var/attacked = 0 // determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/tame = 0 // if set to 1, the slime will not eat humans ever, or attack them
	var/rabid = 0 // if set to 1, the slime will attack and eat anything it comes in contact with

	var/list/Friends = list() // A list of potential friends
	// slimes pass on genetic data, so all their offspring have the same "Friends",

	var/mood = "" // To show its face
	var/list/speech_buffer = list() // Last phrase said near it and person who said it
	var/number = 0 // Used to understand when someone is talking to it
	var/mob/living/Leader = null // AI variable - tells the slime to follow this person
	var/holding_still = 0 // AI variable, cooloff-ish for how long it's going to stay in one place
	var/target_patience = 0 // AI variable, cooloff-ish for how long it's going to follow its target

	///////////TIME FOR SUBSPECIES

	var/colour = "grey"
	var/primarytype = /mob/living/carbon/slime
	var/mutationone = /mob/living/carbon/slime/orange
	var/mutationtwo = /mob/living/carbon/slime/metal
	var/mutationthree = /mob/living/carbon/slime/blue
	var/mutationfour = /mob/living/carbon/slime/purple
	var/adulttype = /mob/living/carbon/slime/adult
	var/coretype = /obj/item/slime_extract/grey
	var/mob/living/last_pointed = null

/mob/living/carbon/slime/adult
	name = "adult slime"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey adult slime"
	speak_emote = list("telepathically chirps")

	health = 200
	gender = NEUTER

	update_icon = 0
	nutrition = 800 // 1200 = max


/mob/living/carbon/slime/atom_init()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	number = rand(1, 1000)
	if(name == "baby slime")
		name = text("[colour] baby slime ([number])")
	else
		name = text("[colour] adult slime ([number])")
	real_name = name

	. = ..()

	regenerate_icons()

/mob/living/carbon/slime/Destroy()
	Victim = null
	Target = null
	ATarget = null
	last_pointed = null
	Leader = null
	if(Friends.len)
		Friends.Cut()
	return ..()

/mob/living/carbon/slime/regenerate_icons()
	cut_overlays()
	//var/icon_text = "[colour] [is_adult ? "adult" : "baby"] slime"
	//icon_dead = "[icon_text] dead"
	//if(stat != DEAD)
		//icon_state = icon_text
	if(stat != DEAD)
		if(mood)
			add_overlay(image('icons/mob/slimes.dmi', icon_state = "aslime-[mood]"))
	//else
		//icon_state = icon_dead
	..()

/mob/living/carbon/slime/movement_delay()
	var/tally = 0

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45) tally += (health_deficiency / 25)

	if (bodytemperature < 183.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	if(reagents)
		if(reagents.has_reagent("hyperzine")) // hyperzine slows slimes down
			tally *= 2 // moves twice as slow

		if(reagents.has_reagent("frostoil")) // frostoil also makes them move VEEERRYYYYY slow
			tally *= 5

	if(pull_debuff)
		tally += pull_debuff

	if(health <= 0) // if damaged, the slime moves twice as slow
		tally *= 2

	if (bodytemperature >= 330.23) // 135 F
		return -1	// slimes become supercharged at high temperatures

	return tally+config.slime_delay

/mob/living/carbon/slime/ObjBump(obj/O)
	if(!client && powerlevel > 0)
		var/probab = 10
		switch(powerlevel)
			if(1 to 2)	probab = 20
			if(3 to 4)	probab = 30
			if(5 to 6)	probab = 40
			if(7 to 8)	probab = 60
			if(9)		probab = 70
			if(10)		probab = 95
		if(prob(probab))
			if(istype(O, /obj/structure/window) || istype(O, /obj/structure/grille))
				if(isslimeadult(src))
					if(nutrition <= 600 && !Atkcool)
						O.attack_slime(src)
						spawn()
							Atkcool = 1
							sleep(15)
							Atkcool = 0
				else
					if(nutrition <= 500 && !Atkcool)
						if(prob(5))
							O.attack_slime(src)
							spawn()
								Atkcool = 1
								sleep(15)
								Atkcool = 0

/mob/living/carbon/slime/MobBump(mob/M)
	if(ishuman(M)) //pushing humans
		if(isslimeadult(src) && prob(10)) //only if we're adult, and 10% of the time
			return 0
		else
			return 1

/mob/living/carbon/slime/Process_Spacemove(movement_dir = 0)
	return 2

/mob/living/carbon/slime/Stat()
	..()

	if(statpanel("Status"))
		if(isslimeadult(src))
			stat(null, "Health: [round((health / 200) * 100)]%")
			stat(null, "Nutrition: [nutrition]/1200")
			if(amount_grown >= max_grown)
				stat(null, "You can reproduce!")
		else
			stat(null, "Health: [round((health / 150) * 100)]%")
			stat(null, "Nutrition: [nutrition]/1000")
			if(amount_grown >= max_grown)
				stat(null, "You can evolve!")

		stat(null,"Power Level: [powerlevel]")


/mob/living/carbon/slime/adjustFireLoss(amount)
	..(-abs(amount)) // Heals them
	return

/mob/living/carbon/slime/bullet_act(obj/item/projectile/Proj)
	attacked += 10
	return ..()

/mob/living/carbon/slime/emp_act(severity)
	powerlevel = 0 // oh no, the power!
	..()

/mob/living/carbon/slime/ex_act(severity)

	if (stat == DEAD && client)
		return

	else if (stat == DEAD && !client)
		qdel(src)
		return

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			return

		if (2.0)

			b_loss += 60
			f_loss += 60


		if(3.0)
			b_loss += 30

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()


/mob/living/carbon/slime/blob_act()
	if (stat == DEAD)
		return
	var/shielded = 0

	var/damage = null
	if (stat != DEAD)
		damage = rand(10,30)

	if(shielded)
		damage /= 4

		//paralysis += 1

	to_chat("<span class='warning'>The blob attacks you!</span>")

	adjustFireLoss(damage)

	updatehealth()
	return


/mob/living/carbon/slime/u_equip(obj/item/W)
	return


/mob/living/carbon/slime/attack_ui(slot)
	return


/mob/living/carbon/slime/hurtReaction(mob/living/attacker, show_message = TRUE)
	if(Victim)
		if(Victim == attacker)
			visible_message("<span class='warning'>[attacker] attempts to wrestle \the [src] off!</span>")
			playsound(src, 'sound/weapons/punchmiss.ogg', VOL_EFFECTS_MASTER)
			return FALSE
		else
			if(prob(30))
				visible_message("<span class='warning'>[attacker] attempts to wrestle \the [src] off!</span>")
				playsound(src, 'sound/weapons/punchmiss.ogg', VOL_EFFECTS_MASTER)
				return FALSE

			if(prob(90) && !client)
				Discipline++

			Victim = null
			anchored = FALSE
			step_away(src, attacker)
			return TRUE

	return ..()

/mob/living/carbon/slime/restrained()
	return 0

/mob/living/carbon/slime/show_inv(mob/user)
	return

/mob/living/carbon/slime/updatehealth()
	if(status_flags & GODMODE)
		if(istype(src, /mob/living/carbon/slime/adult))
			health = 200
		else
			health = 150
		stat = CONSCIOUS
	else
		// slimes can't suffocate unless they suicide. They are also not harmed by fire
		if(istype(src, /mob/living/carbon/slime/adult))
			health = 200 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())
		else
			health = 150 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())

/mob/living/carbon/slime/getTrail()
	return null

/mob/living/carbon/slime/is_usable_head(targetzone = null)
	return TRUE

/mob/living/carbon/slime/is_usable_arm(targetzone = null)
	return FALSE

/mob/living/carbon/slime/is_usable_leg(targetzone = null)
	return FALSE

/mob/living/carbon/slime/get_species()
	return SLIME

/obj/item/slime_extract
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey slime extract"
	force = 1.0
	w_class = ITEM_SIZE_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 6
	origin_tech = "biotech=6"
	var/Uses = 1 // uses before it goes inert
	var/enhanced = 0 // has it been enhanced before?

/obj/item/slime_extract/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/slimesteroid2))
		if(enhanced == 1)
			to_chat(user, "<span class='warning'>This extract has already been enhanced!</span>")
			return
		if(Uses == 0)
			to_chat(user, "<span class='warning'>You can't enhance a used extract!</span>")
			return
		to_chat(user, "You apply the enhancer. It now has triple the amount of uses.")
		Uses = 3
		enhanced = 1
		qdel(I)
		return
	return ..()

/obj/item/slime_extract/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

/obj/item/slime_extract/grey
	name = "grey slime extract"
	icon_state = "grey slime extract"
	origin_tech = "biotech=2"

/obj/item/slime_extract/gold
	name = "gold slime extract"
	icon_state = "gold slime extract"
	origin_tech = "biotech=8"

/obj/item/slime_extract/silver
	name = "silver slime extract"
	icon_state = "silver slime extract"
	origin_tech = "biotech=7"

/obj/item/slime_extract/metal
	name = "metal slime extract"
	icon_state = "metal slime extract"
	origin_tech = "biotech=6;engineering=3;materials=3"

/obj/item/slime_extract/purple
	name = "purple slime extract"
	icon_state = "purple slime extract"
	origin_tech = "biotech=6;materials=3"

/obj/item/slime_extract/darkpurple
	name = "dark purple slime extract"
	icon_state = "dark purple slime extract"
	origin_tech = "biotech=7;engineering=4;materials=4;phorontech=4"

/obj/item/slime_extract/orange
	name = "orange slime extract"
	icon_state = "orange slime extract"
	origin_tech = "biotech=6;combat=3;materials=3"

/obj/item/slime_extract/yellow
	name = "yellow slime extract"
	icon_state = "yellow slime extract"
	origin_tech = "biotech=7;powerstorage=4;magnets=4"

/obj/item/slime_extract/red
	name = "red slime extract"
	icon_state = "red slime extract"
	origin_tech = "biotech=8;combat=5;materials=5"

/obj/item/slime_extract/blue
	name = "blue slime extract"
	icon_state = "blue slime extract"
	origin_tech = "biotech=6;materials=3"

/obj/item/slime_extract/darkblue
	name = "dark blue slime extract"
	icon_state = "dark blue slime extract"
	origin_tech = "biotech=7"

/obj/item/slime_extract/pink
	name = "pink slime extract"
	icon_state = "pink slime extract"
	origin_tech = "biotech=8;materials=5"

/obj/item/slime_extract/green
	name = "green slime extract"
	icon_state = "green slime extract"
	origin_tech = "biotech=8;materials=5"

/obj/item/slime_extract/lightpink
	name = "light pink slime extract"
	icon_state = "light pink slime extract"
	origin_tech = "biotech=9;materials=6"

/obj/item/slime_extract/black
	name = "black slime extract"
	icon_state = "black slime extract"
	origin_tech = "biotech=9;materials=6"

/obj/item/slime_extract/oil
	name = "oil slime extract"
	icon_state = "oil slime extract"
	origin_tech = "biotech=9;combat=6"

/obj/item/slime_extract/adamantine
	name = "adamantine slime extract"
	icon_state = "adamantine slime extract"
	origin_tech = "biotech=9;robotics=6;combat=6"

//Zve added
/obj/item/slime_extract/bluespace
	name = "bluespace slime extract"
	icon_state = "bluespace slime extract"
	origin_tech = "biotech=9;bluespace=6"

/obj/item/slime_extract/pyrite
	name = "pyrite slime extract"
	icon_state = "pyrite slime extract"
	origin_tech = "biotech=9"

/obj/item/slime_extract/cerulean
	name = "cerulean slime extract"
	icon_state = "cerulean slime extract"
	origin_tech = "biotech=9;materials=6"

/obj/item/slime_extract/sepia
	name = "sepia slime extract"
	icon_state = "sepia slime extract"
	origin_tech = "biotech=9;engineering=6"

/obj/item/slime_extract/rainbow
	name = "rainbow slime extract"
	icon_state = "rainbow slime extract"
	origin_tech = "biotech=9;bluespace=3"

////Pet Slime Creation///

/obj/item/weapon/slimepotion
	name = "docility potion"
	desc = "A potent chemical mix that will nullify a slime's powers, causing it to become docile and tame."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"

/obj/item/weapon/slimepotion/attack(mob/living/carbon/slime/M, mob/user)
	if(!istype(M, /mob/living/carbon/slime))//If target is not a slime.
		to_chat(user, "<span class='warning'>The potion only works on baby slimes!</span>")
		return ..()
	if(istype(M, /mob/living/carbon/slime/adult)) //Can't tame adults
		to_chat(user, "<span class='warning'>Only baby slimes can be tamed!</span>")
		return..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return..()
	var/mob/living/simple_animal/slime/pet = new /mob/living/simple_animal/slime(M.loc)
	pet.icon_state = "[M.colour] baby slime"
	pet.icon_living = "[M.colour] baby slime"
	pet.icon_dead = "[M.colour] baby slime dead"
	pet.colour = "[M.colour]"
	to_chat(user, "You feed the slime the potion, removing it's powers and calming it.")
	qdel(M)
	var/newname = sanitize_safe(input(user, "Would you like to give the slime a name?", "Name your new pet", "pet slime") as null|text, MAX_NAME_LEN)

	if (!newname)
		newname = "pet slime"
	pet.name = newname
	pet.real_name = newname
	qdel(src)

/obj/item/weapon/slimepotion2
	name = "advanced docility potion"
	desc = "A potent chemical mix that will nullify a slime's powers, causing it to become docile and tame. This one is meant for adult slimes."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"

/obj/item/weapon/slimepotion2/attack(mob/living/carbon/slime/adult/M, mob/user)
	if(!istype(M, /mob/living/carbon/slime/adult))//If target is not a slime.
		to_chat(user, "<span class='warning'>The potion only works on adult slimes!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return..()
	var/mob/living/simple_animal/adultslime/pet = new /mob/living/simple_animal/adultslime(M.loc)
	pet.icon_state = "[M.colour] adult slime"
	pet.icon_living = "[M.colour] adult slime"
	pet.icon_dead = "[M.colour] baby slime dead"
	pet.colour = "[M.colour]"
	to_chat(user, "You feed the slime the potion, removing it's powers and calming it.")
	qdel(M)
	var/newname = sanitize_safe(input(user, "Would you like to give the slime a name?", "Name your new pet", "pet slime") as null|text, MAX_NAME_LEN)

	if (!newname)
		newname = "pet slime"
	pet.name = newname
	pet.real_name = newname
	qdel(src)


/obj/item/weapon/slimesteroid
	name = "slime steroid"
	desc = "A potent chemical mix that will cause a slime to generate more extract."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"

/obj/item/weapon/slimesteroid/attack(mob/living/carbon/slime/M, mob/user)
	if(!istype(M, /mob/living/carbon/slime))//If target is not a slime.
		to_chat(user, "<span class='warning'>The steroid only works on baby slimes!</span>")
		return ..()
	if(istype(M, /mob/living/carbon/slime/adult)) //Can't tame adults
		to_chat(user, "<span class='warning'>Only baby slimes can use the steroid!</span>")
		return..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return..()
	if(M.cores == 3)
		to_chat(user, "<span class='warning'>The slime already has the maximum amount of extract!</span>")
		return..()

	to_chat(user, "You feed the slime the steroid. It now has triple the amount of extract.")
	M.cores = 3
	qdel(src)

/obj/item/weapon/slimesteroid2
	name = "extract enhancer"
	desc = "A potent chemical mix that will give a slime extract three uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"

////////Adamantine Golem stuff I dunno where else to put it

/obj/item/clothing/under/golem
	name = "adamantine skin"
	desc = "A golem's skin."
	icon_state = "golem"
	item_state = "golem"
	item_color = "golem"
	has_sensor = 0
	canremove = 0
	unacidable = 1
	flags = ABSTRACT | DROPDEL


/obj/item/clothing/shoes/golem
	name = "golem's feet"
	desc = "Sturdy adamantine feet."
	icon_state = "golem"
	item_state = null
	canremove = 0
	flags = ABSTRACT | DROPDEL | NOSLIP
	unacidable = 1


/obj/item/clothing/mask/gas/golem
	name = "golem's face"
	desc = "The imposing face of an adamantine golem."
	icon_state = "golem"
	item_state = "golem"
	canremove = 0
	siemens_coefficient = 0
	unacidable = 1
	flags = ABSTRACT | DROPDEL
	flags_inv = 0


/obj/item/clothing/gloves/golem
	name = "golem's hands"
	desc = "Strong adamantine hands."
	icon_state = "golem"
	item_state = null
	siemens_coefficient = 0
	canremove = 0
	unacidable = 1
	flags = ABSTRACT | DROPDEL


/obj/item/clothing/head/helmet/space/golem
	icon_state = "golem"
	item_state = "dermal"
	item_color = "dermal"
	name = "golem's head"
	desc = "A golem's head."
	canremove = 0
	unacidable = 1

	body_parts_covered = HEAD|FACE|EYES
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

	flags = ABSTRACT | DROPDEL
	flags_inv = 0
	slowdown = 0
	unacidable = 1
	canremove = 0
	siemens_coefficient = 0

	armor = list(melee = 80, bullet = 70, laser = 80, energy = 66, bomb = 80, bio = 100, rad = 100)


/obj/item/clothing/suit/space/golem
	name = "adamantine shell"
	desc = "A golem's thick outter shell."
	icon_state = "golem"
	item_state = "golem"
	w_class = ITEM_SIZE_LARGE//bulky item
	allowed = null

	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

	flags = ABSTRACT | DROPDEL
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	slowdown = 0
	unacidable = 1
	canremove = 0
	siemens_coefficient = 0
	can_breach = 0

	armor = list(melee = 80, bullet = 70, laser = 80, energy = 66, bomb = 80, bio = 100, rad = 100)

/obj/effect/golemrune
	anchored = 1
	desc = "A strange rune used to create golems. It glows when spirits are nearby."
	name = "rune"
	icon = 'icons/obj/rune.dmi'
	icon_state = "golem"
	unacidable = 1
	layer = TURF_LAYER
	var/last_ghost_click = 0
	var/mob/dead/observer/spirit

/obj/effect/golemrune/atom_init()
	. = ..()
	announce_to_ghosts()

/obj/effect/golemrune/update_icon()
	if(spirit)
		icon_state = "golem2"
	else
		icon_state = "golem"

/obj/effect/golemrune/process()
	check_spirit()

/obj/effect/golemrune/attack_ghost(mob/dead/observer/user)
	if(user.mind && user.mind.current && user.mind.current.stat != DEAD)
		to_chat(user, "<span class='notice'>Your spirit linked to another body.</span>")
		return
	if(user.golem_rune && user.golem_rune != src)
		to_chat(user, "<span class='notice'>One rune per one poor little spirit.</span>")
		return
	if(spirit && spirit != user)
		to_chat(user, "<span class='warning'>This rune is taken by another spirit, wait or find new one.</span>")
		return
	if(last_ghost_click >= world.time)
		to_chat(user, "<span class='notice'>You cannot do this so often.</span>")
		return
	if(user == spirit)
		for(var/image/I in user.client.images)
			if(I.loc == src && I.icon_state == "agolem_master")
				user.client.images -= I
				break
		spirit = null
		user.golem_rune = null
		to_chat(user, "<span class='notice'>You are no longer queued for golem role.</span>")
	else
		START_PROCESSING(SSobj, src)
		last_ghost_click = world.time + 50
		var/image/I = image('icons/mob/hud.dmi', src, "agolem_master") //If there is alot activated rune close by, we can see which is ours.
		user.client.images += I
		spirit = user
		user.golem_rune = src
		to_chat(user, "<span class='notice'>You are now queued for golem role.</span>")
	check_spirit()

/obj/effect/golemrune/attack_hand(mob/living/carbon/human/H)
	if(H.my_golem || !H.get_species() == GOLEM)
		return
	if(!check_spirit())
		to_chat(H, "The rune fizzles uselessly. There is no spirit nearby.")
		return
	H.SetNextMove(CLICK_CD_INTERACT)
	var/mob/living/carbon/human/golem/G = new(loc)
	G.attack_log = spirit.attack_log //Preserve attack log, if there is any...
	G.attack_log += "\[[time_stamp()]\]<font color='blue'> ======GOLEM LIFE======</font>"
	G.key = spirit.key
	G.my_master = H
	G.update_golem_hud_icons()
	H.my_golem = G
	H.update_golem_hud_icons()
	to_chat(G, "You are an adamantine golem. You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools. Serve [H], and assist them in completing their goals at any cost.")
	qdel(src)

/obj/effect/golemrune/proc/announce_to_ghosts()
	for(var/mob/dead/observer/O in player_list)
		if(O.client)
			var/area/A = get_area(src)
			if(A)
				to_chat(O, "<span class='userdanger'>Golem rune created in [A.name] (<A HREF='?src=\ref[O];ghostplayerobservejump=\ref[src]'>JMP</A>).</span>")

/obj/effect/golemrune/proc/check_spirit()
	var/result = 1
	if(!spirit)
		result = 0
	else if(spirit && (!spirit.client || spirit.mind && spirit.mind.current && spirit.mind.current.stat != DEAD))
		spirit.golem_rune = null
		spirit = null
		result = 0
	if(!result)
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return result

/mob/living/carbon/human/proc/update_golem_hud_icons()
	if(client)
		if(dna && (dna.mutantrace == "adamantine"))
			if(my_master)
				var/I = image('icons/mob/hud.dmi', loc = my_master, icon_state = "agolem_master")
				client.images += I
		else
			if(my_golem)
				var/I = image('icons/mob/hud.dmi', loc = my_golem, icon_state = "agolem_master")
				client.images += I

//////////////////////////////Old shit from metroids/RoRos, and the old cores, would not take much work to re-add them////////////////////////

/*
// Basically this slime Core catalyzes reactions that normally wouldn't happen anywhere
/obj/item/slime_core
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "slime extract"
	force = 1.0
	w_class = ITEM_SIZE_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 6
	origin_tech = "biotech=4"
	var/POWERFLAG = 0 // sshhhhhhh
	var/Flush = 30
	var/Uses = 5 // uses before it goes inert

/obj/item/slime_core/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	POWERFLAG = rand(1,10)
	Uses = rand(7, 25)
	//flags |= NOREACT

	spawn()
		Life()

/obj/item/slime_core/proc/Life()
	while(src)
		sleep(25)
		Flush--
		if(Flush <= 0)
			reagents.clear_reagents()
			Flush = 30
*/



/obj/item/weapon/reagent_containers/food/snacks/egg/slime
	name = "slime egg"
	desc = "A small, gelatinous egg."
	icon = 'icons/mob/mob.dmi'
	icon_state = "slime egg-growing"
	bitesize = 12
	origin_tech = "biotech=4"
	var/grown = 0

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("slimejelly", 1)
	addtimer(CALLBACK(src, .proc/Grow), rand(1200,1500)) // the egg takes a while to "ripen"

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/proc/Grow()
	grown = 1
	icon_state = "slime egg-grown"
	START_PROCESSING(SSobj, src)
	return

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/proc/Hatch()
	STOP_PROCESSING(SSobj, src)
	var/turf/T = get_turf(src)
	src.visible_message("<span class='notice'>The [name] pulsates and quivers!</span>")
	spawn(rand(50,100))
		src.visible_message("<span class='notice'>The [name] bursts open!</span>")
		new/mob/living/carbon/slime(T)
		qdel(src)


/obj/item/weapon/reagent_containers/food/snacks/egg/slime/process()
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	if (environment.gas["phoron"] > MOLES_PHORON_VISIBLE)//phoron exposure causes the egg to hatch
		src.Hatch()

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon))
		return
	else
		return ..()
