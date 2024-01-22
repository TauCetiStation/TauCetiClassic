/obj/effect/proc_holder/spell/aoe_turf/conjure
	name = "Conjure"
	desc = "This spell conjures objs of the specified types in range."

	var/list/summon_type = list() //determines what exactly will be summoned

	var/summon_lifespan = 0 // 0=permanent, any other time in deciseconds
	var/summon_amt = 1 //amount of objects summoned
	var/summon_ignore_density = FALSE //if set to 1, adds dense tiles to possible spawn places
	var/summon_ignore_prev_spawn_points = 0 //if set to 1, each new object is summoned on a new spawn point
	var/deleting_previous = 0 //if set to 1, a new cast delete previous objects
	var/list/previous_objects = list() // Containts object references, which was spawned last time.

	var/list/newVars = list() //vars of the summoned objects will be replaced with those where they meet
	//should have format of list("emagged" = 1,"name" = "Wizard's Justicebot"), for example
	var/delay = 1//Go Go Gadget Inheritance
	sound = 'sound/items/welder.ogg'

/obj/effect/proc_holder/spell/aoe_turf/conjure/cast(list/targets)

	for(var/turf/T in targets)
		if(T.density && !summon_ignore_density)
			targets -= T
	playsound(usr, sound, VOL_EFFECTS_MASTER)

	if(do_after(usr,delay,target=usr))
		if(deleting_previous)
			listclearnulls(previous_objects)
			for(var/atom/A in previous_objects)
				qdel(A)
				previous_objects -= A
		for(var/i in 1 to summon_amt)
			if(!targets.len)
				break
			var/summoned_object_type = pick(summon_type)
			var/spawn_place = pick(targets)
			if(summon_ignore_prev_spawn_points)
				targets -= spawn_place
			if(ispath(summoned_object_type,/turf))
				var/turf/O = spawn_place
				var/turf/N = summoned_object_type
				O.ChangeTurf(N)
			else
				var/atom/summoned_object = new summoned_object_type(spawn_place)

				for(var/varName in newVars)
					if(varName in summoned_object.vars)
						summoned_object.vars[varName] = newVars[varName]

				if(summon_lifespan)
					QDEL_IN(summoned_object, summon_lifespan)
				if(deleting_previous)
					previous_objects += summoned_object

	else
		switch(charge_type)
			if("recharge")
				charge_counter = charge_max - 5//So you don't lose charge for a failed spell(Also prevents most over-fill)
			if("charges")
				charge_counter++//Ditto, just for different spell types


	return

/obj/effect/proc_holder/spell/aoe_turf/conjure/summonEdSwarm //test purposes
	name = "Dispense Wizard Justice"
	desc = "This spell dispenses wizard justice."

	summon_type = list(/obj/machinery/bot/secbot/ed209)
	summon_amt = 10
	range = 3
	newVars = list("emagged" = 1,"name" = "Wizard's Justicebot")


//This was previously left in the old wizard code, not being included.
//Wasn't sure if I should transfer it here, or to code/datums/spells.dm
//But I decided because it is a conjuration related object it would fit better here
//Feel free to change this, I don't know.
/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon = 'icons/effects/effects.dmi'
	icon_state = "m_shield"
	anchored = TRUE
	opacity = 0
	density = TRUE
	unacidable = 1
	can_block_air = TRUE

/obj/effect/forcefield/magic
	var/mob/wizard

/obj/effect/forcefield/magic/atom_init(mapload, mob/wiz, timeleft = 300)
	. = ..()
	wizard = wiz
	QDEL_IN(src, timeleft)

/obj/effect/forcefield/magic/CanPass(atom/movable/mover, turf/target, height=0)
	if(mover == wizard)
		return TRUE
	return FALSE

/obj/effect/forcefield/cult
	name = "Blood Shield"
	desc = "Like erythrocyte, the cells form a force barrier."
	icon = 'icons/effects/effects.dmi'
	icon_state = "cultshield"

/obj/effect/forcefield/cult/alt_app
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/forcefield/cult/alt_app/atom_init()
	. = ..()
	var/image/I = image('icons/effects/effects.dmi', src, "cultshield")
	I.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/holy_role, "cult_wall", I)

/obj/effect/proc_holder/spell/aoe_turf/conjure/smoke
	name = "Парализующий Дым"
	desc = "Это заклинание создает парализующий дым."

	school = "conjuration"
	charge_max = 200
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 1

	action_icon_state = "rot"
	action_background_icon_state = "bg_cult"

/obj/effect/proc_holder/spell/aoe_turf/conjure/smoke/cast()
	var/datum/effect/effect/system/smoke_spread/chem/S = new
	var/turf/location = get_turf(loc)
	create_reagents(80)
	reagents.add_reagent("harvester", 80)
	S.attach(location)
	S.set_up(reagents, 5, 0, location, 15, 5)
	S.start()

/datum/reagent/toxin/harvester
	name = "Harvester Toxin"
	id = "harvester"
	description = "A toxic cloud."
	color = "#9c3636"
	toxpwr = 0
	custom_metabolism = 1

/datum/reagent/toxin/harvester/on_general_digest(mob/living/carbon/M)
	..()
	if(!data)
		data = 1
	if(!volume)
		volume = 1
	if(volume > 5)
		M.Stun(2)
		M.Weaken(4)

/obj/effect/proc_holder/spell/no_target/area_conversion
	name = "Обращение Зоны"
	desc = "Это заклинание моментально делает небольшую зону вокруг вас подвластной вашей Вере"
	clothes_req = FALSE
	charge_max = 5 SECONDS
	action_icon_state = "areaconvert"
	action_background_icon_state = "bg_cult"
	range = 3

/obj/effect/proc_holder/spell/no_target/area_conversion/cast(list/targets, mob/user)
	if(!user.my_religion)
		return
	. = ..()
	for(var/turf/nearby_turf in range(range, user))
		if(prob(100 - (get_dist(nearby_turf, user) * 25)))
			playsound(nearby_turf, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER)
			nearby_turf.atom_religify(user.my_religion)

/obj/effect/proc_holder/spell/no_target/area_conversion/lesser
	charge_max = 25 SECONDS
	range = 2
