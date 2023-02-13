/obj/effect/proc_holder/spell/no_target/spawn_bible
	name = "Create bible"
	desc = "Bible"

	charge_max = 2 MINUTES
	favor_cost = 100
	divine_power = 1 //count
	needed_aspects = list(ASPECT_RESOURCES = 1, ASPECT_RESCUE = 1)

	clothes_req = FALSE

	action_icon_state = "spawn_bible"
	sound = 'sound/effects/phasein.ogg'

/obj/effect/proc_holder/spell/no_target/spawn_bible/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/human/M in viewers(user.loc, null))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	for(var/i in 1 to divine_power)
		user.my_religion.spawn_bible(user.loc)


/obj/effect/proc_holder/spell/targeted/heal
	name = "Heal"

	favor_cost = 300
	charge_max = 1.5 MINUTES
	divine_power = -5 //power
	needed_aspects = list(ASPECT_RESCUE = 1, ASPECT_CHAOS = 1)

	clothes_req = FALSE
	range = 6
	selection_type = "range"

	action_icon_state = "heal"
	sound = 'sound/magic/heal.ogg'

/obj/effect/proc_holder/spell/targeted/heal/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/target = locate() in targets

	var/mob/living/carbon/human/H = target
	if(!(H in oview(range))) // If they are not in overview after selection.
		revert_cast()
		return

	H.apply_damages(divine_power * rand(-2, 10) * 0.1, divine_power * rand(-2, 10) * 0.1, divine_power * rand(-2, 10) * 0.1)

/obj/effect/proc_holder/spell/targeted/heal/revert_cast(mob/user = usr)
	. = ..()
	to_chat(user, "<span class='notice'>Target not found or too far away.</span>")
	

/obj/effect/proc_holder/spell/targeted/heal/damage
	name = "Punishment"

	favor_cost = 300
	charge_max = 1.5 MINUTES
	divine_power = 5 //power
	needed_aspects = list(ASPECT_OBSCURE = 1, ASPECT_CHAOS = 1)

	action_icon_state = "god_default"
	sound = 'sound/magic/Repulse.ogg'


/obj/effect/proc_holder/spell/blessing
	name = "Blessing"

	favor_cost = 200
	charge_max = 1 MINUTES
	divine_power = 8 //power
	needed_aspects = list(ASPECT_WEAPON = 1, ASPECT_MYSTIC = 1)

	range = 3
	clothes_req = FALSE

	action_icon_state = "blessing"
	sound = 'sound/magic/heal.ogg'

/obj/effect/proc_holder/spell/blessing/choose_targets(mob/user = usr)
	var/list/possible_targets = list()
	var/obj/item/target

	for(var/obj/item/W in orange(range, user))
		if(W.blessed == 0)
			possible_targets[W] = image(W.icon, W.icon_state)

	if(possible_targets.len == 0)
		revert_cast()
		to_chat(user, "<span class='warning'>Рядом с вами не обнаружено подходящих предметов.</span>")
		return

	target = show_radial_menu(user, user, possible_targets, radius = 36, tooltips = TRUE)
	if(!target)
		revert_cast()
		return

	perform(list(target), user=user)
	
/obj/effect/proc_holder/spell/blessing/cast(list/targets, mob/user = usr)
	var/obj/item/target = targets[1]

	target.visible_message("<span class='notice'>[target] has been blessed by [user]!</span>")
	target.name = "blessed [target.name]"
	target.force += divine_power
	target.add_filter("holy_spell_outline", 2, outline_filter(1, "#fffb00a1"))

	target.blessed = divine_power


/obj/effect/proc_holder/spell/no_target/charge/religion
	name = "Electric Charge Pulse"

	favor_cost = 400
	charge_max = 4 MINUTES
	divine_power = 1 //range
	needed_aspects = list(ASPECT_RESCUE = 1, ASPECT_TECH = 1)

	invocation_type = "none"
	clothes_req = FALSE

	action_icon_state = "charge"

