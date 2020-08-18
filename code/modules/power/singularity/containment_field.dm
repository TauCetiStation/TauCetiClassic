//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/containment_field
	name = "Containment Field"
	desc = "An energy field."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "Contain_F"
	anchored = 1
	density = 0
	unacidable = 1
	use_power = NO_POWER_USE
	light_range = 4

	var/obj/machinery/field_generator/FG1 = null
	var/obj/machinery/field_generator/FG2 = null
	var/last_shock     = 0    // Used to add a delay between shocks. In some cases this used to crash servers by spawning hundreds of sparks every second.
	var/shock_cooldown = 20

/obj/machinery/containment_field/Destroy()
	detach_from_field_generator(FG1)
	FG1 = null
	detach_from_field_generator(FG2)
	FG2 = null
	return ..()

/obj/machinery/containment_field/proc/detach_from_field_generator(obj/machinery/field_generator/FG)
	if(!FG)
		return
	FG.fields -= src
	FG.turn_off()

/obj/machinery/containment_field/attack_hand(mob/user)
	if(in_range(src, user) && !isobserver(user))
		shock(user)

/obj/machinery/containment_field/blob_act()
	return 0

/obj/machinery/containment_field/ex_act(severity)
	return 0

/obj/machinery/containment_field/HasProximity(atom/movable/AM)
	if(issilicon(AM) && prob(40))
		shock(AM)
		return 1
	if(iscarbon(AM) && prob(50))
		shock(AM)
		return 1
	return 0


/obj/machinery/containment_field/proc/shock(mob/living/shoked_mob)
	if(world.time < last_shock + shock_cooldown)
		return

	if(!FG1 || !FG2)
		qdel(src)
		return

	var/datum/effect/effect/system/spark_spread/S = new
	S.set_up(5, 1, shoked_mob.loc)
	S.start()

	if(iscarbon(shoked_mob))
		var/shock_damage = min(rand(30,40), rand(30,40))
		shoked_mob.burn_skin(shock_damage)
		shoked_mob.updatehealth()

		shoked_mob.visible_message(
			"<span class='warning'>[shoked_mob] was shocked by the [src]!</span>",
			"<span class='danger'>You feel a powerful shock course through your body sending you flying!</span>",
			"<span class='notice'>You hear a heavy electrical crack.</span>")

		var/stun = min(shock_damage, 15)
		shoked_mob.Stun(stun)
		shoked_mob.Weaken(10)
		shoked_mob.updatehealth()

		var/atom/target = get_edge_target_turf(shoked_mob, get_dir(src, get_step_away(shoked_mob, src)))
		shoked_mob.throw_at(target, 200, 4)
	else if(issilicon(shoked_mob))
		var/shock_damage = rand(15,30)
		shoked_mob.take_overall_damage(0, shock_damage)

		shoked_mob.visible_message(
			"<span class='warning'>[shoked_mob] was shocked by the [src]!</span>",
			"<span class='danger'>Energy pulse detected, system damaged!</span>",
			"<span class='notice'>You hear an electrical crack.</span>")

		if(prob(20))
			shoked_mob.Stun(2)

	last_shock = world.time

/obj/machinery/containment_field/proc/set_master(master1, master2)
	if(!master1 || !master2)
		return

	FG1 = master1
	FG1.fields += src
	FG2 = master2
	FG2.fields += src
