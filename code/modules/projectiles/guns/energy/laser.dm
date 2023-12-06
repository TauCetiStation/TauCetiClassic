/obj/item/weapon/gun/energy/laser
	name = "laser rifle"
	desc = "Стандартное оружие, предназначенное для убийства с помощью концентрированных энергетических зарядов."
	icon = 'icons/obj/gun.dmi'
	icon_state = "laser"
	item_state = null	//so the human update icon uses the icon_state instead.
	w_class = SIZE_SMALL
	m_amt = 2000
	origin_tech = "combat=3;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/laser)
	slot_flags = SLOT_FLAGS_BACK
	can_be_holstered = FALSE

/obj/item/weapon/gun/energy/laser/atom_init()
	. = ..()
	if(power_supply)
		power_supply.maxcharge = 1500
		power_supply.charge = 1500

/obj/item/weapon/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "Модифицированная версия стандартной лазерной винтовки, стреляет менее концентрированными энергетическими зарядами, предназначенными для стрельбы по мишеням."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = FALSE

/obj/item/weapon/gun/energy/laser/selfcharging
	name = "selfcharging laser gun"
	var/charge_rate = 30

/obj/item/weapon/gun/energy/laser/selfcharging/atom_init()
	. = ..()
	RegisterSignal(power_supply, COMSIG_CELL_CHARGE_CHANGED, PROC_REF(update_selfrecharger_icon))
	power_supply.AddComponent(/datum/component/cell_selfrecharge, charge_rate)

/obj/item/weapon/gun/energy/laser/selfcharging/proc/update_selfrecharger_icon()
	SIGNAL_HANDLER
	update_icon()

/obj/item/weapon/gun/energy/laser/selfcharging/Destroy()
	UnregisterSignal(power_supply, COMSIG_CELL_CHARGE_CHANGED)
	return ..()

/obj/item/weapon/gun/energy/laser/selfcharging/cyborg
	name = "laser gun"
	desc = "Стандартное оружие, предназначенное для убийства с помощью концентрированных энергетических зарядов."
	icon_state = "laser"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/cyborg)
	cell_type = /obj/item/weapon/stock_parts/cell/secborg

/obj/item/weapon/gun/energy/laser/selfcharging/cyborg/newshot()
	if(!isrobot(loc))
		return FALSE
	if(..())
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			R.cell.use(shot.e_cost)

/obj/item/weapon/gun/energy/laser/selfcharging/captain
	name = "antique laser gun"
	icon_state = "caplaser"
	desc = "Это антикварный лазерный пистолет. Качество исполнения всех его деталей высочайшее. Он украшен элементами из хрома и шкуры ассистента. Буквально излучает энергетику и власть. На нем выгравирована космическая станция 13. И эта станция взрывается."
	force = 10
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = null
	can_be_holstered = TRUE
	charge_rate = 25

/obj/item/weapon/gun/energy/laser/selfcharging/alien
	name = "Alien blaster"
	icon_state = "egun"
	desc = "Оно излучает инопланетную энергетику. Вы не знаете, что это за оружие."
	force = 5
	origin_tech = null
	charge_rate = 50

/obj/item/weapon/gun/energy/laser/scatter
	name = "scatter laser gun"
	icon_state = "oldlaser"
	desc = "Лазерная пушка, оснащенная комплектом преломления, который создает несколько энергетических зарядов."
	can_be_holstered = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/laser/scatter)

/obj/item/weapon/gun/energy/laser/scatter/attack_self(mob/living/user)
	..()
	update_icon()

/obj/item/weapon/gun/energy/laser/scatter/alien
	name = "scatter laser rife"
	icon_state = "subegun"
	desc = "Лазерная пушка, оснащенная комплектом преломления, который создает несколько энергетических зарядов."
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/laser/scatter)
	origin_tech = null

/obj/item/weapon/gun/energy/lasercannon
	name = "laser cannon"
	desc = "В пушке Л.А.З.Е.Р. излучающая среда заключена в трубку с ураном-235 и подвергается воздействию высокого потока нейтронов в активной зоне ядерного реактора. Эта невероятная технология может помочь ВАМ достичь высоких скоростей электронного излучения при малых объемах лазера!"
	icon_state = "lasercannon"
	item_state = null
	origin_tech = "combat=4;materials=3;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/heavy)

	fire_delay = 20

/obj/item/weapon/gun/energy/lasercannon/cyborg/newshot()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost))
				chambered = shot
				chambered.newshot()
	return

/obj/item/weapon/gun/energy/xray
	name = "xray laser gun"
	desc = "Мощное лазерное оружие, способное испускать концентрированные рентгеновские лучи."
	icon_state = "xray"
	item_state = null
	origin_tech = "combat=5;materials=3;magnets=2;syndicate=2"
	ammo_type = list(/obj/item/ammo_casing/energy/xray)

////////Laser Tag////////////////////

/obj/item/weapon/gun/energy/laser/selfcharging/lasertag
	name = "laser tag gun"
	icon_state = "retro"
	desc = "Пистолет для лазертага. Почти как у комиссаров Имперской Гвардии."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/omnitag)
	origin_tech = "combat=1;magnets=2"
	clumsy_check = FALSE
	can_be_holstered = TRUE

	var/lasertag_color = "none"

/obj/item/weapon/gun/energy/laser/selfcharging/lasertag/special_check(mob/living/carbon/human/M)
	if(ishuman(M))
		if(istype(M.wear_suit, /obj/item/clothing/suit/lasertag))
			var/obj/item/clothing/suit/lasertag/L = M.wear_suit
			if(L.lasertag_color == lasertag_color)
				return ..()
		to_chat(M, "<span class='warning'>Вы должны быть одеты в броню для лазертага соответствующего цвета!</span>")
	return FALSE

/obj/item/weapon/gun/energy/laser/selfcharging/lasertag/bluetag
	fire_delay = 5
	icon_state = "bluetag"
	item_state = "l_tag_blue"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)
	lasertag_color = "blue"

/obj/item/weapon/gun/energy/laser/selfcharging/lasertag/redtag
	fire_delay = 5
	icon_state = "redtag"
	item_state = "l_tag_red"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)
	lasertag_color = "red"
