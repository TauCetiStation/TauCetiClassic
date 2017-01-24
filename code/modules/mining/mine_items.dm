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
	/*/New year part
	new /obj/item/clothing/suit/wintercoat/cargo
	new /obj/item/clothing/head/santa(src)
	new /obj/item/clothing/shoes/winterboots(src)
	*/

/**********************Shuttle Computer**************************/
/*var/mining_shuttle_tickstomove = 10
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

/obj/machinery/computer/mining_shuttle/attack_hand(user)
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
	. = ..()
	if(!.)
		return

	if(href_list["move"])
		//if(ticker.mode.name == "blob")
		//	if(ticker.mode:declared)
		//		usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
		//		return

		if (!mining_shuttle_moving)
			to_chat(usr, "<span class='notice'>Shuttle recieved message and will be sent shortly.</span>")
			move_mining_shuttle()
		else
			to_chat(usr, "<span class='notice'>Shuttle is already moving.</span>")

	updateUsrDialog()

/obj/machinery/computer/mining_shuttle/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/card/emag) && !emagged)
		src.req_access = list()
		emagged = 1
		to_chat(usr, "<span class='notice'>You fried the consoles ID checking system. It's now available to everyone!</span>")
	else
		..()
*/
/******************************Lantern*******************************/
/obj/item/device/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	item_state = "lantern"
	desc = "A mining lantern."
	brightness_on = 4			// luminosity when on

/*****************************Pickaxe********************************/
/obj/item/weapon/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/items.dmi'
	icon_state = "pickaxe"
	flags = CONDUCT
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
	item_state = "plasmacutter"
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
	flags = CONDUCT
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
	icon = 'icons/obj/mining/hand_tools.dmi'
	icon_custom = 'icons/obj/mining/hand_tools.dmi'
	icon_state = "hand_drill"
	item_state = "drill"
	origin_tech = "materials=2;powerstorage=3;engineering=2"
	flags = CONDUCT
	slot_flags = null
	force = 15.0
	throwforce = 4.0
	w_class = 4.0
	m_amt = 3750
	attack_verb = list("hit", "pierced", "sliced", "attacked")
	drill_sound = 'sound/items/drill.ogg'
	drill_verb = "drill"
	digspeed = 30
	var/drill_cost = 15
	var/state = 0
	var/obj/item/weapon/stock_parts/cell/power_supply
	var/cell_type = /obj/item/weapon/stock_parts/cell
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

/obj/item/weapon/pickaxe/drill/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(state==0)
			state = 1
			to_chat(user, "<span class='notice'>You open maintenance panel.</span>")
			update_icon()
		else if(state==1)
			state = 0
			to_chat(user, "<span class='notice'>You close maintenance panel.</span>")
			update_icon()
		else if(state == 2)
			to_chat(user, "<span class='danger'>[src] is broken!</span>")
		return
	else if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(state == 1 || state == 2)
			if(!power_supply)
				user.remove_from_mob(W)
				power_supply = W
				power_supply.loc = src
				to_chat(user, "<span class='notice'>You load a powercell into \the [src]!</span>")
			else
				to_chat(user, "<span class='notice'>There's already a powercell in \the [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] panel is closed.</span>")
		return

/obj/item/weapon/pickaxe/drill/attack_hand(mob/user)
	if(loc != user)
		..()
		return	//let them pick it up
	if(state == 1 || state == 2)
		if(!power_supply)
			to_chat(user, "<span class='notice'>There's no powercell in the [src].</span>")
		else
			power_supply.loc = get_turf(src.loc)
			user.put_in_hands(power_supply)
			power_supply.updateicon()
			power_supply = null
			to_chat(user, "<span class='notice'>You pull the powercell out of \the [src].</span>")
		return

/obj/item/weapon/pickaxe/drill/attack_self(mob/user)
	mode = !mode

	if(mode)
		to_chat(user, "<span class='notice'>[src] is now standard mode.</span>")
	else
		to_chat(user, "<span class='notice'>[src] is now safe mode.</span>")


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



/*****************************Explosives********************************/
/obj/item/weapon/mining_charge
	name = "mining explosives"
	desc = "Used for mining."
	gender = PLURAL
	icon = 'icons/obj/mining/explosives.dmi'
	icon_state = "charge_basic"
	item_state = "flashbang"
	flags = NOBLUDGEON
	w_class = 2.0
	var/timer = 10
	var/atom/target = null
	var/blast_range = 1
	var/impact = 2
	var/power = 5

/obj/item/weapon/mining_charge/attack_self(mob/user)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(newtime < 5)
		newtime = 5
	timer = newtime
	to_chat(user, "<span class='notice'>Timer set for </span>[timer]<span class='notice'> seconds.</span>")

