/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/stun, /obj/item/ammo_casing/energy/electrode)
	can_be_holstered = TRUE
	cell_type = "/obj/item/weapon/stock_parts/cell/crap"

/obj/item/weapon/gun/energy/taser/cyborg
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	fire_sound = 'sound/weapons/guns/gunpulse_Taser.ogg'
	ammo_type = list(/obj/item/ammo_casing/energy/stun)
	cell_type = "/obj/item/weapon/stock_parts/cell/secborg"
	var/charge_tick = 0
	var/recharge_time = 10 //Time it takes for shots to recharge (in ticks)

/obj/item/weapon/gun/energy/taser/cyborg/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/gun/energy/taser/cyborg/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/gun/energy/taser/cyborg/process() //Every [recharge_time] ticks, recharge a shot for the cyborg
	charge_tick++
	if(charge_tick < recharge_time) return 0
	charge_tick = 0

	if(!power_supply) return 0 //sanity
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost)) 		//Take power from the borg...
				power_supply.give(shot.e_cost)	//... to recharge the shot

	update_icon()
	return 1



/obj/item/weapon/gun/energy/taser/stunrevolver
	name = "stun revolver"
	desc = "A high-tech revolver that fires stun cartridges. The stun cartridges can be recharged using a conventional energy weapon recharger."
	icon_state = "stunrevolver"
	item_state = "taser"
	origin_tech = "combat=3;materials=3;powerstorage=2"
	ammo_type = list(/obj/item/ammo_casing/energy/stun/gun)
	cell_type = "/obj/item/weapon/stock_parts/cell"

/obj/item/weapon/gun/energy/crossbow
	name = "foam dart crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon_state = "crossbow"
	w_class = ITEM_SIZE_SMALL
	item_state = "crossbow"
	m_amt = 2000
	origin_tech = "combat=2;magnets=2;syndicate=5"
	silenced = 1
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)
	can_be_holstered = TRUE
	cell_type = "/obj/item/weapon/stock_parts/cell/crap"
	var/charge_tick = 0


/obj/item/weapon/gun/energy/crossbow/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/weapon/gun/energy/crossbow/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/weapon/gun/energy/crossbow/process()
	charge_tick++
	if(charge_tick < 4) return 0
	charge_tick = 0
	if(!power_supply) return 0
	power_supply.give(100)
	return 1


/obj/item/weapon/gun/energy/crossbow/update_icon()
	return

/obj/item/weapon/gun/energy/crossbow/largecrossbow
	name = "Energy Crossbow"
	desc = "A weapon favored by syndicate infiltration teams."
	w_class = ITEM_SIZE_LARGE
	can_be_holstered = FALSE
	force = 10
	m_amt = 200000
