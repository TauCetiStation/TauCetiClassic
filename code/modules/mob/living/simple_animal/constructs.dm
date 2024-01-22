/mob/living/simple_animal/construct
	name = "Construct"
	real_name = "Construct"
	desc = "Оно двигается..?"
	icon = 'icons/mob/construct.dmi'
	speak_emote = list("шипит")
	emote_hear = list("стонет", "визжит")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm = "punches"
	icon_dead = "shade_dead"
	speed = -1
	a_intent = INTENT_HARM
	stop_automated_movement = TRUE
	status_flags = CANPUSH
	universal_speak = 1
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
	can_point = TRUE

/mob/living/simple_animal/construct/atom_init()
	attack_sound = SOUNDIN_PUNCH_MEDIUM
	. = ..()
	name = text("[initial(name)] ([rand(1, 1000)])")
	real_name = name
	for(var/spell in construct_spells)
		AddSpell(new spell(src))

	var/obj/effect/effect/forcefield/rune/R = new
	AddComponent(/datum/component/forcefield, "blood aura", 20, 5 SECONDS, 3 SECONDS, R, TRUE, TRUE)
	SEND_SIGNAL(src, COMSIG_FORCEFIELD_PROTECT, src)

	var/image/glow = image(icon, src, "glow_[icon_state]", ABOVE_LIGHTING_LAYER)
	glow.plane = LIGHTING_LAMPS_PLANE
	add_overlay(glow)

	ADD_TRAIT(src, TRAIT_ARIBORN, TRAIT_ARIBORN_FLYING)

/mob/living/simple_animal/construct/death()
	..()
	new /obj/item/weapon/reagent_containers/food/snacks/ectoplasm(src.loc)
	visible_message("<span class='red'>[src] collapses in a shattered heap.</span>")
	ghostize(bancheck = TRUE)
	qdel(src)

/mob/living/simple_animal/construct/ghostize(can_reenter_corpse, bancheck)
	if(!QDELETED(src) && key && ckey)
		qdel(src)
	. = ..()

/mob/living/simple_animal/construct/examine(mob/user)
	var/msg = "<span cass='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"

	if(w_class)
		msg += "It is a [get_size_flavor()] sized creature.\n"

	msg += "*---------*</span>"
	to_chat(user, msg)

/mob/living/simple_animal/construct/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/construct/builder) && health <  maxHealth)
		health += min(health + 5, maxHealth)
		med_hud_set_health()
		M.visible_message("[M] mends some of the <EM>[src]'s</EM> wounds.")
		return
	return ..()

/////////////////Juggernaut///////////////
/mob/living/simple_animal/construct/armoured/fire_halloween
	name = "Fire Eye"
	icon_state = "firejuggernaut"
	icon_living = "firejuggernaut"
	melee_damage = 10
	speed = 2
	construct_spells = list(
		/obj/effect/proc_holder/spell/aoe_turf/hulk_lazor,
		/obj/effect/proc_holder/spell/aoe_turf/hulk_spit
	)

/obj/effect/proc_holder/spell/targeted/inflict_handler/disintegrate/halloween
	clothes_req = 0

/mob/living/simple_animal/construct/armoured/pain_halloween
	name = "Incarnation of Pain"
	icon_state = "pain"
	icon_living = "pain"
	melee_damage = 5
	speed = 5
	construct_spells = list(
		/obj/effect/proc_holder/spell/targeted/inflict_handler/disintegrate/halloween
	)

/obj/effect/proc_holder/spell/aoe_turf/repulse/halloween
	clothes_req = 0

/mob/living/simple_animal/construct/armoured/golem_halloween
	name = "Metal Golem"
	icon_state = "golem"
	icon_living = "golem"
	melee_damage = 35
	speed = 4
	construct_spells = list(
		/obj/effect/proc_holder/spell/aoe_turf/repulse/halloween
	)

/mob/living/simple_animal/construct/armoured
	name = "Juggernaut"
	real_name = "Juggernaut"
	desc = "Одержимый доспех, управляемый волей беспокойных мертвецов."
	icon_state = "juggernaut"
	icon_living = "juggernaut"
	maxHealth = 200
	health = 200
	response_harm = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage = 25
	attacktext = "smash"
	speed = 3
	w_class = SIZE_MASSIVE
	environment_smash = 2
	status_flags = 0
	construct_spells = list(
			/obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall,
			)

