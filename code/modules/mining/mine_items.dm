/**********************Light************************/
//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light-emtter"
	anchored = 1
	unacidable = 1
	light_range = 8

/**********************Miner Lockers**************************/
/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "miningsec1"
	icon_closed = "miningsec"
	icon_locked = "miningsec1"
	icon_opened = "miningsecopen"
	icon_broken = "miningsecbroken"
	icon_off = "miningsecoff"
	req_access = list(access_mining)

/obj/structure/closet/secure_closet/miner/New()
	..()
	sleep(2)
	if(prob(50))
		new /obj/item/weapon/storage/backpack/industrial(src)
	else
		new /obj/item/weapon/storage/backpack/satchel_eng(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/device/geoscanner(src)
	new /obj/item/weapon/storage/bag/ore(src)
	new /obj/item/device/flashlight/lantern(src)
	new /obj/item/weapon/shovel(src)
//	new /obj/item/weapon/pickaxe(src)
	new /obj/item/clothing/glasses/hud/mining(src)
	//New year part
	new /obj/item/clothing/suit/wintercoat/cargo
	new /obj/item/clothing/head/santa(src)
	new /obj/item/clothing/shoes/winterboots(src)

/**********************Shuttle Computer**************************/
var/mining_shuttle_tickstomove = 10
var/mining_shuttle_moving = 0
var/mining_shuttle_location = 0 // 0 = station 13, 1 = mining station

proc/move_mining_shuttle()
	if(mining_shuttle_moving)	return
	mining_shuttle_moving = 1
	spawn(mining_shuttle_tickstomove*10)
		var/area/fromArea
		var/area/toArea
		if (mining_shuttle_location == 1)
			fromArea = locate(/area/shuttle/mining/outpost)
			toArea = locate(/area/shuttle/mining/station)

		else
			fromArea = locate(/area/shuttle/mining/station)
			toArea = locate(/area/shuttle/mining/outpost)

		var/list/dstturfs = list()
		var/throwy = world.maxy

		for(var/turf/T in toArea)
			dstturfs += T
			if(T.y < throwy)
				throwy = T.y

		// hey you, get out of the way!
		for(var/turf/T in dstturfs)
			// find the turf to move things to
			var/turf/D = locate(T.x, throwy - 1, 1)
			//var/turf/E = get_step(D, SOUTH)
			for(var/atom/movable/AM as mob|obj in T)
				AM.Move(D)
				// NOTE: Commenting this out to avoid recreating mass driver glitch
				/*
				spawn(0)
					AM.throw_at(E, 1, 1)
					return
				*/

			if(istype(T, /turf/simulated))
				qdel(T)

		for(var/mob/living/carbon/bug in toArea) // If someone somehow is still in the shuttle's docking area...
			bug.gib()

		for(var/mob/living/simple_animal/pest in toArea) // And for the other kind of bug...
			pest.gib()

		fromArea.move_contents_to(toArea)
		if (mining_shuttle_location)
			mining_shuttle_location = 0
		else
			mining_shuttle_location = 1

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					if(M.buckled)
						shake_camera(M, 3, 1) // buckled, not a lot of shaking
					else
						shake_camera(M, 10, 1) // unbuckled, HOLY SHIT SHAKE THE ROOM
			if(istype(M, /mob/living/carbon))
				if(!M.buckled)
					M.Weaken(3)

		mining_shuttle_moving = 0
	return

/obj/machinery/computer/mining_shuttle
	name = "mining shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = list(access_mining)
	circuit = "/obj/item/weapon/circuitboard/mining_shuttle"
	var/location = 0 //0 = station, 1 = mining base

/obj/machinery/computer/mining_shuttle/attack_hand(user as mob)
	if(..(user))
		return
	src.add_fingerprint(usr)
	var/dat

	dat = "<center>Mining Shuttle Control<hr>"

	if(mining_shuttle_moving)
		dat += "Location: <font color='red'>Moving</font> <br>"
	else
		dat += "Location: [mining_shuttle_location ? "Outpost" : "Station"] <br>"

	dat += "<b><A href='?src=\ref[src];move=[1]'>Send</A></b></center>"


	user << browse("[dat]", "window=miningshuttle;size=200x150")

/obj/machinery/computer/mining_shuttle/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["move"])
		//if(ticker.mode.name == "blob")
		//	if(ticker.mode:declared)
		//		usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
		//		return

		if (!mining_shuttle_moving)
			usr << "<span class='notice'>Shuttle recieved message and will be sent shortly.</span>"
			move_mining_shuttle()
		else
			usr << "<span class='notice'>Shuttle is already moving.</span>"

	updateUsrDialog()

