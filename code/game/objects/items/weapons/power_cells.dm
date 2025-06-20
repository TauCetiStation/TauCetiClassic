/obj/item/weapon/stock_parts/cell
	name = "power cell"
	desc = "A rechargable electrochemical power cell."
	hitsound = list('sound/items/tools/device_big-hit.ogg')
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	origin_tech = "powerstorage=1"
	force = 3.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	w_class = SIZE_SMALL
	var/charge = 0
	var/maxcharge = 1000
	var/init_full = TRUE // initialize charge with maxcharge
	m_amt = 700
	g_amt = 50
	var/rigged = 0 // true if rigged to explode
	var/minor_fault = 0 //If not 100% reliable, it will build up faults.
	var/charge_efficiency = 0.033


/obj/item/weapon/stock_parts/cell/proc/get_charge_efficiency()
	var/base_efficiency = charge_efficiency


	if(minor_fault)
		base_efficiency *= 0.8


	var/wear_factor = 1.0
	if(reliability < 100)
		wear_factor = 0.7 + (reliability / 150.0)

	return base_efficiency * wear_factor

/obj/item/weapon/stock_parts/cell/set_prototype_qualities(rel_val=100, mark=0)
	..()
	while(!prob(reliability))
		if(maxcharge <= 1000)
			break
		if(maxcharge < 10000)
			maxcharge = max(maxcharge - 2000, 1000)
		else
			maxcharge = max(maxcharge * 0.9, 1000)
		charge = min(charge, maxcharge)

/obj/item/weapon/stock_parts/cell/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] is licking the electrodes of the [src.name]! It looks like \he's trying to commit suicide.</b></span>")
	return (FIRELOSS)

/obj/item/weapon/stock_parts/cell/crap
	name = "Nanotrasen brand rechargable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	origin_tech = "powerstorage=1"
	maxcharge = 500
	init_full = FALSE
	g_amt = 40
	rating = 2
	charge_efficiency = 0.1

/obj/item/weapon/stock_parts/cell/secborg
	name = "security borg rechargable D battery"
	origin_tech = "powerstorage=1"
	maxcharge = 600 //600 max charge / 100 charge per shot = six shots
	g_amt = 40
	rating = 2.5
	charge_efficiency = 0.2

/obj/item/weapon/stock_parts/cell/secborg/empty
	init_full = FALSE

/obj/item/weapon/stock_parts/cell/apc
	name = "APC power cell"
	desc = "A special power cell designed for heavy-duty use in area power controllers."
	origin_tech = "powerstorage=1"
	maxcharge = 500
	g_amt = 40
	charge_efficiency = 0.2

/obj/item/weapon/stock_parts/cell/high
	name = "high-capacity power cell"
	origin_tech = "powerstorage=2"
	icon_state = "hcell"
	maxcharge = 10000
	g_amt = 60
	rating = 3
	charge_efficiency = 5

/obj/item/weapon/stock_parts/cell/high/empty
	init_full = FALSE

/obj/item/weapon/stock_parts/cell/super
	name = "super-capacity power cell"
	origin_tech = "powerstorage=5"
	icon_state = "scell"
	maxcharge = 20000
	g_amt = 70
	rating = 4
	charge_efficiency = 13.33

/obj/item/weapon/stock_parts/cell/super/empty
	init_full = FALSE

/obj/item/weapon/stock_parts/cell/hyper
	name = "hyper-capacity power cell"
	origin_tech = "powerstorage=6"
	icon_state = "hpcell"
	maxcharge = 30000
	g_amt = 80
	rating = 5
	charge_efficiency = 23

/obj/item/weapon/stock_parts/cell/hyper/empty
	init_full = FALSE

/obj/item/weapon/stock_parts/cell/bluespace
	name = "bluespace power cell"
	origin_tech = "powerstorage=7"
	icon_state = "bscell"
	maxcharge = 40000
	g_amt = 80
	rating = 6
	charge_efficiency = 46

/obj/item/weapon/stock_parts/cell/bluespace/empty
	init_full = FALSE

/obj/item/weapon/stock_parts/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	origin_tech = null
	maxcharge = 30000
	g_amt = 80
	rating = 6
	charge_efficiency = 80

/obj/item/weapon/stock_parts/cell/infinite/use()
	return 1

/obj/item/weapon/stock_parts/cell/potato
	name = "potato battery"
	desc = "A rechargable starch based power cell."
	origin_tech = "powerstorage=1"
	icon = 'icons/obj/power.dmi'
	icon_state = "potato_cell"
	charge = 100
	maxcharge = 300
	m_amt = 0
	g_amt = 0
	minor_fault = 1
	rating = 1
	charge_efficiency = 0.1

/obj/item/weapon/stock_parts/cell/slime
	name = "charged slime core"
	desc = "A yellow slime core infused with phoron, it crackles with power."
	origin_tech = "powerstorage=2;biotech=4"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "yellow slime extract"
	maxcharge = 10000
	m_amt = 0
	g_amt = 0
	rating = 3
	charge_efficiency = 23