/mob/living/simple_animal/construct/armoured/atom_init()
	attack_sound = SOUNDIN_PUNCH_VERYHEAVY
	. = ..()
	var/obj/effect/effect/forcefield/rune/R = new
	AddComponent(/datum/component/forcefield, "strong blood aura", 80, 5 SECONDS, 6 SECONDS, R, TRUE, TRUE)
	SEND_SIGNAL(src, COMSIG_FORCEFIELD_PROTECT, src)

/mob/living/simple_animal/construct/armoured/bullet_act(obj/item/projectile/P, def_zone)
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
/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/phaseshift/hell
	dissapear_animation = icon(icon = 'icons/mob/construct.dmi', icon_state = "infernal_rift_out")
	appear_animation = icon(icon = 'icons/mob/construct.dmi', icon_state = "infernal_rift_in")

/mob/living/simple_animal/construct/wraith/hellknight_halloween
	name = "Hell Knight"
	real_name = "Hell Knight"
	desc = "Hell Knight."
	icon_state = "hell_knight"
	icon_living = "hell_knight"
	speed = 1
	melee_damage = 25
	construct_spells = list(
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/phaseshift/hell
		)

/obj/effect/proc_holder/spell/targeted/emplosion/disable_tech/halloween
	clothes_req = FALSE

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/phaseshift/envoy
	dissapear_animation = icon(icon = 'icons/mob/construct.dmi', icon_state = "shadowstep_out")
	appear_animation = icon(icon = 'icons/mob/construct.dmi', icon_state = "shadowstep_in")

/mob/living/simple_animal/construct/wraith/envoy_halloween
	name = "Envoy of Death"
	real_name = "Envoy of Death"
	desc = "Envoy of Death."
	icon_state = "envoy_of_death"
	icon_living = "envoy_of_death"
	speed = 0
	construct_spells = list(
		/obj/effect/proc_holder/spell/targeted/emplosion/disable_tech/halloween,
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/phaseshift/envoy
		)

/mob/living/simple_animal/construct/wraith/firewraith_halloween
	name = "Fire Demon"
	real_name = "Fire Demon"
	desc = "Зловещий демон, управляемый духом."
	icon_state = "firewraith"
	icon_living = "firewraith"
	melee_damage = 10
	speed = 0
	construct_spells = list(
		/obj/effect/proc_holder/spell/dumbfire/fireball
		)

/mob/living/simple_animal/construct/wraith
	name = "Wraith"
	real_name = "Wraith"
	desc = "Зловещий доспех с клинками, управляемый связанным духом."
	icon_state = "wraith"
	icon_living = "wraith"
	maxHealth = 75
	health = 75
	melee_damage = 20
	attacktext = "slash"
	speed = -1
	see_in_dark = 7
	attack_sound = list('sound/weapons/bladeslice.ogg')
	attack_push_vis_effect = ATTACK_EFFECT_SLASH
	attack_disarm_vis_effect = ATTACK_EFFECT_SLASH
	construct_spells = list(
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/phaseshift,
		)


/////////////////////////////Artificer/////////////////////////
/mob/living/simple_animal/construct/builder/summoner_halloween
	name = "Summoner"
	real_name = "Summoner"
	desc = "Summoner."
	icon_state = "summoner"
	icon_living = "summoner"
	melee_damage = 15
	speed = -1
	construct_spells = list(
		/obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall,
		/obj/effect/proc_holder/spell/targeted/forcewall,
		/obj/effect/proc_holder/spell/targeted/smoke,
		)

/obj/effect/proc_holder/spell/targeted/lighting_shock/halloween
	charge_max = 100
	clothes_req = 0

/mob/living/simple_animal/construct/builder/firetower_halloween
	name = "Fire Tower"
	real_name = "Fire Tower"
	desc = "Fire Tower."
	icon_state = "fireartificer"
	icon_living = "fireartificer"
	melee_damage = 5
	construct_spells = list(
		/obj/effect/proc_holder/spell/targeted/lighting_shock/halloween
		)

/mob/living/simple_animal/construct/builder
	name = "Artificer"
	real_name = "Artificer"
	desc = "Выпуклая структура, предназначенная для создания и поддержания армий Культа Нар-Си."
	icon_state = "artificer"
	icon_living = "artificer"
	maxHealth = 50
	health = 50
	response_harm = "viciously beats"
	harm_intent_damage = 5
	melee_damage = 10
	attacktext = "ramm"
	speed = -0.2
	environment_smash = 2
	construct_spells = list(
		/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser,
		/obj/effect/proc_holder/spell/aoe_turf/conjure/door,
		/obj/effect/proc_holder/spell/aoe_turf/conjure/wall,
		/obj/effect/proc_holder/spell/aoe_turf/conjure/floor,
		/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone,
		)