/obj/item/weapon/mining_charge/afterattack(turf/simulated/mineral/target, mob/user, flag)
	if (!flag)
		return
	if (!istype(target, /turf/simulated/mineral))
		to_chat(user, "<span class='notice'>You can't plant [src] on [target.name].</span>")
		return
	to_chat(user, "<span class='notice'>Planting explosives...</span>")

	if(do_after(user, 50, target = target) && in_range(user, target))
		user.drop_item()
		target = target
		loc = null
		var/location
		location = target
		target.overlays += image('icons/obj/mining/explosives.dmi', "charge_basic_armed")
		to_chat(user, "<span class='notice'>Charge has been planted. Timer counting down from </span>[timer]")
		spawn(timer*10)
			for(var/turf/simulated/mineral/M in view(get_turf(target), blast_range))
				if(!M)	return

			if(target)
				explosion(location, 3, 2, 2)
				target.ex_act(1)
				if(src)
					qdel(src)

/obj/item/weapon/mining_charge/attack(mob/M, mob/user, def_zone)
	return

/*****************************Power tools********************************/
/obj/item/weapon/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "According to Nanotrasen accounting, this is mining equipment. It's been modified for extreme power output to crush rocks, but often serves as a miner's first defense against hostile alien life; it's not very powerful unless used in a low pressure environment."
	icon = 'icons/obj/mining/hand_tools.dmi'
	icon_custom = 'icons/obj/mining/hand_tools.dmi'
	icon_state = "kineticgun"
	item_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	cell_type = "/obj/item/weapon/stock_parts/cell/crap"
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

/obj/item/weapon/gun/energy/kinetic_accelerator/attack_self(mob/living/user/L)
	if(overheat || recent_reload)
		return
	power_supply.give(500)
	if(!silenced)
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	else
		to_chat(usr, "<span class='warning'>You silently charge [src].<span>")
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

