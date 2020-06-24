/********Hydralic clamp********/
/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	name = "hydraulic clamp"
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	var/dam_force = 20
	var/obj/mecha/working/ripley/cargo_holder

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/can_attach(obj/mecha/working/ripley/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/attach(obj/mecha/M)
	..()
	cargo_holder = M
	return

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/action(atom/target)
	if(!action_checks(target)) return
	if(!cargo_holder) return
	if(istype(target, /obj/structure/stool)) return
	for(var/M in target.contents)
		if(istype(M, /mob/living))
			return

	if(istype(target,/obj))
		var/obj/O = target
		if(!O.anchored)
			if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
				occupant_message("You lift [target] and start to load it into cargo compartment.")
				chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
				set_ready_state(0)
				chassis.use_power(energy_drain)
				O.anchored = 1
				var/T = chassis.loc
				if(do_after_cooldown(target))
					if(T == chassis.loc && src == chassis.selected)
						cargo_holder.cargo += O
						O.loc = chassis
						O.anchored = 0
						occupant_message("<font color='blue'>[target] succesfully loaded.</font>")
						log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
					else
						occupant_message("<font color='red'>You must hold still while handling objects.</font>")
						O.anchored = initial(O.anchored)
			else
				occupant_message("<font color='red'>Not enough room in cargo compartment.</font>")
		else if(istype(target, /obj/structure/scrap))
			var/obj/structure/scrap/pile = target
			playsound(target, 'sound/effects/metal_creaking.ogg', VOL_EFFECTS_MASTER)
			if(do_after_cooldown(pile))
				occupant_message("<font color='red'>You squeeze the [pile.name] into compact shape.</font>")
				pile.make_cube()
			else
				occupant_message("<font color='red'>[target] is firmly secured.</font>")
		else if(istype(target, /obj/structure/droppod))
			var/obj/structure/droppod/Drop = target
			if(Drop.flags & STATE_DROPING || Drop.intruder || Drop.second_intruder)
				return
			var/T = chassis.loc
			if(do_after_cooldown(Drop) && T == chassis.loc && src == chassis.selected\
			&& !Drop.intruder && !Drop.second_intruder && !(Drop.flags & STATE_DROPING) && !(Drop.flags & STATE_AIMING))
				cargo_holder.cargo += Drop
				Drop.loc = chassis
				occupant_message("<font color='blue'>[target] succesfully loaded.</font>")
				log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
				return 1

	else if(istype(target,/mob/living))
		var/mob/living/M = target
		if(M.stat>1) return
		if(chassis.occupant.a_intent == INTENT_HARM)
			M.take_overall_damage(dam_force)
			M.adjustOxyLoss(round(dam_force/2))
			M.updatehealth()
			occupant_message("<span class='warning'>You squeeze [target] with [src.name]. Something cracks.</span>")
			chassis.visible_message("<span class='warning'>[chassis] squeezes [target].</span>")

			M.log_combat(chassis.occupant, "attacked via [chassis]'s [name]")
		else
			step_away(M,chassis)
			occupant_message("You push [target] out of the way.")
			chassis.visible_message("[chassis] pushes [target] out of the way.")
		set_ready_state(0)
		chassis.use_power(energy_drain)
		do_after_cooldown()
	return 1


/********Drill********/
/obj/item/mecha_parts/mecha_equipment/tool/drill
	name = "drill"
	desc = "This is the drill that'll pierce the heavens! (Can be attached to: Combat and Engineering Exosuits)"
	icon_state = "mecha_drill"
	equip_cooldown = 30
	energy_drain = 10
	force = 15
	var/penetration = 5

/obj/item/mecha_parts/mecha_equipment/tool/drill/action(atom/target)
	if(!action_checks(target)) return
	if(isobj(target))
		var/obj/target_obj = target
		if(!target_obj.vars.Find("unacidable") || target_obj.unacidable)	return
	set_ready_state(0)
	chassis.use_power(energy_drain)
	chassis.visible_message("<font color='red'><b>[chassis] starts to drill [target]</b></font>", "You hear the drill.")
	occupant_message("<font color='red'><b>You start to drill [target]</b></font>")
	var/T = chassis.loc
	var/C = target.loc	//why are these backwards? we may never know -Pete
	if(do_after_cooldown(target))
		if(T == chassis.loc && src == chassis.selected)
			if(istype(target, /turf/simulated/wall/r_wall))
				occupant_message("<font color='red'>[target] is too durable to drill through.</font>")
			else if(istype(target, /turf/simulated/mineral))
				for(var/turf/simulated/mineral/M in range(chassis,1))
					if(get_dir(chassis,M)&chassis.dir)
						M.GetDrilled()
				log_message("Drilled through [target]")
				if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
					var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
					if(ore_box)
						for(var/obj/item/weapon/ore/ore in range(chassis,1))
							if(get_dir(chassis,ore)&chassis.dir)
								ore.Move(ore_box)
			else if(istype(target, /turf/simulated/floor/plating/airless/asteroid))
				for(var/turf/simulated/floor/plating/airless/asteroid/M in range(chassis,1))
					if(get_dir(chassis,M)&chassis.dir)
						M.gets_dug()
				log_message("Drilled through [target]")
				if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
					var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
					if(ore_box)
						for(var/obj/item/weapon/ore/ore in range(chassis,1))
							if(get_dir(chassis,ore)&chassis.dir)
								ore.Move(ore_box)
			else if(target.loc == C)
				if(istype(target,/mob/living))
					var/mob/living/M = target
					M.log_combat(chassis.occupant, "attacked via [chassis]'s [name]")

				log_message("Drilled through [target]")
				target.ex_act(2)
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/drill/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat))
			return 1
	return 0