/mob/living/simple_animal/construct/builder/atom_init()
	attack_sound = SOUNDIN_PUNCH_MEDIUM
	. = ..()
	var/datum/atom_hud/data/medical/adv/hud = global.huds[DATA_HUD_MEDICAL_ADV]
	hud.add_hud_to(src)

/////////////////////////////Behemoth/////////////////////////
/mob/living/simple_animal/construct/behemoth
	name = "Behemoth"
	real_name = "Behemoth"
	desc = "Вершина оккультных технологий. Бегемоты — лучшее оружие в арсенале Культа Нар-Си."
	icon_state = "juggernaut"
	icon_living = "juggernaut"
	maxHealth = 10
	health = 10
	speak_emote = list("rumbles")
	response_harm = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage = 50
	attacktext = "brutally crush"
	speed = 5
	environment_smash = 2
	w_class = SIZE_MASSIVE
	resize = 1.2

/mob/living/simple_animal/construct/behemoth/atom_init()
	attack_sound = SOUNDIN_PUNCH_HEAVY
	. = ..()
	var/obj/effect/effect/forcefield/rune/R = new
	AddComponent(/datum/component/forcefield, "strong blood aura", 500, 30 SECONDS, 10 SECONDS, R, TRUE, TRUE)
	SEND_SIGNAL(src, COMSIG_FORCEFIELD_PROTECT, src)


/////////////////////////////////////Harvester construct/////////////////////////////////
/mob/living/simple_animal/construct/harvester/necro_halloween
	name = "Necrophage"
	desc = "Necrophage"
	icon_state = "necrophage"
	icon_living = "necrophage"
	maxHealth = 90
	health = 90
	speed = 1
	construct_spells = list(
		/obj/effect/proc_holder/spell/aoe_turf/conjure/smoke,
		/obj/effect/proc_holder/spell/no_target/rot
		)

/mob/living/simple_animal/construct/harvester/necro_halloween/add_conversion_area_spell()
	return

/obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps/halloween
	clothes_req = 0

/mob/living/simple_animal/construct/harvester/fireharvest_halloween
	name = "Fire Harvester"
	desc = "Предвестник"
	icon_state = "fireharvester"
	icon_living = "fireharvester"
	construct_spells = list(
		/obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps/halloween
		)

/mob/living/simple_animal/construct/harvester/fireharvest_halloween/add_conversion_area_spell()
	return

/obj/effect/proc_holder/spell/targeted/inflict_handler/blind/halloween
	clothes_req = FALSE

/mob/living/simple_animal/construct/harvester/boneshaper_halloween
	name = "Boneshaper"
	desc = "Boneshaper"
	icon_state = "boneshaper"
	icon_living = "boneshaper"
	maxHealth = 120
	health = 120
	melee_damage = 5
	construct_spells = list(
		/obj/effect/proc_holder/spell/targeted/trigger/blind,
		/obj/effect/proc_holder/spell/targeted/inflict_handler/blind/halloween
		)
/mob/living/simple_animal/construct/harvester/boneshaper_halloween/add_conversion_area_spell()
	return

/mob/living/simple_animal/construct/harvester
	name = "Harvester"
	real_name = "Harvester"
	desc = "Предвестник просветления Нар-Си. Скоро все будет кончено."
	icon_state = "harvester"
	icon_living = "harvester"
	maxHealth = 60
	health = 60
	melee_damage = 8
	attacktext = "prodd"
	speed = 0
	environment_smash = 1
	see_in_dark = 7
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	density = FALSE
	attack_sound = list('sound/weapons/slash.ogg')
	attack_push_vis_effect = ATTACK_EFFECT_SLASH
	attack_disarm_vis_effect = ATTACK_EFFECT_SLASH
	pass_flags = PASSTABLE
	construct_spells = list(
		/obj/effect/proc_holder/spell/aoe_turf/conjure/smoke,
		)
/mob/living/simple_animal/construct/harvester/atom_init()
	. = ..()
	add_conversion_area_spell()