/obj/item/projectile/kinetic/on_hit(atom/target)
	. = ..()
	var/turf/target_turf = get_turf(target)
	if(istype(target_turf, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = target_turf
		M.GetDrilled(firer)
	new /obj/item/effect/kinetic_blast(target_turf)

/obj/item/effect/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = 4.1

/obj/item/effect/kinetic_blast/New()
	spawn(4)
		qdel(src)


/*****************************Survival Pod********************************/


/area/survivalpod
	name = "\improper Emergency Shelter"
	icon_state = "away"
	requires_power = 0
	has_gravity = 1

/obj/item/weapon/survivalcapsule
	name = "bluespace shelter capsule"
	desc = "An emergency shelter stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = 1
	origin_tech = "engineering=3;bluespace=2"
	var/template_id = "shelter_alpha"
	var/datum/map_template/shelter/template
	var/used = FALSE

/obj/item/weapon/survivalcapsule/proc/get_template()
	if(template)
		return
	template = shelter_templates[template_id]
	if(!template)
		qdel(src)

/obj/item/weapon/survivalcapsule/Destroy()
	template = null // without this, capsules would be one use. per round.
	. = ..()

/obj/item/weapon/survivalcapsule/examine(mob/user)
	..()
	get_template()
	to_chat(user, "This capsule has the [template.name] stored.")
	to_chat(user, template.description)

/obj/item/weapon/survivalcapsule/attack_self()
	// Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(!used)
		var/turf/T = get_turf(src)
		if((T.z != ZLEVEL_ASTEROID) && !istype(T.loc, /area/space)) //we don't need complete all checks
			src.loc.visible_message("<span class='warning'>You must use shelter at asteroid or in space! Grab this shit \
			and shut up!</span>")
			used = TRUE
			new /obj/item/clothing/mask/breath(T)
			new /obj/item/weapon/tank/air(T)
			new /obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian(T)
			new /obj/item/clothing/suit/space/cheap(T)
			new /obj/item/clothing/head/helmet/space/cheap(T)
			playsound(T, 'sound/effects/sparks2.ogg', 100, 1)
		else
			src.loc.visible_message("<span class='warning'>\The [src] begins \
				to shake. Stand back!</span>")
			used = TRUE
			sleep(50)

			T = get_turf(src) //update location
			var/status = template.check_deploy(T)
			switch(status)
				if(SHELTER_DEPLOY_BAD_AREA)
					src.loc.visible_message("<span class='warning'>\The [src] \
					will not function in this area.</span>")
				if(SHELTER_DEPLOY_BAD_TURFS, SHELTER_DEPLOY_ANCHORED_OBJECTS)
					var/width = template.width
					var/height = template.height
					src.loc.visible_message("<span class='warning'>\The [src] \
					doesn't have room to deploy! You need to clear a \
					[width]x[height] area!</span>")

			if(status != SHELTER_DEPLOY_ALLOWED)
				used = FALSE
				return

			playsound(T, 'sound/effects/phasein.ogg', 100, 1)

			if(T.z != ZLEVEL_ASTEROID)//only report capsules away from the mining level
				message_admins("[key_name_admin(usr)] [ADMIN_QUE(usr)] [ADMIN_FLW(usr)] activated a bluespace capsule away from the mining level! [ADMIN_JMP(T)]")
				log_admin("[key_name(usr)] activated a bluespace capsule away from the mining level at [T.x], [T.y], [T.z]")
			template.load(T, centered = TRUE)

		PoolOrNew(/datum/effect/effect/system/smoke_spread, T)
		qdel(src)

//Pod turfs and objects


//Floors
/turf/simulated/floor/pod
	name = "pod floor"
	icon_state = "podfloor"

/*
/turf/simulated/floor/pod/light
	icon_state = "podfloor_light"
	icon_regular_floor = "podfloor_light"
	floor_tile = /obj/item/stack/tile/pod/light

/turf/simulated/floor/pod/dark
	icon_state = "podfloor_dark"
	icon_regular_floor = "podfloor_dark"
	floor_tile = /obj/item/stack/tile/pod/dark
*/

//Walls

/obj/item/inflatable/survival
	name = "inflatable pod wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	w_class = 3.0

/obj/structure/inflatable/survival
	name = "pod wall"
	desc = "An easily-compressable wall used for temporary shelter."
	icon_state = "surv_wall0"
	var/basestate = "surv_wall"

/obj/structure/inflatable/survival/New()
	..()
	update_nearby_icons()

/obj/structure/inflatable/survival/Destroy()
	update_nearby_tiles()
	return ..()

/obj/structure/inflatable/survival/proc/update_nearby_icons()
	update_icon()
	for(var/direction in cardinal)
		for(var/obj/structure/inflatable/survival/W in get_step(src,direction) )
			W.update_icon()

/obj/structure/inflatable/survival/update_icon()
	spawn(2)
		if(!src)
			return

		var/junction = 0
		if(anchored)
			for(var/obj/structure/inflatable/survival/W in orange(src,1))
				if(abs(x-W.x)-abs(y-W.y) )
					junction |= get_dir(src,W)
		icon_state = "[basestate][junction]"

//Window
/obj/structure/window/shuttle/survival_pod
	name = "pod window"
	icon = 'icons/obj/survwindows.dmi'
	icon_state = "window"
	basestate = "window"

//Door
/obj/structure/inflatable/door/survival_pod
	name = "inflatable airlock"
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "door_surv_closed"
	opening_state = "door_surv_opening"
	closing_state = "door_surv_closing"
	open_state = "door_surv_open"
	closed_state = "door_surv_closed"

//Table
/*
/obj/structure/table/survival_pod
	icon = 'icons/obj/survival_pod.dmi'
	icon_state = "table"*/

//Sleeper
/obj/machinery/sleeper/survival_pod
	icon = 'icons/obj/survival_pod.dmi'

//Computer
/obj/item/device/gps/computer
	name = "pod computer"
	icon_state = "pod_computer"
	icon = 'icons/obj/survival_pod_computer.dmi'
	anchored = 1
	density = 1
	pixel_y = -32

/obj/item/device/gps/computer/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench) && !(flags&NODECONSTRUCT))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] disassembles the gps.</span>", \
						"<span class='notice'>You start to disassemble the gps...</span>", "You hear clanking and banging noises.")
		if(do_after(user, 20/W.toolspeed, target = src))
			new /obj/item/device/gps(src.loc)
			qdel(src)
			return ..()

/obj/item/device/gps/computer/attack_hand(mob/user)
	attack_self(user)

//Bed
/obj/structure/stool/bed/pod
	icon = 'icons/obj/survival_pod.dmi'
	icon_state = "bed"

//Survival Storage Unit
/obj/machinery/smartfridge/survival_pod
	name = "survival pod storage"
	desc = "A heated storage unit."
	icon_state = "donkvendor"
	icon = 'icons/obj/survival_pod_vendor.dmi'
	icon_on = "donkvendor"
	icon_off = "donkvendor"
	icon_panel = "donkvendor-panel"
	luminosity = 5
	max_n_of_items = 10
	pixel_y = -4
	active_power_usage = 0
	idle_power_usage = 0
	var/forbidden_tools = list()