/********Diamond drill********/
/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
	name = "diamond drill"
	desc = "This is an upgraded version of the drill that'll pierce the heavens! (Can be attached to: Combat and Engineering Exosuits)"
	icon_state = "mecha_diamond_drill"
	origin_tech = "materials=4;engineering=3"
	equip_cooldown = 20
	force = 15
	penetration = 6

/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill/action(atom/target)
	if(!action_checks(target)) return
	if(isobj(target))
		var/obj/target_obj = target
		if(target_obj.unacidable)	return
	set_ready_state(0)
	chassis.use_power(energy_drain)
	chassis.visible_message("<font color='red'><b>[chassis] starts to drill [target]</b></font>", "You hear the drill.")
	occupant_message("<font color='red'><b>You start to drill [target]</b></font>")
	var/T = chassis.loc
	var/C = target.loc	//why are these backwards? we may never know -Pete
	if(do_after_cooldown(target))
		if(T == chassis.loc && src == chassis.selected)
			if(istype(target, /turf/simulated/wall/r_wall))
				if(do_after_cooldown(target))//To slow down how fast mechs can drill through the station
					log_message("Drilled through [target]")
					target.ex_act(3)
			else if(istype(target, /turf/simulated/mineral))
				for(var/turf/simulated/mineral/M in range(chassis,1))
					if(get_dir(chassis,M)&chassis.dir)
						M.GetDrilled()
				log_message("Drilled through [target]")
				if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
					var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
					if(ore_box)
						for(var/obj/item/weapon/ore/ore in range(chassis,1))
							if(get_dir(chassis,ore)&chassis.dir)
								ore.Move(ore_box)
			else if(istype(target,/turf/simulated/floor/plating/airless/asteroid))
				for(var/turf/simulated/floor/plating/airless/asteroid/M in range(target,1))
					M.gets_dug()
				log_message("Drilled through [target]")
				if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
					var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
					if(ore_box)
						for(var/obj/item/weapon/ore/ore in range(target,1))
							ore.Move(ore_box)
			else if(target.loc == C)
				if(istype(target,/mob/living))
					var/mob/living/M = target
					M.log_combat(chassis.occupant, "attacked via [chassis]'s [name]")
				log_message("Drilled through [target]")
				target.ex_act(2)
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat))
			return 1
	return 0


/********Extinguisher********/
/obj/item/weapon/reagent_containers/spray/extinguisher/mecha
	volume = 1200

/obj/item/weapon/reagent_containers/spray/extinguisher/mecha/atom_init()
	. = ..()
	flags |= OPENCONTAINER

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher
	name = "extinguisher"
	desc = "Exosuit-mounted extinguisher (Can be attached to: Engineering exosuits)"
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0
	range = MELEE|RANGED

	var/obj/item/weapon/reagent_containers/spray/extinguisher/ext

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/atom_init()
	ext = new/obj/item/weapon/reagent_containers/spray/extinguisher/mecha(src)
	. = ..()

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/Destroy()
	QDEL_NULL(ext)
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/action(atom/target)
	if(!action_checks(target))
		return

	set_ready_state(0)

	if(do_after_cooldown(target) && chassis.occupant)
		ext.afterattack(target, chassis.occupant)
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/Topic(href, href_list)
	..()
	if (href_list["switch"])
		ext.safety = !ext.safety
		occupant_message("The [name] now [ext.safety ? "locked" : "ready"].")
		update_equip_info()

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/get_equip_info()
	return "[..()] \[[ext.reagents.total_volume]\]\[<a href='?src=\ref[src];switch=1'>[src.ext.safety ? "Safe" : "Ready"]</a>\]"

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/on_reagent_change()
	return

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/can_attach(obj/mecha/working/M)
	if(..())
		if(istype(M))
			return 1
	return 0


/********RCD********/
/obj/item/mecha_parts/mecha_equipment/tool/rcd
	name = "mounted RCD"
	desc = "An exosuit-mounted Rapid Construction Device. (Can be attached to: Any exosuit)"
	icon_state = "mecha_rcd"
	origin_tech = "materials=4;bluespace=3;magnets=4;powerstorage=4"
	equip_cooldown = 10
	energy_drain = 250
	range = MELEE|RANGED
	var/mode = 0 //0 - deconstruct, 1 - wall or floor, 2 - airlock.
	var/disabled = 0 //malf

/obj/item/mecha_parts/mecha_equipment/tool/rcd/atom_init()
	. = ..()
	mecha_rcd_list += src