/mob/living/simple_animal/construct/harvester/proc/add_conversion_area_spell()
	if(SSticker.nar_sie_has_risen)
		AddSpell(new /obj/effect/proc_holder/spell/no_target/area_conversion(src))
	else
		AddSpell(new /obj/effect/proc_holder/spell/no_target/area_conversion/lesser(src))

/mob/living/simple_animal/construct/harvester/Bump(atom/A)
	. = ..()
	if(A == loc)
		return
	var/its_wall = FALSE
	if(istype(A, /turf/simulated/wall/cult))
		its_wall = TRUE

	if(its_wall || istype(A, /obj/structure/mineral_door/cult) || istype(A, /obj/structure/cult) || isconstruct(A) || istype(A, /mob/living/simple_animal/hostile/pylon))
		var/atom/movable/stored_pulling = pulling
		if(stored_pulling)
			stored_pulling.set_dir(get_dir(stored_pulling.loc, loc))
			stored_pulling.forceMove(loc)

		if(its_wall)
			forceMove(A)
		else
			forceMove(A.loc)

		if(stored_pulling)
			start_pulling(stored_pulling) //drag anything we're pulling through the wall with us by magic

/mob/living/simple_animal/construct/harvester/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/living/simple_animal/construct/harvester/UnarmedAttack(atom/A)
	if(ishuman(A) && prob(20))
		if(get_targetzone() == BP_HEAD) // No
			return ..()
		var/mob/living/carbon/human/C = A
		var/obj/item/organ/external/BP = C.get_bodypart(get_targetzone())
		if(BP && !BP.droplimb(FALSE, FALSE, DROPLIMB_EDGE))
			return ..() //Attack
		return
	return ..()

/////////////////////////////////////Proteon from tg/////////////////////////////////
/mob/living/simple_animal/construct/proteon
	name = "Proteon"
	real_name = "Proteon"
	desc = "Слабая конструкция, предназначенная для обыска руин в поисках предметов привязанности Нар'Си. Эти зазубренные когти — не шутка."
	icon_state = "proteon"
	icon_living = "proteon"
	maxHealth = 30
	health = 30
	melee_damage = 35
	speed = -2
	response_harm = "pinch"

	sight = SEE_MOBS

/mob/living/simple_animal/construct/proteon/atom_init()
	attack_sound = SOUNDIN_PUNCH_HEAVY
	. = ..()


/////////////////////////////////////Charged Pylon not construct/////////////////////////////////
/mob/living/simple_animal/hostile/pylon
	name = "charged pylon"
	real_name = "charged pylon"
	desc = "Летающий кристалл, излучающий таинственную энергию."
	icon = 'icons/obj/cult.dmi'
	icon_state = "pylon_glow"
	icon_living = "pylon"
	ranged = TRUE
	amount_shoot = 3
	projectiletype = /obj/item/projectile/beam/cult_laser
	projectilesound = 'sound/weapons/guns/gunpulse_laser.ogg'
	ranged_cooldown = 5
	ranged_cooldown_cap = 0
	maxHealth = 120
	health = 120
	melee_damage = 0
	speed = 0
	anchored = TRUE
	stop_automated_movement = TRUE
	canmove = FALSE
	faction = "cult"
	var/timer

/mob/living/simple_animal/hostile/pylon/atom_init()
	. = ..()
	friends = global.cult_religion?.members

/mob/living/simple_animal/hostile/pylon/death(gibbed)
	. = ..()
	for(var/atom/A in contents)
		qdel(A)
	qdel(src)

/mob/living/simple_animal/hostile/pylon/proc/deactivate()
	for(var/obj/structure/cult/pylon/P in contents)
		P.update_integrity(health)
		P.forceMove(loc)
	qdel(src)

/mob/living/simple_animal/hostile/pylon/proc/add_friend(datum/religion/R, mob/M, holy_role)
	friends = R.members

/mob/living/simple_animal/hostile/pylon/attackby(obj/item/I, mob/user, params)
	if(iscultist(user))
		if(istype(I, /obj/item/weapon/storage/bible/tome))
			deactivate()
			deltimer(timer)
	else
		return ..()

/mob/living/simple_animal/hostile/pylon/update_canmove()
	return

/mob/living/simple_animal/hostile/pylon/UnarmedAttack(atom/A)
	SEND_SIGNAL(src, COMSIG_MOB_HOSTILE_ATTACKINGTARGET, A)
	OpenFire(A)