/obj/machinery/smartfridge/survival_pod/empty
	name = "dusty survival pod storage"
	desc = "A heated storage unit. This one's seen better days."

/obj/machinery/smartfridge/survival_pod/empty/New()
	return()

/obj/machinery/smartfridge/survival_pod/accept_check(obj/item/O)
	if(istype(O, /obj/item))
		return 1
	return 0

/obj/machinery/smartfridge/survival_pod/New()
	..()
	set_light(luminosity)
	for(var/i in 1 to 5)
		var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/W = new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		W.warm = 1
		W.loc = src
		if(item_quants[W.name])
			item_quants[W.name]++
		else
			item_quants[W.name] = 1
	if(prob(50))
		var/obj/item/weapon/storage/pill_bottle/dice/D = new /obj/item/weapon/storage/pill_bottle/dice(src)
		D.loc = src
		item_quants[D.name] = 1
	else
		var/obj/item/device/guitar/G = new /obj/item/device/guitar(src)
		G.loc = src
		item_quants[G.name] = 1
	forbidden_tools = typecacheof(/obj/item/weapon/crowbar)
	forbidden_tools += typecacheof(/obj/item/weapon/screwdriver)
	forbidden_tools += typecacheof(/obj/item/weapon/wrench)
	forbidden_tools += typecacheof(/obj/item/weapon/wirecutters)
	spawn(20)
		stat = 0
		ispowered = 1

/obj/machinery/smartfridge/survival_pod/attackby(obj/item/O, mob/user)
	if(is_type_in_typecache(O,forbidden_tools))
		if(istype(O,/obj/item/weapon/wrench))
			to_chat(user, "\blue You start to disassemble the storage unit...")
			if(do_after(user,20,target = src))
				if(!src)
					return
				qdel(src)
			return
		if(accept_check(O))
			if(contents.len >= max_n_of_items)
				to_chat(user, "<span class='notice'>\The [src] is full.</span>")
				return 1
			else
				user.remove_from_mob(O)
				O.loc = src
				if(item_quants[O.name])
					item_quants[O.name]++
				else
					item_quants[O.name] = 1
				user.visible_message("<span class='notice'>[user] has added \the [O] to \the [src].", \
									 "<span class='notice'>You add \the [O] to \the [src].")
				nanomanager.update_uis(src)
				return

	..()

//Fans
/obj/structure/fans
	icon = 'icons/obj/survival_pod.dmi'
	icon_state = "fans"
	name = "environmental regulation system"
	desc = "A large machine releasing a constant gust of air."
	anchored = 1
	density = 1

/obj/structure/fans/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench) && !(flags&NODECONSTRUCT))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] disassembles the fan.</span>", \
						"<span class='notice'>You start to disassemble the fan...</span>", "You hear clanking and banging noises.")
		if(do_after(user, 20/W.toolspeed, target = src))
			if(src.name == "environmental regulation system")
				new /obj/item/weapon/tank/air(src.loc)
			qdel(src)
			return ..()

/obj/structure/fans/tiny
	name = "tiny fan"
	desc = "A tiny fan, releasing a thin gust of air."
	layer = ABOVE_NORMAL_TURF_LAYER
	density = 0
	icon_state = "fan_tiny"

/obj/structure/fans/tiny/New()
	var/turf/T = get_turf(loc)
	if(T)
		T.blocks_air = 1
	..()

/obj/structure/fans/tiny/Destroy()
	var/turf/T = get_turf(loc)
	if(T)
		T.blocks_air = 0
		if(SSair)
			SSair.mark_for_update(get_turf(loc))
	return ..()

/obj/structure/fans/New(loc)
	..()

/obj/structure/fans/Destroy()
	return ..()

//Signs
/obj/structure/sign/mining
	name = "nanotrasen mining corps sign"
	desc = "A sign of relief for weary miners, and a warning for would-be competitors to Nanotrasen's mining claims."
	icon = 'icons/turf/walls.dmi'
	icon_state = "ntpod"

/obj/structure/sign/mining/survival
	name = "shelter sign"
	desc = "A high visibility sign designating a safe shelter."
	icon = 'icons/turf/walls.dmi'
	icon_state = "survival"

/obj/structure/sign/mining/attack_hand(mob/user)
	if(..(user))
		return
	user.visible_message("[user] removes the sign.", "You remove the sign.")
	qdel(src)

//Fluff
/obj/structure/tubes
	icon_state = "tubes"
	icon = 'icons/obj/survival_pod.dmi'
	name = "tubes"
	anchored = 1
	layer = BELOW_MOB_LAYER
	density = 0
