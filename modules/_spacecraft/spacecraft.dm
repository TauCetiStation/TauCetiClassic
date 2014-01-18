/obj/spacecraft
	name = "Spacecraft"
	desc = ""
	icon = 'tauceti/modules/_spacecraft/spacecraft.dmi'
	icon_state = "civilian"
	density = 1
	opacity = 1
	unacidable = 1
	anchored = 1
	bounds = "64,64"
	layer = MOB_LAYER  //Нужно посмотреть
	var/mob/living/carbon/pilot = null //Оператор аппарата

	//Движение
	var/can_turn = 1 //может ли повернуть
	var/can_move = 0
	var/speed = 0 //Текущая скорость
	var/last_relay = 0
	var/turn_energy_drain = 5

	var/obj/item/weapon/cell/cell //энергоячейка
	var/online = 0 //есть питание/нет питания
	//Двигло
	var/obj/item/spacecraft_parts/engine/engine = null
	var/engine_on = 0
	var/cooling_rate = 3 //степень охлаждения
	//итераторы
	var/datum/global_iterator/pr_inertial_movement //итератор инерционного движения в космосе
	var/datum/global_iterator/pr_speed_increment //увеличение скорости
	var/datum/global_iterator/pr_cooling //охлаждение подсистем
	var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature
	var/datum/global_iterator/pr_give_air //moves air from tank to cabin
	var/datum/global_iterator/pr_internal_damage //processes internal damage


	//Атмос
	var/use_internal_tank = 0
	var/internal_tank_valve = ONE_ATMOSPHERE
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/gas_mixture/cabin_air
	//эффекты
	var/datum/effect/effect/system/jet_trail_follow/jet_trail

	var/class = "civilian"

	New()
		..()
		add_iterators()
		engine = new /obj/item/spacecraft_parts/engine(src)
		add_cell()
		add_airtank()
		add_cabin()
		pr_cooling.stop()
		pr_int_temp_processor.stop()
		pr_give_air.stop()
		src.jet_trail = new /datum/effect/effect/system/jet_trail_follow()
		src.jet_trail.set_up(src)
		src.verbs -= /obj/spacecraft/verb/toggle_engine
		return

	Del()
		src.go_out()
		..()
		return

//////HELPERS///////
/obj/spacecraft/proc/removeVerb(verb_path)
	verbs -= verb_path

/obj/spacecraft/proc/addVerb(verb_path)
	verbs += verb_path

/obj/spacecraft/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)  	//Внутренний бак с воздухом
	return internal_tank

/obj/spacecraft/proc/add_cabin()															//Кокпит,а точнее, её атмосфера
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.oxygen = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.nitrogen = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	return cabin_air