/obj/machinery/computer/mining_shuttle/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/card/emag) && !emagged)
		src.req_access = list()
		emagged = 1
		usr << "<span class='notice'>You fried the consoles ID checking system. It's now available to everyone!</span>"
	else
		..()

/******************************Lantern*******************************/
/obj/item/device/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	desc = "A mining lantern."
	brightness_on = 4			// luminosity when on

/*****************************Pickaxe********************************/
/obj/item/weapon/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/items.dmi'
	icon_state = "pickaxe"
	flags = FPRINT | TABLEPASS| CONDUCT
//	slot_flags = SLOT_BELT
	force = 15.0
	throwforce = 4.0
	item_state = "pickaxe"
	w_class = 4.0
	m_amt = 3750 //one sheet, but where can you make them?
	var/digspeed = 50 //moving the delay to an item var so R&D can make improved picks. --NEO
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("hit", "pierced", "sliced", "attacked")
	var/drill_sound = 'sound/weapons/Genhit.ogg'
	var/drill_verb = "picking"
	sharp = 1

	var/excavation_amount = 100

/obj/item/weapon/pickaxe/hammer
	name = "sledgehammer"
	//icon_state = "sledgehammer" Waiting on sprite
	desc = "A mining hammer made of reinforced metal. You feel like smashing your boss in the face with this."

/obj/item/weapon/pickaxe/silver
	name = "silver pickaxe"
	icon_state = "spickaxe"
	item_state = "spickaxe"
	digspeed = 45
	origin_tech = "materials=3"
	desc = "This makes no metallurgic sense."

/obj/item/weapon/pickaxe/gold
	name = "golden pickaxe"
	icon_state = "gpickaxe"
	item_state = "gpickaxe"
	digspeed = 45
	origin_tech = "materials=4"
	desc = "This makes no metallurgic sense."

/obj/item/weapon/pickaxe/plasmacutter
	name = "plasma cutter"
	icon_state = "plasmacutter"
	item_state = "gun"
	w_class = 3.0 //it is smaller than the pickaxe
	damtype = "fire"
	digspeed = 20 //Can slice though normal walls, all girders, or be used in reinforced wall deconstruction/ light thermite on fire
	origin_tech = "materials=4;phorontech=3;engineering=3"
	desc = "A rock cutter that uses bursts of hot plasma. You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	drill_verb = "cutting"

/obj/item/weapon/pickaxe/diamond
	name = "diamond pickaxe"
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	digspeed = 10
	origin_tech = "materials=6;engineering=4"
	desc = "A pickaxe with a diamond pick head, this is just like minecraft."


/*****************************Shovel********************************/
/obj/item/weapon/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/items.dmi'
	icon_state = "shovel"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	force = 8.0
	throwforce = 4.0
	item_state = "shovel"
	w_class = 3.0
	m_amt = 50
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")

/obj/item/weapon/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
	force = 5.0
	throwforce = 7.0
	w_class = 2.0


/**********************Mining car (Crate like thing, not the rail car)**************************/
/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
	icon = 'icons/obj/storage.dmi'
	icon_state = "miningcar"
	density = 1
	icon_opened = "miningcaropen"
	icon_closed = "miningcar"


/**********************Mining drills**************************/
/obj/item/weapon/pickaxe/drill
	name = "mining drill" // Can dig sand as well!
	desc = "Yours is the drill that will pierce through the rock walls."
	icon = 'tauceti/modules/_mining/hand_tools.dmi'
	tc_custom = 'tauceti/modules/_mining/hand_tools.dmi'
	icon_state = "hand_drill"
	item_state = "drill"
	origin_tech = "materials=2;powerstorage=3;engineering=2"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = null
	force = 15.0
	throwforce = 4.0
	w_class = 4.0
	m_amt = 3750
	attack_verb = list("hit", "pierced", "sliced", "attacked")
	drill_sound = 'tauceti/sounds/items/drill.ogg'
	drill_verb = "drill"
	digspeed = 30
	reliability = 600
	crit_fail = 1
	var/max_reliability = 600
	var/drill_cost = 15
	var/state = 0
	var/obj/item/weapon/cell/power_supply
	var/cell_type = /obj/item/weapon/cell
	var/mode = 0

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
		icon_state = initial(icon_state)
	else if(state == 1)
		icon_state += "_open"
	else if(state == 2)
		icon_state += "_broken"
	return

