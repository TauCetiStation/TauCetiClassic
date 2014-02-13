/obj/item/weapon/pickaxe/drill
	name = "mining drill" // Can dig sand as well!
	desc = "Yours is the drill that will pierce through the rock walls."
	icon = 'tauceti/modules/_mining/hand_tools.dmi'
	tc_custom = 'tauceti/modules/_mining/hand_tools.dmi'
	icon_state = "drill_ready"
	item_state = "drill"
	origin_tech = "materials=2;powerstorage=3;engineering=2"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	force = 15.0
	throwforce = 4.0
	w_class = 4.0
	m_amt = 3750
	attack_verb = list("hit", "pierced", "sliced", "attacked")
	drill_sound = 'tauceti/sounds/items/drill.ogg'
	drill_verb = "drill"
	digspeed = 30
	hardness = 3
	reliability = 100
	crit_fail = 5
	var/max_reliability = 100
	var/drill_cost = 50
	var/mode = 0
	var/state = 0
	var/obj/item/weapon/cell/power_supply
	var/cell_type = /obj/item/weapon/cell

/obj/item/weapon/pickaxe/drill/New()
	..()
	if(cell_type)
		power_supply = new cell_type(src)
	else
		power_supply = new(src)
	power_supply.give(power_supply.maxcharge)
	return

/obj/item/weapon/pickaxe/drill/update_icon()
	if(!state)
		icon_state = "drill_ready"
	else if(state == 1)
		icon_state = "drill_open"
	else if(state == 2)
		icon_state = "drill_broken"
	return

/obj/item/weapon/pickaxe/drill/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(state==0)
			state = 1
			user << "You open maintenance panel."
			update_icon()
		else if(state==1)
			state = 0
			user << "You close maintenance panel."
			update_icon()
		else if(state == 2)
			user << "[src] is broken!"
		return
	else if(istype(W, /obj/item/weapon/cell))
		if(state == 1 || state == 2)
			if(!power_supply)
				user.remove_from_mob(W)
				power_supply = W
				power_supply.loc = src
				user << "<span class='notice'>You load a powercell into \the [src]!</span>"
			else
				user << "<span class='notice'>There's already a powercell in \the [src].</span>"
		else
			user <<"[src] panel is closed."
		return
	else if(istype(W, /obj/item/weapon/repairkit))
		var/obj/item/weapon/repairkit/R = W
		if(state == 1)
			if(reliability <= max_reliability/2)
				if(R.uses == 0)
					return
				else
					R.uses -= 1
					reliability = max_reliability
					user << "You repaired [src]"
					if(R.uses == 0)
						del(R)
			else user << "[src] is in well condition."
		else if(state == 2)
			if(R.uses == 0)
				return
			else
				R.uses -= 1
				reliability = max_reliability
				state = 1
				update_icon()
				user << "You repaired [src]"
				if(R.uses == 0)
					del(R)
		return

/obj/item/weapon/pickaxe/drill/proc/update_reliability()
	if(reliability <= 0)
		state = 2
		update_icon()

/obj/item/weapon/pickaxe/drill/attack_hand(mob/user as mob)
	if(loc != user)
		..()
		return	//let them pick it up
	if(state == 1 || state == 2)
		if(!power_supply)
			user << "There's no powercell in the [src]."
		else
			power_supply.loc = get_turf(src.loc)
			user.put_in_hands(power_supply)
			power_supply.updateicon()
			power_supply = null
			user << "<span class='notice'>You pull the powercell out of \the [src].</span>"
		return

/obj/item/weapon/pickaxe/drill/attack_self(mob/user as mob)
	mode = !mode
	if(mode)
		digspeed = 20
		user << "[src] is now standard mode."
	else
		digspeed = 30
		user << "[src] is now safe mode."

/obj/item/weapon/repairkit
	name = "mining equipment repair kit"
	desc = "A generic kit containing all the needed tools and parts to repair mining tools."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "sven_kit"
	var/uses = 10

