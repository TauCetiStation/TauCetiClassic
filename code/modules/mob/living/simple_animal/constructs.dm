/mob/living/simple_animal/construct
	name = "Construct"
	real_name = "Construct"
	desc = ""
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm = "punches"
	icon_dead = "shade_dead"
	speed = -1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	universal_speak = 1
	attack_sound = list('sound/weapons/punch1.ogg')
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	faction = "cult"
	var/list/construct_spells = list()

	animalistic = FALSE
	has_head = TRUE
	has_arm = TRUE

/mob/living/simple_animal/construct/atom_init()
	. = ..()
	name = text("[initial(name)] ([rand(1, 1000)])")
	real_name = name
	for(var/spell in construct_spells)
		spell_list += new spell(src)

	var/obj/effect/effect/forcefield/rune/R = new
	AddComponent(/datum/component/forcefield, "blood aura", 20, 5 SECONDS, 3 SECONDS, R, TRUE, TRUE)
	SEND_SIGNAL(src, COMSIG_FORCEFIELD_PROTECT, src)

/mob/living/simple_animal/construct/death()
	..()
	new /obj/item/weapon/reagent_containers/food/snacks/ectoplasm (src.loc)
	visible_message("<span class='red'>[src] collapses in a shattered heap.</span>")
	ghostize(bancheck = TRUE)
	qdel(src)
	return

/mob/living/simple_animal/construct/examine(mob/user)
	var/msg = "<span cass='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"
	to_chat(user, msg)

/mob/living/simple_animal/construct/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/construct/builder) && health <  maxHealth)
		health += min(health + 5, maxHealth)
		M.visible_message("[M] mends some of the <EM>[src]'s</EM> wounds.")
		return
	return ..()

/////////////////Juggernaut///////////////
/mob/living/simple_animal/construct/armoured
	name = "Juggernaut"
	real_name = "Juggernaut"
	desc = "A possessed suit of armour driven by the will of the restless dead."
	icon = 'icons/mob/mob.dmi'
	icon_state = "behemoth"
	icon_living = "behemoth"
	maxHealth = 250
	health = 250
	response_harm = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage = 30
	attacktext = "smash"
	speed = 3
	environment_smash = 2
	attack_sound = list('sound/weapons/punch3.ogg')
	status_flags = 0
	construct_spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall)

/mob/living/simple_animal/construct/armoured/atom_init()
	. = ..()
	var/obj/effect/effect/forcefield/rune/R = new
	AddComponent(/datum/component/forcefield, "strong blood aura", 40, 5 SECONDS, 6 SECONDS, R, TRUE, TRUE)
	SEND_SIGNAL(src, COMSIG_FORCEFIELD_PROTECT, src)

/mob/living/simple_animal/construct/armoured/Life()
	weakened = 0
	..()

/mob/living/simple_animal/construct/armoured/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
		var/reflectchance = 80 - round(P.damage/3)
		if(prob(reflectchance))
			adjustBruteLoss(P.damage * 0.5)
			visible_message("<span class='danger'>The [P.name] gets reflected by [src]'s shell!</span>", \
							"<span class='userdanger'>The [P.name] gets reflected by [src]'s shell!</span>")

			// Find a turf near or on the original location to bounce to
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
				var/new_y = P.starting.y + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
				var/turf/curloc = get_turf(src)

				// redirect the projectile
				P.redirect(new_x, new_y, curloc, src)

			return PROJECTILE_FORCE_MISS // complete projectile permutation

	return ..()


////////////////////////Wraith/////////////////////////////////////////////
/mob/living/simple_animal/construct/wraith
	name = "Wraith"
	real_name = "Wraith"
	desc = "A wicked bladed shell contraption piloted by a bound spirit."
	icon = 'icons/mob/mob.dmi'
	icon_state = "floating"
	icon_living = "floating"
	maxHealth = 75
	health = 75
	melee_damage = 25
	attacktext = "slash"
	speed = -1
	see_in_dark = 7
	attack_sound = list('sound/weapons/bladeslice.ogg')
	construct_spells = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift)


/////////////////////////////Artificer/////////////////////////
/mob/living/simple_animal/construct/builder
	name = "Artificer"
	real_name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining The Cult of Nar-Sie's armies."
	icon = 'icons/mob/mob.dmi'
	icon_state = "artificer"
	icon_living = "artificer"
	maxHealth = 50
	health = 50
	response_harm = "viciously beats"
	harm_intent_damage = 5
	melee_damage = 5
	attacktext = "ramm"
	speed = 0
	environment_smash = 2
	attack_sound = list('sound/weapons/punch2.ogg')
	construct_spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/wall,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/floor,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone)


/////////////////////////////Behemoth/////////////////////////
/mob/living/simple_animal/construct/behemoth
	name = "Behemoth"
	real_name = "Behemoth"
	desc = "The pinnacle of occult technology, Behemoths are the ultimate weapon in the Cult of Nar-Sie's arsenal."
	icon = 'icons/mob/mob.dmi'
	icon_state = "behemoth"
	icon_living = "behemoth"
	maxHealth = 750
	health = 750
	speak_emote = list("rumbles")
	response_harm = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage = 50
	attacktext = "brutally crush"
	speed = 5
	environment_smash = 2
	attack_sound = list('sound/weapons/punch4.ogg')
	var/energy = 0
	var/max_energy = 1000

/mob/living/simple_animal/construct/behemoth/atom_init()
	. = ..()
	var/obj/effect/effect/forcefield/rune/R = new
	AddComponent(/datum/component/forcefield, "strong blood aura", 40, 5 SECONDS, 6 SECONDS, R, TRUE, TRUE)
	SEND_SIGNAL(src, COMSIG_FORCEFIELD_PROTECT, src)


/////////////////////////////////////Harvester construct/////////////////////////////////
/mob/living/simple_animal/construct/harvester
	name = "Harvester"
	real_name = "Harvester"
	desc = "A harbinger of Nar-Sie's enlightenment. It'll be all over soon."
	icon = 'icons/mob/harvester.dmi'
	icon_state = "harvester"
	icon_living = "harvester"
	maxHealth = 60
	health = 60
	melee_damage = 3
	attacktext = "prodd"
	speed = 0
	environment_smash = 1
	see_in_dark = 7
	attack_sound = list('sound/weapons/slash.ogg')
	construct_spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/smoke)

/mob/living/simple_animal/construct/harvester/Process_Spacemove(movement_dir = 0)
	return 1
