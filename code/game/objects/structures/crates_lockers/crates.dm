//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"
	climbable = 1
//	mouse_drag_pointer = MOUSE_ACTIVE_POINTER	//???
	var/rigged = 0

/obj/structure/closet/crate/can_open()
	return 1

/obj/structure/closet/crate/can_close()
	return 1

/obj/structure/closet/crate/open()
	if(src.opened)
		return 0
	if(!src.can_open())
		return 0

	if(rigged && locate(/obj/item/device/radio/electropack) in src)
		if(isliving(usr))
			var/mob/living/L = usr
			if(L.electrocute_act(17, src))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return 2

	playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 15, null, -3)
	for(var/obj/O in src)
		O.forceMove(get_turf(src))
	icon_state = icon_opened
	src.opened = 1

	if(climbable)
		structure_shaken()

	return 1

/obj/structure/closet/crate/close()
	if(!src.opened)
		return 0
	if(!src.can_close())
		return 0

	playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 15, null, -3)
	var/itemcount = 0
	for(var/obj/O in get_turf(src))
		if(itemcount >= storage_capacity)
			break
		if(O.density || O.anchored || istype(O,/obj/structure/closet))
			continue
		if(istype(O, /obj/structure/stool/bed)) //This is only necessary because of rollerbeds and swivel chairs.
			var/obj/structure/stool/bed/B = O
			if(B.buckled_mob)
				continue
		O.forceMove(src)
		itemcount++

	icon_state = icon_closed
	src.opened = 0
	return 1

/obj/structure/closet/crate/attackby(obj/item/weapon/W, mob/user)
	if(opened || istype(W, /obj/item/weapon/grab))
		return ..()

	else if(istype(W, /obj/item/weapon/packageWrap) || istype(W, /obj/item/weapon/extraction_pack))	//OOP? Doesn't heard.
		return
	else if(iscoil(W))
		if(rigged)
			to_chat(user, "<span class='notice'>[src] is already rigged!</span>")
			return

		var/obj/item/stack/cable_coil/C = W
		if(!C.use(1))
			return

		to_chat(user, "<span class='notice'>You rig [src].</span>")
		rigged = 1
	else if(istype(W, /obj/item/device/radio/electropack))
		if(rigged)
			to_chat(user, "<span class='notice'>You attach [W] to [src].</span>")
			user.drop_item()
			W.forceMove(src)
	else if(iswirecutter(W))
		if(rigged)
			to_chat(user, "<span class='notice'>You cut away the wiring.</span>")
			playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
			rigged = 0
	else
		return attack_hand(user)

/obj/structure/closet/crate/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/O in src.contents)
				qdel(O)
			qdel(src)
			return
		if(2.0)
			for(var/obj/O in src.contents)
				if(prob(50))
					qdel(O)
			qdel(src)
			return
		if(3.0)
			if (prob(50))
				qdel(src)
			return
		else
	return

/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	var/redlight = "securecrater"
	var/greenlight = "securecrateg"
	var/sparks = "securecratesparks"
	var/emag = "securecrateemag"
	broken = 0
	locked = 1

/obj/structure/closet/crate/secure/atom_init()
	. = ..()
	if(locked)
		cut_overlays()
		add_overlay(redlight)
	else
		cut_overlays()
		add_overlay(greenlight)

/obj/structure/closet/crate/secure/can_open()
	return !locked

/obj/structure/closet/crate/secure/AltClick(mob/user)
	if(!user.incapacitated() && in_range(user, src) && user.IsAdvancedToolUser())
		src.togglelock(user)
	..()

/obj/structure/closet/crate/secure/proc/togglelock(mob/user)
	if(src.opened)
		to_chat(user, "<span class='notice'>Close the crate first.</span>")
		return
	if(src.broken)
		to_chat(user, "<span class='warning'>The crate appears to be broken.</span>")
		return
	if(src.allowed(user))
		src.locked = !src.locked
		for(var/mob/O in viewers(user, 3))
			if((O.client && !( O.blinded )))
				to_chat(O, "<span class='notice'>The crate has been [locked ? null : "un"]locked by [user].</span>")
		cut_overlays()
		add_overlay(locked ? redlight : greenlight)
	else
		to_chat(user, "<span class='notice'>Access Denied</span>")