////¬«–€¬◊¿“ ¿//////
/obj/item/weapon/mining_charge
	name = "mining explosives"
	desc = "Used for mining."
	gender = PLURAL
	icon = 'tauceti/modules/_mining/explosives.dmi'
	icon_state = "charge_basic"
	item_state = "flashbang"
	flags = FPRINT | TABLEPASS | NOBLUDGEON
	w_class = 2.0
	var/timer = 10
	var/atom/target = null
	var/blast_range = 1
	var/impact = 2
	var/power = 5

/obj/item/weapon/mining_charge/attack_self(mob/user as mob)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(newtime < 5)
		newtime = 5
	timer = newtime
	user << "Timer set for [timer] seconds."

/obj/item/weapon/mining_charge/afterattack(turf/simulated/mineral/target as turf, mob/user as mob, flag)
	if (!flag)
		return
	if (!istype(target, /turf/simulated/mineral))
		return
	user << "Planting explosives..."

	if(do_after(user, 50) && in_range(user, target))
		user.drop_item()
		target = target
		loc = null
		var/location
		location = target
		target.overlays += image('tauceti/modules/_mining/explosives.dmi', "charge_basic_armed")
		user << "Charge has been planted. Timer counting down from [timer]."
		spawn(timer*10)
			for(var/turf/simulated/mineral/M in view(get_turf(target), blast_range))
				if(!M) return

				if(M.toughness && M.toughness > 1)
					M.toughness -= impact
				else
					M.ex_act(1)
			if(target)
				if(target.toughness && target.toughness > power)
					explosion(location, -1, -1, 2, 3)
					target.toughness -= impact
				else
					explosion(location, -1, -1, 2, 3)
					target.ex_act(1)
				if (src)
					del(src)

/obj/item/weapon/mining_charge/attack(mob/M as mob, mob/user as mob, def_zone)
	return
/*
//—»ÀŒ¬€≈ »Õ—“–”Ã≈Õ“€//
/obj/item/weapon/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "According to Nanotrasen accounting, this is mining equipment. It's been modified for extreme power output to crush rocks, but often serves as a miner's first defense against hostile alien life; it's not very powerful unless used in a low pressure environment."
	icon = 'tauceti/modules/_mining/hand_tools.dmi'
	tc_custom = 'tauceti/modules/_mining/hand_tools.dmi'
	icon_state = "kineticgun"
	item_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	cell_type = "/obj/item/weapon/cell/crap"
	var/overheat = 0
	var/recent_reload = 1

/obj/item/weapon/gun/energy/kinetic_accelerator/shoot_live_shot()
	overheat = 1
	spawn(20)
		overheat = 0
		recent_reload = 0
	..()

/obj/item/weapon/gun/energy/kinetic_accelerator/attack_self(var/mob/living/user/L)
	if(overheat || recent_reload)
		return
	power_supply.give(500)
	playsound(src.loc, 'sound/weapons/shotgunpump.ogg', 60, 1)
	recent_reload = 1
	update_icon()
	return

/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/item/projectile/kinetic
	select_name = "kinetic"
	e_cost = 500
	fire_sound = 'tauceti/sounds/weapon/Gunshot4.ogg'

/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 15
	damage_type = BRUTE
	flag = "bomb"
	var/range = 2
	var/power = 4

obj/item/projectile/kinetic/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure < 50)
		name = "full strength kinetic force"
		damage = 30
	..()

/obj/item/projectile/kinetic/Range()
	range--
	if(range <= 0)
		new /obj/item/effect/kinetic_blast(src.loc)
		del(src)

/obj/item/projectile/kinetic/on_hit(var/atom/target)
	var/turf/target_turf = get_turf(target)
	if(istype(target_turf, /turf/simulated/mineral))
		world << "Op!"
/*		var/turf/simulated/mineral/M = target_turf
		if(M.toughness && M.toughness <= power)
			M.GetDrilled()
	new /obj/item/effect/kinetic_blast(target_turf)
	..() */

/obj/item/effect/kinetic_blast
	name = "kinetic explosion"
	icon = 'tauceti/icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = 4.1

/obj/item/effect/kinetic_blast/New()
	spawn(4)
		del(src)		*/