/obj/effect/proc_holder/spell/no_target/charge/religion/proc/flick_sparks(atom/movable/AM)
	var/obj/effect/effect/sparks/blue/B = new /obj/effect/effect/sparks/blue(AM.loc)
	QDEL_IN(B, 6)

/obj/effect/proc_holder/spell/no_target/charge/religion/cast(list/targets, mob/user = usr)
	var/charged = FALSE

	for(var/I in range(divine_power))
		if(isrobot(I))
			var/mob/living/silicon/robot/R = I
			flick_sparks(R)
			if(R.cell)
				cell_charge(R.cell)
				charged = TRUE

		else if(istype(I, /obj/item/weapon/stock_parts/cell))
			flick_sparks(I)
			cell_charge(I)
			charged = TRUE

		else if(istype(I, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = I
			flick_sparks(B)
			B.charges = initial(B.charges)
			B.status = 1
			B.update_icon()
			charged = TRUE

		else if(istype(I, /obj/machinery/power/smes))
			flick_sparks(I)
			charged = TRUE
			for(var/obj/item/weapon/stock_parts/cell/Cell in I)
				cell_charge(Cell)

		else if(istype(I, /obj/mecha))
			var/obj/mecha/M = I
			flick_sparks(M)
			cell_charge(M.cell)
			charged = TRUE

		else if(istype(I, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/A = I
			flick_sparks(A)
			cell_charge(A.cell)
			charged = TRUE

	if(charged)
		playsound(user, 'sound/magic/Charge.ogg', VOL_EFFECTS_MASTER)
	else
		to_chat(user, "<span class='notice'>There is nothing to charge in the radius!</span>")
		revert_cast()
		return


/obj/effect/proc_holder/spell/no_target/food
	name = "Spawn food"

	favor_cost = 250
	charge_max = 3 MINUTES
	divine_power = 2 //count
	needed_aspects = list(ASPECT_SPAWN = 1 , ASPECT_FOOD = 1)

	clothes_req = FALSE

	action_icon_state = "spawn_food"
	sound = 'sound/effects/phasein.ogg'

/obj/effect/proc_holder/spell/no_target/food/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/human/M in viewers(user.loc))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	spawn_food(user.loc, 4 + rand(1, divine_power))


/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_animal
	name = "Create random friendly animal"

	favor_cost = 250
	charge_max = 2 MINUTES
	divine_power = 1 //count
	needed_aspects = list(ASPECT_SPAWN = 1)
	summon_amt = 1
	delay = 0

	clothes_req = FALSE

	action_icon_state = "spawn_animal"
	sound = 'sound/effects/phasein.ogg'

	summon_type = list(/mob/living/simple_animal/corgi/puppy, /mob/living/simple_animal/hostile/retaliate/goat, /mob/living/simple_animal/corgi, /mob/living/simple_animal/cat, /mob/living/simple_animal/parrot, /mob/living/simple_animal/crab, /mob/living/simple_animal/cow, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken, /mob/living/simple_animal/pig, /mob/living/simple_animal/turkey, /mob/living/simple_animal/goose, /mob/living/simple_animal/seal, /mob/living/simple_animal/walrus, /mob/living/simple_animal/fox, /mob/living/simple_animal/lizard, /mob/living/simple_animal/mouse, /mob/living/simple_animal/mushroom, /mob/living/simple_animal/pug, /mob/living/simple_animal/shiba, /mob/living/simple_animal/yithian, /mob/living/simple_animal/tindalos, /mob/living/carbon/monkey, /mob/living/carbon/monkey/skrell, /mob/living/carbon/monkey/tajara, /mob/living/carbon/monkey/unathi, /mob/living/simple_animal/slime)

/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_animal/cast(list/targets, mob/user = usr)
	if(summon_amt < divine_power)
		summon_amt = divine_power

	for(var/mob/living/carbon/human/M in viewers(user.loc, null))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()
	..()


/obj/effect/proc_holder/spell/no_target/grease
	name = "Spill grease"

	favor_cost = 500
	charge_max = 5 MINUTES
	divine_power = 1 //range
	needed_aspects = list(ASPECT_WACKY = 3)

	clothes_req = FALSE

	action_icon_state = "grease"
	sound = 'sound/magic/ForceWall.ogg'

/obj/effect/proc_holder/spell/no_target/grease/cast(list/targets, mob/user = usr)
	var/turf/T = get_turf(user)
	for(var/turf/simulated/floor/F in RANGE_TURFS(divine_power, T))
		F.make_wet_floor(LUBE_FLOOR)


/obj/effect/proc_holder/spell/no_target/infection
	name = "Spread a good infection"
	desc = "Good infection with viruses weight even and mind restoration"

	favor_cost = 300
	charge_max = 3 MINUTES
	divine_power = 1 //range
	needed_aspects = list(ASPECT_RESCUE = 1, ASPECT_OBSCURE = 1)

	range = 0
	clothes_req = FALSE

	action_icon_state = "infection_good"
	sound = 'sound/magic/Smoke.ogg'

	var/list/infected = list()
	var/obj/effect/proc_holder/spell/no_target/infection/obcurse/evil_spell

/obj/effect/proc_holder/spell/no_target/infection/cast(list/targets, mob/user = usr)
	var/datum/effect/effect/system/smoke_spread/chem/S = new
	create_reagents(10)
	reagents.add_reagent("tricordrazine", 10)
	S.attach(user.loc)
	S.set_up(reagents, 5, 0, user.loc)
	S.start()

	var/datum/disease2/effectholder/hungry_holder = new
	hungry_holder.effect = new /datum/disease2/effect/weight_even()
	hungry_holder.chance = rand(hungry_holder.effect.chance_minm, hungry_holder.effect.chance_maxm)
	var/datum/disease2/disease/hungry = new
	hungry.addeffect(hungry_holder)

	var/datum/disease2/effectholder/mind_holder = new
	mind_holder.effect = new /datum/disease2/effect/mind_restoration()
	mind_holder.chance = rand(mind_holder.effect.chance_minm, mind_holder.effect.chance_maxm)
	var/datum/disease2/disease/mind = new
	mind.addeffect(mind_holder)

	// That would not infect infected.
	if(!evil_spell)
		for(var/obj/effect/proc_holder/spell/no_target/infection/obcurse/O in user.spell_list)
			evil_spell = O

	for(var/mob/living/carbon/human/H in range(divine_power))
		if(evil_spell)
			if(H in evil_spell.infected)
				continue
			infected += H

		infect_virus2(H, mind)
		infect_virus2(H, hungry)


/obj/effect/proc_holder/spell/no_target/infection/obcurse
	name = "Spread a evil infection"
	desc = "Evil infection with viruses cough and headache"

	needed_aspects = list(ASPECT_DEATH = 1, ASPECT_OBSCURE = 1)

	action_icon_state = "infection_evil"

	var/obj/effect/proc_holder/spell/no_target/infection/good_spell

/obj/effect/proc_holder/spell/no_target/infection/obcurse/cast(list/targets, mob/user = usr)
	var/datum/effect/effect/system/smoke_spread/chem/S = new
	create_reagents(1)
	reagents.add_reagent("harvester", 1)
	S.attach(user.loc)
	S.set_up(reagents, 5, 0, user.loc)
	S.color = "#421c52" //dark purple
	S.start()

	var/datum/disease2/effectholder/cough_holder = new
	cough_holder.effect = new /datum/disease2/effect/cough()
	cough_holder.chance = rand(cough_holder.effect.chance_minm, cough_holder.effect.chance_maxm)
	var/datum/disease2/disease/cough = new
	cough.addeffect(cough_holder)

	var/datum/disease2/effectholder/headache_holder = new
	headache_holder.effect = new /datum/disease2/effect/headache()
	headache_holder.chance = rand(headache_holder.effect.chance_minm, headache_holder.effect.chance_maxm)
	var/datum/disease2/disease/headache = new
	headache.addeffect(headache_holder)

	// That would not infect infected.
	if(!good_spell)
		for(var/obj/effect/proc_holder/spell/no_target/infection/O in user.spell_list)
			if(istype(O, /obj/effect/proc_holder/spell/no_target/infection))
				good_spell = O

	for(var/mob/living/carbon/human/H in range(divine_power))
		if(H.mind && H.mind.holy_role >= HOLY_ROLE_PRIEST)
			continue
		if(good_spell)
			if(H in good_spell.infected)
				continue
			infected += H

		infect_virus2(H, cough)
		infect_virus2(H, headache)


/obj/effect/proc_holder/spell/no_target/rot
	name = "The smell of rot"
	desc = "Spread smoke with Thermopsis"

	favor_cost = 150
	charge_max = 3 MINUTES
	divine_power = 1 //count gibs
	needed_aspects = list(ASPECT_FOOD = 1, ASPECT_OBSCURE = 2)

	clothes_req = FALSE

	action_icon_state = "rot"
	sound = 'sound/magic/Smoke.ogg'

/obj/effect/proc_holder/spell/no_target/rot/cast(list/targets, mob/user = usr)
	var/datum/effect/effect/system/smoke_spread/chem/S = new
	create_reagents(30)
	reagents.add_reagent("thermopsis", 30)
	S.attach(user.loc)
	S.set_up(reagents, 2, 0, user.loc)
	S.color = "#3d0606" //dark red
	S.start()

	if(divine_power >= 1)
		gibs(user.loc)
		if(divine_power >= 2)
			hgibs(user.loc)


/obj/effect/proc_holder/spell/no_target/scribe_rune
	name = "Руна"
	desc = "Рисовать запомненную руну."

	charge_max = 1 MINUTE

	clothes_req = FALSE

	action_icon_state = "rune"
	action_background_icon_state = "bg_cult"

	var/datum/building_agent/rune/agent

/obj/effect/proc_holder/spell/no_target/scribe_rune/Destroy()
	agent = null
	return ..()

/obj/effect/proc_holder/spell/no_target/scribe_rune/cast(list/targets, mob/user = usr)
	if(!user.my_religion)
		user.RemoveSpell(src)
		return

	var/list/L = LAZYACCESS(user.my_religion.runes_by_ckey, user.ckey)
	if(!isnull(L) && L.len >= user.my_religion.max_runes_on_mob)
		to_chat(user, "<span class='warning'>Ваше тело слишком слабо, чтобы выдержать ещё больше рун!</span>")
		return

	var/obj/effect/rune/R = new agent.building_type(get_turf(user), user.my_religion, user)
	var/datum/rune/rune = new agent.rune_type(R)
	rune.religion = user.my_religion
	R.power = rune
	R.icon = get_uristrune_cult(TRUE, rune.words)


/obj/effect/proc_holder/spell/no_target/memorize_rune
	name = "Запомнить руну"
	desc = "Запоминает руну и позволяет её рисовать без тома."

	clothes_req = FALSE

	action_icon_state = "rune"
	action_background_icon_state = "bg_cult"

	var/choosing = FALSE

/obj/effect/proc_holder/spell/no_target/memorize_rune/cast(list/targets, mob/user = usr)
	if(!user.my_religion)
		user.RemoveSpell(src)
		return
	if(choosing)
		return

	choosing = TRUE
	var/datum/building_agent/rune/B = input("Выберите руну", name, "") as null|anything in user.my_religion.available_runes
	if(!B)
		choosing = FALSE
		revert_cast()
		return

	var/obj/effect/proc_holder/spell/no_target/scribe_rune/S = new
	S.agent = B
	S.name = initial(B.name)
	user.AddSpell(S)
	user.RemoveSpell(src)
