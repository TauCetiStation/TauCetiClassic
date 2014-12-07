/obj/item/spacecraft_parts
	name = "spacecraft part"
	icon = 'tauceti/modules/_spacecraft/spacecraft_parts.dmi'
	icon_state = "blank"
	w_class = 5
	flags = FPRINT | TABLEPASS | CONDUCT
	origin_tech = "programming=2;materials=2"
	var/construction_time = 100
	var/list/construction_cost = list("metal"=20000,"glass"=5000)



/obj/item/spacecraft_parts/engine
	name = "Starfarer MKIII"
	icon_state = "engine1"
	w_class = 4
	var/max_speed = 2 //ћаксимальна€ скорость на которую способен двигатель
	var/min_speed = 6
	var/fuel_drain = 1
	var/oxidiser_drain = 1.2
	var/power_drain = 8
	var/max_heat_capacity = 500 // сколько темпла может держать в себе движок без поломки
	var/cur_heat_capacity = 0
	var/max_health = 100
	health = 100
	var/heating = 5 //сколько тепла производит за шаг
	var/obj/item/weapon/reagent_containers/spacecraft_tank/fuel/fuel_tank = null
	var/obj/item/weapon/reagent_containers/spacecraft_tank/oxidiser/oxidiser_tank = null

/obj/item/spacecraft_parts/engine/New()
	..()
	fuel_tank = new /obj/item/weapon/reagent_containers/spacecraft_tank/fuel(src)
	oxidiser_tank = new /obj/item/weapon/reagent_containers/spacecraft_tank/oxidiser(src)
	return



/obj/item/weapon/reagent_containers/spacecraft_tank
	name = "spacecraft tank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"
	w_class = 3.0
	amount_per_transfer_from_this = 20
	volume = 100
	var/reagent_type = ""

/obj/item/weapon/reagent_containers/spacecraft_tank/fuel
	volume = 1000
	reagent_type = "hydrogen"

/obj/item/weapon/reagent_containers/spacecraft_tank/fuel/New()
	..()
	reagents.add_reagent(reagent_type, 1000)

/obj/item/weapon/reagent_containers/spacecraft_tank/oxidiser
	volume = 1200
	reagent_type = "oxygen"

/obj/item/weapon/reagent_containers/spacecraft_tank/oxidiser/New()
	..()
	reagents.add_reagent(reagent_type, 1200)