/obj/spacecraft/proc/add_cell(var/obj/item/weapon/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.charge = 15000
	cell.maxcharge = 15000


/obj/spacecraft/proc/add_iterators()														//Итераторы
	pr_int_temp_processor = new /datum/global_iterator/spacecraft_preserve_temp(list(src))
	pr_give_air = new /datum/global_iterator/spacecraft_tank_give_air(list(src))
//	pod_pr_internal_damage = new /datum/global_iterator/pod_internal_damage(list(src),0)
	pr_inertial_movement = new /datum/global_iterator/spacecraft_inertial_movement(list(src),0)
	pr_speed_increment = new /datum/global_iterator/spacecraft_speed_increment(list(src),0)
	pr_cooling = new /datum/global_iterator/spacecraft_cooling(list(src))

/obj/spacecraft/proc/enter_after(delay as num, var/mob/user as mob, var/numticks = 5)
	var/delayfraction = delay/numticks
	var/turf/T = user.loc
	for(var/i = 0, i<numticks, i++)
		sleep(delayfraction)
		if(!src || !user || !user.canmove || !(user.loc == T))
			return 0
	return 1

/obj/spacecraft/proc/inspace()
	if(istype(src.loc, /turf/space))
		return 1
	return 0

//////VERBS////////
/obj/spacecraft/verb/move_inside()
	set category = "Object"
	set name = "Enter spacecraft's cockpit"
	set src in oview(1)
	if (usr.stat || !ishuman(usr))
		return
//	src.log_message("[usr] tries to move in.")
	if (src.pilot)
		usr << "\blue <B>The [src.name] is already occupied!</B>"
	//	src.log_append_to_last("Permission denied.")
		return

	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			usr << "You're too busy getting your life sucked out of you."
			return
	usr << "You start climbing into [src.name]"

	visible_message("\blue [usr] starts to climb into [src.name]")

	if(enter_after(40,usr))
		if(!src.pilot)
			moved_inside(usr)
		else if(src.pilot != usr)
			usr << "[src.pilot] was faster. Try better next time, loser."
	else
		usr << "You stop entering the spacecraft."
	return

/obj/spacecraft/proc/moved_inside(var/mob/living/carbon/human/H as mob)
	if(H && H.client && H in range(1))
		H.reset_view(src)
		H.stop_pulling()
		H.forceMove(src)
		src.pilot = H
		src.add_fingerprint(H)
		src.forceMove(src.loc)
//		src.log_append_to_last("[H] moved in as pilot.")

	//	playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
	//	if(!hasInternalDamage())
	//		src.occupant << sound('sound/mecha/nominal.ogg',volume=50)
		return 1
	else
		return 0

/obj/spacecraft/verb/eject()
	set name = "Eject"
	set category = "Spacecraft Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr != src.pilot)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/spacecraft/proc/go_out()
	if(!src.pilot) return
	var/atom/movable/mob_container
	mob_container = src.pilot
	if(mob_container.forceMove(src.loc))//ejecting mob container
//		src.log_message("[mob_container] moved out.")
		pilot.reset_view()
		src.pilot << browse(null, "window=spacecraft")
		src.pilot = null
	return

/obj/spacecraft/verb/Debug()
	set name = "Debug"
	set category = "Spacecraft Interface"
	set src = usr.loc
	set popup_menu = 0
	var/tank_pressure = internal_tank ? round(internal_tank.return_pressure(),0.01) : "None"
	if(usr!=pilot)	return
	usr << "[get_charge()], , [src.loc], [get_fuel()], [get_oxidiser()], [engine.cur_heat_capacity], [tank_pressure], Current speed: [get_current_speed()], Desired speed: [get_desired_speed()]"

/obj/spacecraft/verb/toggle_engine()
	set name = "Toggle spacecraft's main engine."
	set category = "Spacecraft Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.pilot)
		return
	if(!src.engine)
		return
	if(src.engine.damaged)
		src.occupant_message("<font color='red'>The [src.engine] is damaged!</font>")
		return
	if(online)
		engine_on = !engine_on
		if(engine_on)
			engine_start()
		else
			engine_stop()
	else
		src.occupant_message("<font color='red'>No power!</font>")

/obj/spacecraft/verb/toggle_power()
	set name = "Toggle spacecraft's power system."
	set category = "Spacecraft Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.pilot)
		return
	online = !online
	if(online)
		use_internal_tank = 1
	//	if(!hasInternalDamage(POD_INT_TEMP_CONTROL))
		src.pr_int_temp_processor.start(list(src))
		src.pr_give_air.start(list(src))
		src.pr_cooling.start()
		src.occupant_message("<font color='red'>All systems engaged</font>")
		src.pilot << sound('sound/mecha/nominal.ogg',volume=50)
		src.verbs += /obj/spacecraft/verb/toggle_engine
	else
		use_internal_tank = 0
		engine_on = 0
//		can_move = 1
		engine_stop()
		src.pr_int_temp_processor.stop()
		src.pr_cooling.stop()
		src.pr_give_air.stop()
		src.occupant_message("<font color='red'>All systems offline</font>")
		src.verbs -= /obj/spacecraft/verb/toggle_engine

/////MOVEMENT///////
/obj/spacecraft/relaymove(mob/user,direction)
	spawn()
		if(user != src.pilot) //While not "realistic", this piece is player friendly.
			user.forceMove(get_turf(src))
			user << "You climb out from [src]"
			return 0
//		if(connected_port)
//			usr << "Unable to move while connected to the port"
		//	if(world.time - last_message > 20)
		//		src.occupant_message("Unable to move while connected to the air system port")
		//		last_message = world.time
//			return 0
	/*	if(state)
			occupant_message("<font color='red'>Maintenance protocols in effect</font>")
			return */

		if(world.time-last_relay<4)
			return 0
		if(!can_move || engine.damaged || !online)
			return 0

		last_relay = world.time
		var/speed_change = 0
		pr_inertial_movement:min_delay = src.engine.max_speed
		pr_inertial_movement:max_delay = src.engine.min_speed
		if(direction & NORTH)
			if(!engine.oxidiser_tank)
				if(!has_fuel(engine.fuel_drain) || !has_charge(engine.power_drain))
					return
				else
					use_fuel(engine.fuel_drain)
					use_power(engine.power_drain)

			else
				if(!has_fuel(engine.fuel_drain) || !has_oxidiser(engine.oxidiser_drain) || !has_charge(engine.power_drain))
					return
				else
					use_fuel(engine.fuel_drain)
					use_oxidiser(engine.oxidiser_drain)
					use_power(engine.power_drain)
					engine.cur_heat_capacity += engine.heating
					pr_inertial_movement:desired_delay = between(pr_inertial_movement:min_delay, pr_inertial_movement:desired_delay-1, pr_inertial_movement:max_delay)
					speed_change = 1
		else if (direction & SOUTH)
			if(!has_charge(engine.power_drain))
				return
			else
				use_power(engine.power_drain)
				engine.cur_heat_capacity += (engine.heating/2)
				pr_inertial_movement:desired_delay = between(pr_inertial_movement:min_delay, pr_inertial_movement:desired_delay+1, pr_inertial_movement:max_delay)
				speed_change = 1
		else if (src.can_turn && direction & 4)
			if(!has_charge(turn_energy_drain))
				return
			else
				use_power(turn_energy_drain)
				use_fuel(engine.fuel_drain/3)
				use_oxidiser(engine.oxidiser_drain/3)
				pr_inertial_movement:desired_delay += 2
				pr_inertial_movement:cur_delay += 2
				src.dir = turn(src.dir, -90.0)
		else if (src.can_turn && direction & 8)
			if(!has_charge(turn_energy_drain))
				return
			else
				use_fuel(engine.fuel_drain/3)
				use_oxidiser(engine.oxidiser_drain/3)
				use_power(turn_energy_drain)
				pr_inertial_movement:desired_delay += 2
				pr_inertial_movement:cur_delay += 2
				src.dir = turn(src.dir, 90)
		if(speed_change)
		//	src.pr_speed_increment.start()
			speed_increment(src)
			src.pr_inertial_movement.start()
			src.engine_check()
	return


/obj/spacecraft/proc/get_desired_speed()
	return (pr_inertial_movement:max_delay-pr_inertial_movement:desired_delay)/(pr_inertial_movement:max_delay-pr_inertial_movement:min_delay)*100

/obj/spacecraft/proc/get_current_speed()
	return (pr_inertial_movement:max_delay-pr_inertial_movement:cur_delay)/(pr_inertial_movement:max_delay-pr_inertial_movement:min_delay)*100

/obj/spacecraft/proc/speed_increment(var/obj/spacecraft/SC as obj)
	if(SC.pr_inertial_movement:desired_delay != SC.pr_inertial_movement:cur_delay)
		var/delta = SC.pr_inertial_movement:desired_delay - SC.pr_inertial_movement:cur_delay
		SC.pr_inertial_movement:cur_delay += delta>0?1:-1
	return


////ENGINE//////
/obj/spacecraft/proc/engine_start()
	playsound(src, 'tauceti/modules/_spacecraft/sounds/engineon.ogg', 50, 0)
	src.occupant_message("<font color='red'>Starting up main engine...</font>")
	sleep(80)
	src.occupant_message("<font color='red'>Engine is online</font>")
	src.engine_overlay()
	can_move = 1
	src.jet_trail.start()


/obj/spacecraft/proc/engine_stop()
	src.occupant_message("<font color='red'>Engine is offline</font>")
	src.engine_overlay()
	can_move = 0
	src.jet_trail.stop()

/obj/spacecraft/proc/engine_check()
	if(!src.engine)
		return
	if(src.engine.cur_heat_capacity >= src.engine.max_heat_capacity)
		src.occupant_message("<font color='red'>[src.engine] has been damaged!</font>")
		can_move = 0
		src.engine.damaged = 1
		src.engine_on = 0
		src.jet_trail.stop()
		src.engine_overlay()

/obj/spacecraft/proc/engine_overlay()
	var/I = image('tauceti/modules/_spacecraft/spacecraft.dmi', loc = src, icon_state = "[src.class]-flame")
	if(src.engine_on)
		src.overlays += I
	else
		src.overlays -= I
	return

////FUEL STUFF//////
/obj/spacecraft/proc/has_fuel(amount)
	return (get_fuel()>=amount)

/obj/spacecraft/proc/get_fuel()
	if(!src.engine.fuel_tank) return
	return max(0, src.engine.fuel_tank.reagents.get_reagent_amount(src.engine.fuel_tank.reagent_type))

/obj/spacecraft/proc/use_fuel(amount)
	if(get_fuel())
		src.engine.fuel_tank.reagents.remove_reagent(src.engine.fuel_tank.reagent_type, amount)
		return 1
	return 0

/obj/spacecraft/proc/has_oxidiser(amount)
	return (get_oxidiser()>=amount)

/obj/spacecraft/proc/get_oxidiser()
	if(!src.engine.oxidiser_tank) return
	return max(0, src.engine.oxidiser_tank.reagents.get_reagent_amount(src.engine.oxidiser_tank.reagent_type))

/obj/spacecraft/proc/use_oxidiser(amount)
	if(get_oxidiser())
		src.engine.oxidiser_tank.reagents.remove_reagent(src.engine.oxidiser_tank.reagent_type, amount)
		return 1
	return 0

/////POWER STUFF/////
/obj/spacecraft/proc/has_charge(amount)
	return (get_charge()>=amount)

/obj/spacecraft/proc/get_charge()
	if(!src.cell) return
	return max(0, src.cell.charge)

/obj/spacecraft/proc/use_power(amount)
	if(get_charge())
		cell.use(amount)
		return 1
	return 0

/obj/spacecraft/proc/give_power(amount)
	if(!isnull(get_charge()))
		cell.give(amount)
		return 1
	return 0
/*
/obj/mecha/proc/reset_icon()
	if (initial_icon)
		icon_state = initial_icon
	else
		icon_state = initial(icon_state)
	return icon_state
	*/

//////////////////////////////////
/*****ATMOS WORKS****************/
//////////////////////////////////
/obj/spacecraft/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()
	return

/obj/spacecraft/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)
	return