/obj/item/weapon/pickaxe/drill/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(state==0)
			state = 1
			user << "<span class='notice'>You open maintenance panel.</span>"
			update_icon()
		else if(state==1)
			state = 0
			user << "<span class='notice'>You close maintenance panel.</span>"
			update_icon()
		else if(state == 2)
			user << "<span class='danger'>[src] is broken!</span>"
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
			user <<"<span class='notice'>[src] panel is closed.</span>"
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
					user << "<span class='notice'>You repaired [src].</span>"
					if(R.uses == 0)
						qdel(R)
			else user << "<span class='notice'>[src] is in well condition.</span>"
		else if(state == 2)
			if(R.uses == 0)
				return
			else
				R.uses -= 1
				reliability = max_reliability
				state = 1
				update_icon()
				user << "<span class='notice'>You repaired [src].</span>"
				if(R.uses == 0)
					qdel(R)
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
			user << "<span class='notice'>There's no powercell in the [src].</span>"
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
		user << "<span class='notice'>[src] is now standard mode.</span>"
	else
		user << "<span class='notice'>[src] is now safe mode.</span>"


/obj/item/weapon/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	icon_state = "jackhammer"
	digspeed = 40 //Drills 3 tiles in front of user
	origin_tech = "materials=3;powerstorage=2;engineering=2"
	desc = "Cracks rocks with sonic blasts, perfect for killing cave lizards."
	drill_verb = "hammering"

	attackby()
		return

/obj/item/weapon/pickaxe/drill/diamond_drill //When people ask about the badass leader of the mining tools, they are talking about ME!
	name = "diamond mining drill"
	icon_state = "diamond_drill"
	digspeed = 15 //Digs through walls, girders, and can dig up sand
	origin_tech = "materials=6;powerstorage=4;engineering=5"
	desc = "Yours is the drill that will pierce the heavens!"
	drill_verb = "drilling"


/obj/item/weapon/pickaxe/drill/borgdrill
	name = "cyborg mining drill"
	icon_state = "diamond_drill"
	item_state = "jackhammer"
	digspeed = 20
	desc = ""
	drill_verb = "drilling"

	attackby()
		return


/obj/item/weapon/repairkit
	name = "mining equipment repair kit"
	desc = "A generic kit containing all the needed tools and parts to repair mining tools."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "sven_kit"
	var/uses = 10

/*****************************Explosives********************************/
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
	user << "<span class='notice'>Timer set for </span>[timer]<span class='notice'> seconds.</span>"

/obj/item/weapon/mining_charge/afterattack(turf/simulated/mineral/target as turf, mob/user as mob, flag)
	if (!flag)
		return
	if (!istype(target, /turf/simulated/mineral))
		user << "<span class='notice'>You can't plant [src] on [target.name].</span>"
		return
	user << "<span class='notice'>Planting explosives...</span>"

	if(do_after(user, 50, target = target) && in_range(user, target))
		user.drop_item()
		target = target
		loc = null
		var/location
		location = target
		target.overlays += image('tauceti/modules/_mining/explosives.dmi', "charge_basic_armed")
		user << "<span class='notice'>Charge has been planted. Timer counting down from </span>[timer]"
		spawn(timer*10)
			for(var/turf/simulated/mineral/M in view(get_turf(target), blast_range))
				if(!M)	return

			if(target)
				explosion(location, 3, 2, 2)
				target.ex_act(1)
				if(src)
					qdel(src)

/obj/item/weapon/mining_charge/attack(mob/M as mob, mob/user as mob, def_zone)
	return

/*****************************Power tools********************************/
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
	var/overheat_time = 20
	var/recent_reload = 1

/obj/item/weapon/gun/energy/kinetic_accelerator/shoot_live_shot()
	overheat = 1
	spawn(overheat_time)
		overheat = 0
		recent_reload = 0
	..()

/obj/item/weapon/gun/energy/kinetic_accelerator/emp_act(severity)
	return

/obj/item/weapon/gun/energy/kinetic_accelerator/attack_self(var/mob/living/user/L)
	if(overheat || recent_reload)
		return
	power_supply.give(500)
	if(!silenced)
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	else
		usr << "<span class='warning'>You silently charge [src].<span>"
	recent_reload = 1
	update_icon()
	return

/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/item/projectile/kinetic
	select_name = "kinetic"
	e_cost = 500
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 10
	damage_type = BRUTE
	flag = "bomb"
	var/range = 3
	var/power = 4

obj/item/projectile/kinetic/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure < 50)
		name = "full strength kinetic force"
		damage *= 4
	..()

/obj/item/projectile/kinetic/Range()
	range--
	if(range <= 0)
		new /obj/item/effect/kinetic_blast(src.loc)
		qdel(src)

/obj/item/projectile/kinetic/on_hit(var/atom/target)
	. = ..()
	var/turf/target_turf = get_turf(target)
	if(istype(target_turf, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = target_turf
		M.GetDrilled(firer)
	new /obj/item/effect/kinetic_blast(target_turf)

/obj/item/effect/kinetic_blast
	name = "kinetic explosion"
	icon = 'tauceti/icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = 4.1

/obj/item/effect/kinetic_blast/New()
	spawn(4)
		qdel(src)