/obj/item/mecha_parts/mecha_equipment/tool/rcd/Destroy()
	mecha_rcd_list -= src
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/rcd/action(atom/target)
	if(istype(target,/area/shuttle))//>implying these are ever made -Sieve
		disabled = 1
	else
		disabled = 0
	if(!istype(target, /turf) && !istype(target, /obj/machinery/door/airlock))
		target = get_turf(target)
	if(!action_checks(target) || disabled || get_dist(chassis, target)>3) return
	playsound(chassis, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
	//meh
	switch(mode)
		if(0)
			if (istype(target, /turf/simulated/wall))
				occupant_message("Deconstructing [target]...")
				set_ready_state(0)
				if(do_after_cooldown(target))
					if(disabled) return
					chassis.spark_system.start()
					target:ChangeTurf(/turf/simulated/floor/plating)
					playsound(target, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
					chassis.use_power(energy_drain)
			else if (istype(target, /turf/simulated/floor))
				occupant_message("Deconstructing [target]...")
				set_ready_state(0)
				if(do_after_cooldown(target))
					if(disabled) return
					chassis.spark_system.start()
					target:BreakToBase()
					playsound(target, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
					chassis.use_power(energy_drain)
			else if (istype(target, /obj/machinery/door/airlock))
				occupant_message("Deconstructing [target]...")
				set_ready_state(0)
				if(do_after_cooldown(target))
					if(disabled) return
					chassis.spark_system.start()
					qdel(target)
					playsound(target, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
					chassis.use_power(energy_drain)
		if(1)
			if(istype(target, /turf/space))
				occupant_message("Building Floor...")
				set_ready_state(0)
				if(do_after_cooldown(target))
					if(disabled) return
					target:ChangeTurf(/turf/simulated/floor/plating)
					playsound(target, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
					chassis.spark_system.start()
					chassis.use_power(energy_drain*2)
			else if(istype(target, /turf/simulated/floor))
				occupant_message("Building Wall...")
				set_ready_state(0)
				if(do_after_cooldown(target))
					if(disabled) return
					target:ChangeTurf(/turf/simulated/wall)
					playsound(target, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
					chassis.spark_system.start()
					chassis.use_power(energy_drain*2)
		if(2)
			if(istype(target, /turf/simulated/floor))
				occupant_message("Building Airlock...")
				set_ready_state(0)
				if(do_after_cooldown(target))
					if(disabled) return
					chassis.spark_system.start()
					var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock(target)
					T.autoclose = 1
					playsound(target, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
					playsound(target, 'sound/effects/sparks2.ogg', VOL_EFFECTS_MASTER)
					chassis.use_power(energy_drain*2)
	return


/obj/item/mecha_parts/mecha_equipment/tool/rcd/Topic(href,href_list)
	..()
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		switch(mode)
			if(0)
				occupant_message("Switched RCD to Deconstruct.")
			if(1)
				occupant_message("Switched RCD to Construct.")
			if(2)
				occupant_message("Switched RCD to Construct Airlock.")
	return

/obj/item/mecha_parts/mecha_equipment/tool/rcd/get_equip_info()
	return "[..()] \[<a href='?src=\ref[src];mode=0'>D</a>|<a href='?src=\ref[src];mode=1'>C</a>|<a href='?src=\ref[src];mode=2'>A</a>\]"


/********Teleporter********/
/obj/item/mecha_parts/mecha_equipment/teleporter
	name = "teleporter"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	icon_state = "mecha_teleport"
	origin_tech = "bluespace=10"
	equip_cooldown = 150
	energy_drain = 1000
	range = RANGED

/obj/item/mecha_parts/mecha_equipment/teleporter/action(atom/target)
	if(!action_checks(target) || is_centcom_level(loc.z))
		return
	var/turf/T = get_turf(target)
	if(T)
		set_ready_state(0)
		chassis.use_power(energy_drain)
		do_teleport(chassis, T, 4)
		do_after_cooldown()
	return


/********Teleporter********/
/obj/item/mecha_parts/mecha_equipment/wormhole_generator
	name = "wormhole generator"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	icon_state = "mecha_wholegen"
	origin_tech = "bluespace=3"
	equip_cooldown = 50
	energy_drain = 300
	range = RANGED

/obj/item/mecha_parts/mecha_equipment/wormhole_generator/action(atom/target)
	if(!action_checks(target) || is_centcom_level(loc.z))
		return
	var/list/theareas = list()
	for(var/area/AR in orange(100, chassis))
		if(AR in theareas) continue
		theareas += AR
	if(!theareas.len)
		return
	var/area/thearea = pick(theareas)
	var/list/L = list()
	var/turf/pos = get_turf(src)
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density && pos.z == T.z)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T
	if(!L.len)
		return
	var/turf/target_turf = pick(L)
	if(!target_turf)
		return
	chassis.use_power(energy_drain)
	set_ready_state(0)
	var/obj/effect/portal/P = new /obj/effect/portal(get_turf(target))
	P.target = target_turf
	P.creator = null
	P.icon = 'icons/obj/objects.dmi'
	P.failchance = 0
	P.icon_state = "anom"
	P.name = "wormhole"
	do_after_cooldown()
	src = null
	QDEL_IN(P, rand(150,300))
	return


/********Gravcatapult********/
/obj/item/mecha_parts/mecha_equipment/gravcatapult
	name = "gravitational catapult"
	desc = "An exosuit mounted Gravitational Catapult."
	icon_state = "mecha_teleport"
	origin_tech = "bluespace=2;magnets=3"
	equip_cooldown = 10
	energy_drain = 100
	range = MELEE|RANGED
	var/atom/movable/locked
	var/mode = 1 //1 - gravsling 2 - gravpush

	var/last_fired = 0  //Concept stolen from guns.
	var/fire_delay = 10 //Used to prevent spam-brute against humans.

/obj/item/mecha_parts/mecha_equipment/gravcatapult/action(atom/movable/target)

	if(world.time >= last_fired + fire_delay)
		last_fired = world.time
	else
		if (world.time % 3)
			occupant_message("<span class='warning'>[src] is not ready to fire again!</span>")
		return 0

	switch(mode)
		if(1)
			if(!action_checks(target) && !locked) return
			if(!locked)
				if(!istype(target) || target.anchored)
					occupant_message("Unable to lock on [target]")
					return
				locked = target
				occupant_message("Locked on [target]")
				send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
				return
			else if(target!=locked)
				if(locked in view(chassis))
					locked.throw_at(target, 14, 1.5, chassis)
					locked = null
					send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
					set_ready_state(0)
					chassis.use_power(energy_drain)
					do_after_cooldown()
				else
					locked = null
					occupant_message("Lock on [locked] disengaged.")
					send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		if(2)
			if(!action_checks(target)) return
			var/list/atoms = list()
			if(isturf(target))
				atoms = range(target,3)
			else
				atoms = orange(target,3)
			for(var/atom/movable/A in atoms)
				if(A.anchored) continue
				spawn(0)
					var/iter = 5-get_dist(A,target)
					for(var/i=0 to iter)
						step_away(A,target)
						sleep(2)
			set_ready_state(0)
			chassis.use_power(energy_drain)
			do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/gravcatapult/get_equip_info()
	return "[..()] [mode==1?"([locked||"Nothing"])":null] \[<a href='?src=\ref[src];mode=1'>S</a>|<a href='?src=\ref[src];mode=2'>P</a>\]"

/obj/item/mecha_parts/mecha_equipment/gravcatapult/Topic(href, href_list)
	..()
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
	return


/********Armor booster module (Close Combat Weaponry)********/
/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster //what is that noise? A BAWWW from TK mutants.
	name = "closed armor booster module"
	desc = "Boosts exosuit armor against armed melee attacks. Requires energy to operate."
	icon_state = "mecha_abooster_ccw"
	origin_tech = "materials=3"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/can_attach(obj/mecha/M)
	if(..())
		if(!istype(M, /obj/mecha/combat/honker))
			if(!M.proc_res["dynattackby"])
				return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/attach(obj/mecha/M)
	..()
	chassis.proc_res["dynattackby"] = src
	return

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/detach()
	chassis.proc_res["dynattackby"] = null
	..()
	return

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/get_equip_info()
	if(!chassis)	return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name]"

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/proc/dynattackby(obj/item/weapon/W, mob/user)
	if(!action_checks(user))
		return chassis.dynattackby(W,user)
	chassis.log_message("Attacked by [W]. Attacker - [user]")
	if(prob(chassis.deflect_chance*deflect_coeff))
		to_chat(user, "<span class='warning'>The [W] bounces off [chassis] armor.</span>")
		chassis.log_append_to_last("Armor saved.")
	else
		chassis.occupant_message("<font color='red'><b>[user] hits [chassis] with [W].</b></font>")
		user.visible_message("<font color='red'><b>[user] hits [chassis] with [W].</b></font>", "<font color='red'><b>You hit [src] with [W].</b></font>")
		chassis.take_damage(round(W.force*damage_coeff),W.damtype)
		chassis.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	set_ready_state(0)
	chassis.use_power(energy_drain)
	do_after_cooldown()
	return


/********Armor booster module (Ranged Weaponry)********/
/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	name = "ranged armor booster module"
	desc = "Boosts exosuit armor against ranged attacks. Completely blocks taser shots. Requires energy to operate."
	icon_state = "mecha_abooster_proj"
	origin_tech = "materials=4"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/can_attach(obj/mecha/M)
	if(..())
		if(!istype(M, /obj/mecha/combat/honker))
			if(!M.proc_res["dynbulletdamage"] && !M.proc_res["dynhitby"])
				return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/attach(obj/mecha/M)
	..()
	chassis.proc_res["dynbulletdamage"] = src
	chassis.proc_res["dynhitby"] = src
	return

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/detach()
	chassis.proc_res["dynbulletdamage"] = null
	chassis.proc_res["dynhitby"] = null
	..()
	return

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/get_equip_info()
	if(!chassis) return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name]"

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/proc/dynbulletdamage(obj/item/projectile/Proj)
	if(!action_checks(src))
		return chassis.dynbulletdamage(Proj)
	if(prob(chassis.deflect_chance*deflect_coeff))
		chassis.occupant_message("<span class='notice'>The armor deflects incoming projectile.</span>")
		chassis.visible_message("The [chassis.name] armor deflects the projectile")
		chassis.log_append_to_last("Armor saved.")
	else
		chassis.take_damage(round(Proj.damage*src.damage_coeff),Proj.flag)
		chassis.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		Proj.on_hit(chassis)
	set_ready_state(0)
	chassis.use_power(energy_drain)
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/proc/dynhitby(atom/movable/AM, datum/thrownthing/throwingdatum)
	if(!action_checks(AM))
		return chassis.dynhitby(AM, throwingdatum)
	if(prob(chassis.deflect_chance*deflect_coeff) || isliving(AM) || istype(AM, /obj/item/mecha_parts/mecha_tracking))
		chassis.occupant_message("<span class='notice'>The [AM] bounces off the armor.</span>")
		chassis.visible_message("The [AM] bounces off the [chassis] armor")
		chassis.log_append_to_last("Armor saved.")
		if(isliving(AM))
			var/mob/living/M = AM
			M.take_bodypart_damage(10)
	else if(isobj(AM))
		var/obj/O = AM
		if(O.throwforce)
			chassis.take_damage(round(O.throwforce*damage_coeff))
			chassis.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	set_ready_state(0)
	chassis.use_power(energy_drain)
	do_after_cooldown()
	return


/********Repair droid********/
/obj/item/mecha_parts/mecha_equipment/repair_droid
	name = "repair droid"
	desc = "Automated repair droid. Scans exosuit for damage and repairs it. Can fix almost all types of external or internal damage."
	icon_state = "repair_droid"
	origin_tech = "magnets=3;programming=3"
	equip_cooldown = 20
	energy_drain = 100
	range = 0
	var/health_boost = 2
	var/datum/global_iterator/pr_repair_droid
	var/icon/droid_overlay
	var/list/repairable_damage = list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH)

/obj/item/mecha_parts/mecha_equipment/repair_droid/atom_init()
	. = ..()
	pr_repair_droid = new /datum/global_iterator/mecha_repair_droid(list(src),0)
	pr_repair_droid.set_delay(equip_cooldown)

/obj/item/mecha_parts/mecha_equipment/repair_droid/attach(obj/mecha/M)
	..()
	droid_overlay = new(src.icon, icon_state = "repair_droid")
	M.add_overlay(droid_overlay)
	return

/obj/item/mecha_parts/mecha_equipment/repair_droid/Destroy()
	if(chassis)
		chassis.cut_overlay(droid_overlay)
	return ..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/detach()
	chassis.cut_overlay(droid_overlay)
	pr_repair_droid.stop()
	..()
	return

/obj/item/mecha_parts/mecha_equipment/repair_droid/get_equip_info()
	if(!chassis) return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name] - <a href='?src=\ref[src];toggle_repairs=1'>[pr_repair_droid.active()?"Dea":"A"]ctivate</a>"

/obj/item/mecha_parts/mecha_equipment/repair_droid/Topic(href, href_list)
	..()
	if(href_list["toggle_repairs"])
		chassis.cut_overlay(droid_overlay)
		if(pr_repair_droid.toggle())
			droid_overlay = new(src.icon, icon_state = "repair_droid_a")
			log_message("Activated.")
		else
			droid_overlay = new(src.icon, icon_state = "repair_droid")
			log_message("Deactivated.")
			set_ready_state(1)
		chassis.add_overlay(droid_overlay)
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
	return

/datum/global_iterator/mecha_repair_droid/process(var/obj/item/mecha_parts/mecha_equipment/repair_droid/RD as obj)
	if(!RD.chassis)
		stop()
		RD.set_ready_state(1)
		return
	var/health_boost = RD.health_boost
	var/repaired = 0
	if(RD.chassis.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
		health_boost *= -2
	else if(RD.chassis.hasInternalDamage() && prob(15))
		for(var/int_dam_flag in RD.repairable_damage)
			if(RD.chassis.hasInternalDamage(int_dam_flag))
				RD.chassis.clearInternalDamage(int_dam_flag)
				repaired = 1
				break
	if(health_boost<0 || RD.chassis.health < initial(RD.chassis.health))
		RD.chassis.health += min(health_boost, initial(RD.chassis.health)-RD.chassis.health)
		repaired = 1
	if(repaired)
		if(RD.chassis.use_power(RD.energy_drain))
			RD.set_ready_state(0)
		else
			stop()
			RD.set_ready_state(1)
			return
	else
		RD.set_ready_state(1)
	return


/********Energy relay********/
/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	name = "energy relay"
	desc = "Wirelessly drains energy from any available power channel in area. The performance index is quite low."
	icon_state = "tesla"
	origin_tech = "magnets=4"
	equip_cooldown = 10
	energy_drain = 0
	range = 0
	var/datum/global_iterator/pr_energy_relay
	var/coeff = 100
	var/list/use_channels = list(STATIC_EQUIP,STATIC_ENVIRON,STATIC_LIGHT)

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/atom_init()
	. = ..()
	pr_energy_relay = new /datum/global_iterator/mecha_energy_relay(list(src),0)
	pr_energy_relay.set_delay(equip_cooldown)

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/detach()
	pr_energy_relay.stop()
//	chassis.proc_res["dynusepower"] = null
	chassis.proc_res["dyngetcharge"] = null
	..()
	return

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/attach(obj/mecha/M)
	..()
	chassis.proc_res["dyngetcharge"] = src
//	chassis.proc_res["dynusepower"] = src
	return

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/can_attach(obj/mecha/M)
	if(..())
		if(!M.proc_res["dyngetcharge"])// && !M.proc_res["dynusepower"])
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/dyngetcharge()
	if(equip_ready) //disabled
		return chassis.dyngetcharge()
	var/area/A = get_area(chassis)
	var/pow_chan = get_power_channel(A)
	var/charge = 0
	if(pow_chan)
		charge = 1000 //making magic
	else
		return chassis.dyngetcharge()
	return charge

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/get_power_channel(area/A)
	var/pow_chan
	if(A)
		for(var/c in use_channels)
			if(A.powered(c))
				pow_chan = c
				break
	return pow_chan

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/Topic(href, href_list)
	..()
	if(href_list["toggle_relay"])
		if(pr_energy_relay.toggle())
			set_ready_state(0)
			log_message("Activated.")
		else
			set_ready_state(1)
			log_message("Deactivated.")
	return

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/get_equip_info()
	if(!chassis) return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name] - <a href='?src=\ref[src];toggle_relay=1'>[pr_energy_relay.active()?"Dea":"A"]ctivate</a>"

/datum/global_iterator/mecha_energy_relay/process(var/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/ER)
	if(!ER.chassis || ER.chassis.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
		stop()
		ER.set_ready_state(1)
		return
	var/cur_charge = ER.chassis.get_charge()
	if(isnull(cur_charge) || !ER.chassis.cell)
		stop()
		ER.set_ready_state(1)
		ER.occupant_message("No powercell detected.")
		return
	if(cur_charge<ER.chassis.cell.maxcharge)
		var/area/A = get_area(ER.chassis)
		if(A)
			var/pow_chan
			for(var/c in list(STATIC_EQUIP,STATIC_ENVIRON,STATIC_LIGHT))
				if(A.powered(c))
					pow_chan = c
					break
			if(pow_chan)
				var/delta = min(12, ER.chassis.cell.maxcharge-cur_charge)
				ER.chassis.give_power(delta)
				A.use_power(delta*ER.coeff, pow_chan)
	return


/********Phoron generator********/
/obj/item/mecha_parts/mecha_equipment/generator
	name = "phoron generator"
	desc = "Generates power using solid phoron as fuel. Pollutes the environment."
	icon_state = "tesla"
	origin_tech = "phorontech=2;powerstorage=2;engineering=1"
	equip_cooldown = 10
	energy_drain = 0
	range = MELEE
	var/datum/global_iterator/pr_mech_generator
	var/coeff = 100
	var/obj/item/stack/sheet/fuel
	var/max_fuel = 150000
	var/fuel_per_cycle_idle = 100
	var/fuel_per_cycle_active = 500
	var/power_per_cycle = 20
	reliability = 1000

/obj/item/mecha_parts/mecha_equipment/generator/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/mecha_parts/mecha_equipment/generator/atom_init_late()
	fuel = new /obj/item/stack/sheet/mineral/phoron(src)
	fuel.amount = 0
	pr_mech_generator = new /datum/global_iterator/mecha_generator(list(src),0)
	pr_mech_generator.set_delay(equip_cooldown)

/obj/item/mecha_parts/mecha_equipment/generator/detach()
	pr_mech_generator.stop()
	..()
	return


/obj/item/mecha_parts/mecha_equipment/generator/Topic(href, href_list)
	..()
	if(href_list["toggle"])
		if(pr_mech_generator.toggle())
			set_ready_state(0)
			log_message("Activated.")
		else
			set_ready_state(1)
			log_message("Deactivated.")
	return

/obj/item/mecha_parts/mecha_equipment/generator/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[[fuel]: [round(fuel.amount*fuel.perunit,0.1)] cm<sup>3</sup>\] - <a href='?src=\ref[src];toggle=1'>[pr_mech_generator.active()?"Dea":"A"]ctivate</a>"
	return

/obj/item/mecha_parts/mecha_equipment/generator/action(target)
	if(chassis)
		var/result = load_fuel(target)
		var/message
		if(isnull(result))
			message = "<font color='red'>[fuel] traces in target minimal. [target] cannot be used as fuel.</font>"
		else if(!result)
			message = "Unit is full."
		else
			message = "[result] unit\s of [fuel] successfully loaded."
			send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		occupant_message(message)
	return

/obj/item/mecha_parts/mecha_equipment/generator/proc/load_fuel(obj/item/stack/sheet/P)
	if(P.type == fuel.type && P.get_amount())
		var/to_load = max(max_fuel - fuel.amount*fuel.perunit,0)
		if(to_load)
			var/units = min(max(round(to_load / P.perunit),1),P.get_amount())
			if(units)
				fuel.amount += units
				P.use(units)
				return units
		else
			return 0
	return

/obj/item/mecha_parts/mecha_equipment/generator/attackby(obj/item/I, mob/user, params)
	var/result = load_fuel(I)
	if(isnull(result))
		user.visible_message("[user] tries to shove [I] into [src]. What a dumb-ass.","<font color='red'>[fuel] traces minimal. [I] cannot be used as fuel.</font>")
	else if(!result)
		to_chat(user, "Unit is full.")
	else
		user.visible_message("[user] loads [src] with [fuel].","[result] unit\s of [fuel] successfully loaded.")

/obj/item/mecha_parts/mecha_equipment/generator/critfail()
	..()
	var/turf/simulated/T = get_turf(src)
	if(!T)
		return
	var/datum/gas_mixture/GM = new
	if(prob(10))
		GM.gas["phoron"] += 100
		GM.temperature = 1500+T0C //should be enough to start a fire
		T.visible_message("The [src] suddenly disgorges a cloud of heated phoron.")
		qdel(src)
	else
		GM.gas["phoron"] += 5
		GM.temperature = istype(T) ? T.air.temperature : T20C
		T.visible_message("The [src] suddenly disgorges a cloud of phoron.")
	T.assume_air(GM)
	return

/datum/global_iterator/mecha_generator/process(var/obj/item/mecha_parts/mecha_equipment/generator/EG)
	if(!EG.chassis)
		stop()
		EG.set_ready_state(1)
		return 0
	if(EG.fuel.amount<=0)
		stop()
		EG.log_message("Deactivated - no fuel.")
		EG.set_ready_state(1)
		return 0
	if(anyprob(EG.reliability))
		EG.critfail()
		stop()
		return 0
	var/cur_charge = EG.chassis.get_charge()
	if(isnull(cur_charge))
		EG.set_ready_state(1)
		EG.occupant_message("No powercell detected.")
		EG.log_message("Deactivated.")
		stop()
		return 0
	var/use_fuel = EG.fuel_per_cycle_idle
	if(cur_charge<EG.chassis.cell.maxcharge)
		use_fuel = EG.fuel_per_cycle_active
		EG.chassis.give_power(EG.power_per_cycle)
	EG.fuel.amount -= min(use_fuel/EG.fuel.perunit,EG.fuel.amount)
	EG.update_equip_info()
	return 1


/********ExoNuclear reactor********/
/obj/item/mecha_parts/mecha_equipment/generator/nuclear
	name = "ExoNuclear reactor"
	desc = "Generates power using uranium. Pollutes the environment."
	icon_state = "tesla"
	origin_tech = "powerstorage=3;engineering=3"
	max_fuel = 50000
	fuel_per_cycle_idle = 10
	fuel_per_cycle_active = 30
	power_per_cycle = 50
	var/rad_per_cycle = 0.3
	reliability = 1000

/obj/item/mecha_parts/mecha_equipment/generator/nuclear/atom_init_late()
	fuel = new /obj/item/stack/sheet/mineral/uranium(src)
	fuel.amount = 0
	pr_mech_generator = new /datum/global_iterator/mecha_generator/nuclear(list(src),0)
	pr_mech_generator.set_delay(equip_cooldown)

/obj/item/mecha_parts/mecha_equipment/generator/nuclear/critfail()
	return

/datum/global_iterator/mecha_generator/nuclear

/datum/global_iterator/mecha_generator/nuclear/process(var/obj/item/mecha_parts/mecha_equipment/generator/nuclear/EG)
	if(..())
		for(var/mob/living/carbon/M in view(EG.chassis))
			M.apply_effect((EG.rad_per_cycle*3),IRRADIATE,0)
	return 1


/********KILL CLAMP********/
//This is pretty much just for the death-ripley so that it is harmless
/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp
	name = "KILL CLAMP"
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 0
	var/dam_force = 0
	var/obj/mecha/working/ripley/cargo_holder

/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp/can_attach(obj/mecha/working/ripley/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp/attach(obj/mecha/M)
	..()
	cargo_holder = M
	return

/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp/action(atom/target)
	if(!action_checks(target)) return
	if(!cargo_holder) return
	if(istype(target,/obj))
		var/obj/O = target
		if(!O.anchored)
			if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
				chassis.occupant_message("You lift [target] and start to load it into cargo compartment.")
				chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
				set_ready_state(0)
				chassis.use_power(energy_drain)
				O.anchored = 1
				var/T = chassis.loc
				if(do_after_cooldown(target))
					if(T == chassis.loc && src == chassis.selected)
						cargo_holder.cargo += O
						O.loc = chassis
						O.anchored = 0
						chassis.occupant_message("<font color='blue'>[target] succesfully loaded.</font>")
						chassis.log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
					else
						chassis.occupant_message("<font color='red'>You must hold still while handling objects.</font>")
						O.anchored = initial(O.anchored)
			else
				chassis.occupant_message("<font color='red'>Not enough room in cargo compartment.</font>")
		else
			chassis.occupant_message("<font color='red'>[target] is firmly secured.</font>")

	else if(istype(target,/mob/living))
		var/mob/living/M = target
		if(M.stat>1) return
		if(chassis.occupant.a_intent == INTENT_HARM)
			chassis.occupant_message("<span class='warning'>You obliterate [target] with [src.name], leaving blood and guts everywhere.</span>")
			chassis.visible_message("<span class='warning'>[chassis] destroys [target] in an unholy fury.</span>")
		else if(chassis.occupant.a_intent == INTENT_PUSH)
			chassis.occupant_message("<span class='warning'>You tear [target]'s limbs off with [src.name].</span>")
			chassis.visible_message("<span class='warning'>[chassis] rips [target]'s arms off.</span>")
		else
			step_away(M,chassis)
			chassis.occupant_message("You smash into [target], sending them flying.")
			chassis.visible_message("[chassis] tosses [target] like a piece of paper.")
		set_ready_state(0)
		chassis.use_power(energy_drain)
		do_after_cooldown()
	return 1


/********Mecha customisation kit********/
/obj/item/weapon/paintkit //Please don't use this for anything, it's a base type for custom mech paintjobs.
	name = "mecha customisation kit"
	desc = "A generic kit containing all the needed tools and parts to turn a mech into another mech."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "royce_kit"

	var/new_name = "mech"    //What is the variant called?
	var/new_desc = "A mech." //How is the new mech described?
	var/new_icon = "ripley"  //What base icon will the new mech use?
	var/removable = null     //Can the kit be removed?
	var/list/allowed_types = list() //Types of mech that the kit will work on.


/********Mecha Drop System********/
/obj/item/mecha_parts/mecha_equipment/Drop_system
	name = "Drop System"
	desc = "Allow to drop mech from skies."
	icon_state = "tesla"
	origin_tech = "magnets=4"
	equip_cooldown = 10
	energy_drain = 2500
	range = 0
	var/uses = 1
	var/aiming = FALSE
	var/static/datum/droppod_allowed/allowed_areas

/obj/item/mecha_parts/mecha_equipment/Drop_system/atom_init()
	. = ..()
	if(!allowed_areas)
		allowed_areas = new

/obj/item/mecha_parts/mecha_equipment/Drop_system/Topic(href, href_list)
	..()
	if(href_list["start_drop"])
		if(!aiming && uses)
			Select()
			log_message("Select Drop Point.")
		else
			chassis.occupant_message("<span class='notice'>You cannot drop for now!</span>")
	return

/obj/item/mecha_parts/mecha_equipment/Drop_system/get_equip_info()
	if(!chassis)
		return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[name] - <a href='?src=\ref[src];start_drop=1'>Start Drop</a>"

/obj/item/mecha_parts/mecha_equipment/Drop_system/proc/Select() // little copypaste from droppod code
	if(aiming)
		return
	aiming = TRUE
	var/A
	A = input("Select Area for Droping Pod", "Select", A) in allowed_areas.areas
	var/area/thearea = allowed_areas.areas[A]
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density && !istype(T, /turf/space) && !T.obscured)
			L+=T
	if(isemptylist(L))
		chassis.occupant_message("<span class='notice'>Automatic Aim System cannot find an appropriate target!</span>")
		aiming = FALSE
		return
	if(war_device_activated)
		if(world.time < SYNDICATE_CHALLENGE_TIMER)
			chassis.occupant_message("<span class='warning'>You've issued a combat challenge to the station! \
			You've got to give them at least [round(((SYNDICATE_CHALLENGE_TIMER - world.time) / 10) / 60)] \
			time more minutes to allow them to prepare.</span>")
			aiming = FALSE
			return
	else
		war_device_activation_forbidden = TRUE
	chassis.occupant_message("<span class='notice'>You succesfully selected target!</span>")
	chassis.loc = pick(L)
	uses--
	chassis.freeze_movement = TRUE // to prevent moving in drop phase.
	chassis.density = FALSE
	chassis.opacity = FALSE
	var/initial_x = chassis.pixel_x
	var/initial_y = chassis.pixel_y
	playsound(src, 'sound/effects/drop_start.ogg', VOL_EFFECTS_MASTER)
	chassis.pixel_x = rand(-150, 150)
	chassis.pixel_y = 500
	animate(chassis, pixel_y = initial_y, pixel_x = initial_x, time = 20)
	addtimer(CALLBACK(src, .proc/perform_drop), 20)


/obj/item/mecha_parts/mecha_equipment/Drop_system/proc/perform_drop()
	for(var/atom/movable/T in loc)
		if(T != src && T != chassis.occupant && !(istype(T, /obj/structure/window) || istype(T, /obj/machinery/door/airlock) || istype(T, /obj/machinery/door/poddoor)))
			if(!(T in chassis.contents)) T.ex_act(1)
	for(var/mob/living/M in oviewers(6, src))
		shake_camera(M, 2, 2)
	for(var/turf/simulated/floor/T in RANGE_TURFS(1, chassis))
		T.break_tile_to_plating()
	playsound(src, 'sound/effects/drop_land.ogg', VOL_EFFECTS_MASTER)
	chassis.freeze_movement = FALSE
	chassis.density = TRUE
	chassis.opacity = TRUE
	aiming = FALSE