/obj/spacecraft/return_air()
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/spacecraft/proc/return_pressure()
	. = 0
	if(use_internal_tank)
		. =  cabin_air.return_pressure()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_pressure()
	return

/obj/spacecraft/proc/return_temperature()
	. = 0
	if(use_internal_tank)
		. = cabin_air.return_temperature()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_temperature()
	return

//////////////////////////////////
/**********MESSAGES AND LOGS*****/
//////////////////////////////////
/obj/spacecraft/proc/occupant_message(message as text)
	if(message)
		if(src.pilot && src.pilot.client)
			src.pilot << "\icon[src] [message]"
	return
/*
/obj/spacecraft/proc/log_message(message as text,red=null)
	log.len++
	log[log.len] = list("time"=world.timeofday,"message"="[red?"<font color='red'>":null][message][red?"</font>":null]")
	return log.len

/obj/spacecraft/proc/log_append_to_last(message as text,red=null)
	var/list/last_entry = src.log[src.log.len]
	last_entry["message"] += "<br>[red?"<font color='red'>":null][message][red?"</font>":null]"
	return	*/

////ITERATORS///////
/datum/global_iterator/spacecraft_preserve_temp  //normalizing cabin air temperature to 20 degrees celsium. Типо кондиционер.
	delay = 20

	process(var/obj/spacecraft/SC)
		if(!SC.has_charge(0.3))
			return src.stop()
		else
			if(SC.cabin_air && SC.cabin_air.return_volume() > 0)
				var/delta = SC.cabin_air.temperature - T20C
				SC.cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))
				SC.use_power(0.3)
			return