/obj/structure/closet/crate/secure/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(usr.incapacitated()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(ishuman(usr))
		src.add_fingerprint(usr)
		src.togglelock(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/crate/secure/attack_hand(mob/user)
	src.add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	if(locked)
		src.togglelock(user)
	else
		src.toggle(user)

/obj/structure/closet/crate/secure/attackby(obj/item/weapon/W, mob/user)
	if(is_type_in_list(W, list(/obj/item/weapon/packageWrap, /obj/item/stack/cable_coil, /obj/item/device/radio/electropack, /obj/item/weapon/wirecutters)))
		return ..()
	if(locked && istype(W, /obj/item/weapon/melee/energy/blade))
		emag_act(user)
		return
	if(!opened)
		src.togglelock(user)
		return
	return ..()

/obj/structure/closet/crate/secure/emag_act(mob/user)
	if(!locked)
		return FALSE
	user.SetNextMove(CLICK_CD_MELEE)
	cut_overlays()
	add_overlay(emag)
	add_overlay(sparks)
	spawn(6) cut_overlay(sparks) //Tried lots of stuff but nothing works right. so i have to use this *sadface*
	playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	src.locked = 0
	src.broken = 1
	to_chat(user, "<span class='notice'>You unlock \the [src].</span>")
	return TRUE

/obj/structure/closet/crate/secure/emp_act(severity)
	for(var/obj/O in src)
		O.emplode(severity)
	if(!broken && !opened  && prob(50/severity))
		if(!locked)
			src.locked = 1
			cut_overlays()
			add_overlay(redlight)
		else
			cut_overlays()
			add_overlay(emag)
			add_overlay(sparks)
			spawn(6) cut_overlay(sparks) //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(src, 'sound/effects/sparks4.ogg', VOL_EFFECTS_MASTER)
			src.locked = 0
	if(!opened && prob(20/severity))
		if(!locked)
			open()
		else
			src.req_access = list()
			src.req_access += pick(get_all_accesses())
	..()

/obj/structure/closet/crate/plastic
	name = "plastic crate"
	desc = "A rectangular plastic crate."
	icon_state = "plasticcrate"
	icon_opened = "plasticcrateopen"
	icon_closed = "plasticcrate"

/obj/structure/closet/crate/internals
	desc = "A internals crate."
	name = "Internals crate"
	icon_state = "o2crate"
	icon_opened = "o2crateopen"
	icon_closed = "o2crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "Trash Cart"
	icon_state = "trashcart"
	icon_opened = "trashcartopen"
	icon_closed = "trashcart"

/*these aren't needed anymore
/obj/structure/closet/crate/hat
	desc = "A crate filled with Valuable Collector's Hats!."
	name = "Hat Crate"
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"

/obj/structure/closet/crate/contraband
	name = "Poster crate"
	desc = "A random assortment of posters manufactured by providers NOT listed under Nanotrasen's whitelist."
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"
*/

/obj/structure/closet/crate/engi
	desc = "A engineer crate."
	name = "Engineer crate"
	icon_state = "engicrate"
	icon_opened = "engicrateopen"
	icon_closed = "engicrate"

/obj/structure/closet/crate/secure/engisec
	desc = "A crate with a lock on it."
	name = "Secured engineer crate"
	icon_state = "engicrateopensec"
	icon_opened = "engiseccrateopensec"
	icon_closed = "engicrateopensec"

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "Medical crate"
	icon_state = "medicalcrate"
	icon_opened = "medicalcrateopen"
	icon_closed = "medicalcrate"

/obj/structure/closet/crate/secure/medical
	desc = "A crate with a lock on it"
	name = "Secured medical crate"
	icon_state = "medicalseccrate"
	icon_opened = "medicalseccrateopen"
	icon_closed = "medicalseccrate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of the RCD."
	name = "RCD crate"
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"

/obj/structure/closet/crate/rcd/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd(src)

/obj/structure/closet/crate/solar
	name = "Solar Pack crate"

/obj/structure/closet/crate/solar/PopulateContents()
	for(var/i in 1 to 21)
		new /obj/item/solar_assembly(src)
	new /obj/item/weapon/circuitboard/solar_control(src)
	new /obj/item/weapon/tracker_electronics(src)
	new /obj/item/weapon/paper/solar(src)

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "Freezer"
	icon_state = "freezer"
	icon_opened = "freezeropen"
	icon_closed = "freezer"
	var/target_temp = T0C - 40
	var/cooling_power = 40

/obj/structure/closet/crate/freezer/return_air()
	var/datum/gas_mixture/gas = (..())
	if(!gas)
		return null
	var/datum/gas_mixture/newgas = new/datum/gas_mixture()
	newgas.copy_from(gas)
	if(newgas.temperature <= target_temp)
		return

	if((newgas.temperature - cooling_power) > target_temp)
		newgas.temperature -= cooling_power
	else
		newgas.temperature = target_temp
	return newgas

/obj/structure/closet/crate/freezer/rations //Fpr use in the escape shuttle
	desc = "A crate of emergency rations."
	name = "Emergency Rations"


/obj/structure/closet/crate/freezer/rations/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/weapon/storage/box/donkpockets(src)

/obj/structure/closet/crate/bin
	desc = "A large bin."
	name = "Large bin"
	icon_state = "largebin"
	icon_opened = "largebinopen"
	icon_closed = "largebin"

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "Radioactive gear crate"
	icon_state = "radiation"
	icon_opened = "radiationopen"
	icon_closed = "radiation"

/obj/structure/closet/crate/radiation/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/clothing/suit/radiation(src)
	for(var/i in 1 to 4)
		new /obj/item/clothing/head/radiation(src)

/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "Weapons crate"
	icon_state = "weaponcrate"
	icon_opened = "weaponcrateopen"
	icon_closed = "weaponcrate"

/obj/structure/closet/crate/scicrate
	desc = "A science crate."
	name = "Science crate"
	icon_state = "scicrate"
	icon_opened = "scicrateopen"
	icon_closed = "scicrate"

/obj/structure/closet/crate/secure/scisecurecrate
	desc = "A secure science crate."
	name = "Science crate"
	icon_state = "scisecurecrate"
	icon_opened = "scisecurecrateopen"
	icon_closed = "scisecurecrate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "Gear crate"
	icon_state = "secgearcrate"
	icon_opened = "secgearcrateopen"
	icon_closed = "secgearcrate"

/obj/structure/closet/crate/secure/hydrosec
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon_state = "hydrosecurecrate"
	icon_opened = "hydrosecurecrateopen"
	icon_closed = "hydrosecurecrate"

/obj/structure/closet/crate/secure/miningsec
	desc = "Crate for incredulous miners."
	name = "secure mining crate"
	icon_state = "miningsecurecrate"
	icon_opened = "miningsecurecrateopen"
	icon_closed = "miningsecurecrate"
	req_access = list(access_mining)

/obj/structure/closet/crate/secure/woodseccrate
	desc = "A secure wooden crate."
	name = "Secure wooden crate"
	icon_state = "woodseccrate"
	icon_opened = "woodseccrateopen"
	icon_closed = "woodseccrate"

/obj/structure/closet/crate/secure/bin
	desc = "A secure bin."
	name = "Secure bin"
	icon_state = "largebins"
	icon_opened = "largebinsopen"
	icon_closed = "largebins"
	redlight = "largebinr"
	greenlight = "largebing"
	sparks = "largebinsparks"
	emag = "largebinemag"


/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty metal crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"

/obj/structure/closet/crate/large/close()
	. = ..()
	if (.)//we can hold up to one large item
		var/found = 0
		for(var/obj/structure/S in src.loc)
			if(S == src)
				continue
			if(!S.anchored)
				found = 1
				S.forceMove(src)
				break
		if(!found)
			for(var/obj/machinery/M in src.loc)
				if(!M.anchored)
					M.forceMove(src)
					break
	return

/obj/structure/closet/crate/secure/large
	name = "large crate"
	desc = "A hefty metal crate with an electronic locking system."
	icon = 'icons/obj/storage.dmi'
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"
	redlight = "largemetalr"
	greenlight = "largemetalg"

/obj/structure/closet/crate/secure/large/close()
	. = ..()
	if (.)//we can hold up to one large item
		var/found = 0
		for(var/obj/structure/S in src.loc)
			if(S == src)
				continue
			if(!S.anchored)
				found = 1
				S.forceMove(src)
				break
		if(!found)
			for(var/obj/machinery/M in src.loc)
				if(!M.anchored)
					M.forceMove(src)
					break
	return

//fluff variant
/obj/structure/closet/crate/secure/large/reinforced
	desc = "A hefty, reinforced metal crate with an electronic locking system."
	icon_state = "largermetal"
	icon_opened = "largermetalopen"
	icon_closed = "largermetal"

/obj/structure/closet/crate/hydroponics
	name = "Hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"
	icon_opened = "hydrocrateopen"
	icon_closed = "hydrocrate"

/obj/structure/closet/crate/hydroponics/prespawned
	//This exists so the prespawned hydro crates spawn with their contents.

/obj/structure/closet/crate/hydroponics/prespawned/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/spray/plantbgone(src)
	new /obj/item/weapon/minihoe(src)
//	new /obj/item/weapon/weedspray(src)
//	new /obj/item/weapon/weedspray(src)
//	new /obj/item/weapon/pestspray(src)
//	new /obj/item/weapon/pestspray(src)
//	new /obj/item/weapon/pestspray(src)

/obj/structure/closet/crate/dwarf_agriculture

/obj/structure/closet/crate/dwarf_agriculture/PopulateContents()
	new /obj/item/weapon/storage/bag/plants(src)
	new /obj/item/device/plant_analyzer(src)
	new /obj/item/weapon/minihoe(src)
	new /obj/item/weapon/hatchet(src)
	new /obj/item/seeds/reishimycelium(src)
	new /obj/item/seeds/glowshroom(src)
	new /obj/item/seeds/amanitamycelium(src)
	new /obj/item/seeds/angelmycelium(src)
	new /obj/item/seeds/libertymycelium(src)
	new /obj/item/seeds/plastiseed(src)
	new /obj/item/seeds/plumpmycelium(src)
	new /obj/item/seeds/chantermycelium(src)

/obj/structure/closet/crate/seized_inventory
	name = "crate (seized inventory)"

/obj/structure/closet/crate/seized_inventory/PopulateContents()
	var/contraband_num = rand(0, 7)
	var/obj/item/device/contraband_finder/seeker = new(null)

	var/list/contraband_types = seeker.contraband_items
	var/list/danger_types = seeker.danger_items

	var/list/contraband_reagents = seeker.contraband_reagents
	var/list/danger_reagents = seeker.danger_reagents

	if(!length(contraband_types) && !length(danger_types))
		return

	for(var/i in 1 to contraband_num)
		var/type_to_spawn
		if(prob(90) && length(contraband_types))
			type_to_spawn = pick(contraband_types)
		else if(length(danger_types))
			type_to_spawn = pick(danger_types)

		if(type_to_spawn)
			var/obj/item/I = new type_to_spawn(src)

			if(I && I.reagents && (length(contraband_reagents) || length(danger_reagents)))
				var/reagents_to_add = rand(0, I.reagents.maximum_volume)
				spawn_reagents_loop:
					while(TRUE)
						var/current_reagent_to_add = rand(1, max(1, reagents_to_add))
						reagents_to_add -= current_reagent_to_add
						if(reagents_to_add <= 0)
							break spawn_reagents_loop

						if(prob(90) && length(contraband_reagents))
							I.reagents.add_reagent(pick(contraband_reagents), reagents_to_add)
						else if(length(danger_reagents))
							I.reagents.add_reagent(pick(danger_reagents), reagents_to_add)
