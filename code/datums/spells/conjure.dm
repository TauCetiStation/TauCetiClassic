/obj/effect/proc_holder/spell/aoe_turf/conjure
	name = "Conjure"
	desc = "This spell conjures objs of the specified types in range."

	var/list/summon_type = list() //determines what exactly will be summoned
	//should be text, like list("/obj/machinery/bot/ed209")

	var/summon_lifespan = 0 // 0=permanent, any other time in deciseconds
	var/summon_amt = 1 //amount of objects summoned
	var/summon_ignore_density = 0 //if set to 1, adds dense tiles to possible spawn places
	var/summon_ignore_prev_spawn_points = 0 //if set to 1, each new object is summoned on a new spawn point

	var/list/newVars = list() //vars of the summoned objects will be replaced with those where they meet
	//should have format of list("emagged" = 1,"name" = "Wizard's Justicebot"), for example
	var/delay = 1//Go Go Gadget Inheritance

/obj/effect/proc_holder/spell/aoe_turf/conjure/cast(list/targets)

	for(var/turf/T in targets)
		if(T.density && !summon_ignore_density)
			targets -= T
	playsound(src.loc, 'sound/items/welder.ogg', 50, 1)

	if(do_after(usr,delay,target=usr))
		for(var/i=0,i<summon_amt,i++)
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
					spawn(summon_lifespan)
						if(summoned_object)
							qdel(summoned_object)
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

	summon_type = list(/obj/machinery/bot/ed209)
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
	anchored = 1.0
	opacity = 0
	density = 1
	unacidable = 1


	bullet_act(obj/item/projectile/Proj, def_zone)
		var/turf/T = get_turf(src.loc)
		if(T)
			for(var/mob/M in T)
				Proj.on_hit(M,M.bullet_act(Proj, def_zone))
		return
		
/obj/effect/proc_holder/spell/aoe_turf/conjure/smoke
	name = "Paralysing Smoke"
	desc = "This spell spawns a cloud of paralysing smoke."

	school = "conjuration"
	charge_max = 200
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 1

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
	color = "#9C3636"
	toxpwr = 0
	custom_metabolism = 1
	
	on_mob_life(var/mob/living/carbon/M as mob)
		if(!M) M = holder.my_atom
		if(!data) data = 1
		if(!volume) volume = 1
		if(volume > 5)
			M.Weaken(4)
		return