/datum/global_iterator/spacecraft_tank_give_air
	delay = 15
	process(var/obj/spacecraft/SC)
		if(SC.internal_tank || !SC.has_charge(0.1))
			var/datum/gas_mixture/tank_air = SC.internal_tank.return_air()
			var/datum/gas_mixture/cabin_air = SC.cabin_air

			var/release_pressure = SC.internal_tank_valve
			var/cabin_pressure = cabin_air.return_pressure()
			var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
			var/transfer_moles = 0
			if(pressure_delta > 0) //cabin pressure lower than release pressure
				if(tank_air.return_temperature() > 0)
					transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
					cabin_air.merge(removed)
			else if(pressure_delta < 0) //cabin pressure higher than release pressure
				var/datum/gas_mixture/t_air = SC.get_turf_air()
				pressure_delta = cabin_pressure - release_pressure
				if(t_air)
					pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
				if(pressure_delta > 0) //if location pressure is lower than cabin pressure
					transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
					if(t_air)
						t_air.merge(removed)
					else //just delete the cabin gas, we're in space or some shit
						del(removed)
			SC.use_power(0.1)
		else
			return stop()
		return

/datum/global_iterator/spacecraft_cooling
	delay = 20
	process(var/obj/spacecraft/SC as obj)
		if(!SC.engine)
			return stop()
		if(!SC.has_charge(SC.cooling_rate/10))
			return stop()
		else
			if(SC.engine.cur_heat_capacity > SC.cooling_rate)
				SC.engine.cur_heat_capacity -= SC.cooling_rate
				SC.use_power(SC.cooling_rate/10)
		return

/datum/global_iterator/spacecraft_inertial_movement
	delay = 1
	var/min_delay = 0
	var/max_delay = 10
	var/desired_delay
	var/cur_delay
	var/last_move

	New()
		..()
		desired_delay = max_delay
		cur_delay = max_delay

	stop()
		src.cur_delay = max_delay
		src.desired_delay = max_delay
		return ..()

	process(var/obj/spacecraft/SC as obj)
		if(cur_delay >= max_delay)
			return src.stop()
		if(world.time - last_move < cur_delay)
			return
		last_move = world.time

		if(!step(SC, SC.dir) || !SC.inspace())
			src.stop()
		return

	proc/set_desired_delay(var/num as num)
		src.desired_delay = num
		return

/datum/global_iterator/spacecraft_speed_increment
	delay = 5

	process(var/obj/spacecraft/SC as obj)
		if(SC.pr_inertial_movement:desired_delay != SC.pr_inertial_movement:cur_delay)
			var/delta = SC.pr_inertial_movement:desired_delay - SC.pr_inertial_movement:cur_delay
			SC.pr_inertial_movement:cur_delay += delta>0?1:-1

			for(var/mob/M in SC)
				M << "Current speed: [SC.get_current_speed()]"

		else
			src.stop()
		return