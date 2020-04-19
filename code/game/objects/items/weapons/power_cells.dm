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
	w_class = ITEM_SIZE_NORMAL
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 1000
	m_amt = 700
	g_amt = 50
	var/rigged = 0		// true if rigged to explode
	var/minor_fault = 0 //If not 100% reliable, it will build up faults.

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
	g_amt = 40
	rating = 2

/obj/item/weapon/stock_parts/cell/crap/empty/atom_init()
	. = ..()
	charge = 0

/obj/item/weapon/stock_parts/cell/secborg
	name = "security borg rechargable D battery"
	origin_tech = "powerstorage=1"
	maxcharge = 600	//600 max charge / 100 charge per shot = six shots
	g_amt = 40
	rating = 2.5

/obj/item/weapon/stock_parts/cell/secborg/empty/atom_init()
	. = ..()
	charge = 0

/obj/item/weapon/stock_parts/cell/apc
	name = "APC power cell"
	desc = "A special power cell designed for heavy-duty use in area power controllers."
	origin_tech = "powerstorage=1"
	maxcharge = 500
	g_amt = 40

/obj/item/weapon/stock_parts/cell/high
	name = "high-capacity power cell"
	origin_tech = "powerstorage=2"
	icon_state = "hcell"
	maxcharge = 10000
	g_amt = 60
	rating = 3

/obj/item/weapon/stock_parts/cell/high/empty/atom_init()
	. = ..()
	charge = 0

/obj/item/weapon/stock_parts/cell/super
	name = "super-capacity power cell"
	origin_tech = "powerstorage=5"
	icon_state = "scell"
	maxcharge = 20000
	g_amt = 70
	rating = 4

/obj/item/weapon/stock_parts/cell/super/empty/atom_init()
	. = ..()
	charge = 0

/obj/item/weapon/stock_parts/cell/hyper
	name = "hyper-capacity power cell"
	origin_tech = "powerstorage=6"
	icon_state = "hpcell"
	maxcharge = 30000
	g_amt = 80
	rating = 5

/obj/item/weapon/stock_parts/cell/hyper/empty/atom_init()
	. = ..()
	charge = 0

/obj/item/weapon/stock_parts/cell/bluespace
	name = "bluespace power cell"
	origin_tech = "powerstorage=7"
	icon_state = "bscell"
	maxcharge = 40000
	g_amt = 80
	rating = 6
	//chargerate = 4000

/obj/item/weapon/stock_parts/cell/bluespace/empty/atom_init()
	. = ..()
	charge = 0

/obj/item/weapon/stock_parts/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	origin_tech =  null
	maxcharge = 30000
	g_amt = 80
	rating = 6

/obj/item/weapon/stock_parts/cell/infinite/use()
	return 1

/obj/item/weapon/stock_parts/cell/potato
	name = "potato battery"
	desc = "A rechargable starch based power cell."
	origin_tech = "powerstorage=1"
	icon = 'icons/obj/power.dmi' //'icons/obj/hydroponics/harvest.dmi'
	icon_state = "potato_cell" //"potato_battery"
	charge = 100
	maxcharge = 300
	m_amt = 0
	g_amt = 0
	minor_fault = 1
	rating = 1

/obj/item/weapon/stock_parts/cell/slime
	name = "charged slime core"
	desc = "A yellow slime core infused with phoron, it crackles with power."
	origin_tech = "powerstorage=2;biotech=4"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "yellow slime extract"
	maxcharge = 10000
	maxcharge = 10000
	m_amt = 0
	g_amt = 0
	rating = 3
