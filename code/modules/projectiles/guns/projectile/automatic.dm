/obj/item/weapon/gun/projectile/automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
	name = "submachine gun"
	desc = "Легкий, скорострельный пистолет-пулемёт. Использует патроны калибра 9мм."
	icon_state = "saber"
	item_state = null
	w_class = SIZE_SMALL
	origin_tech = "combat=4;materials=2"
	initial_mag = /obj/item/ammo_box/magazine/smg
	has_ammo_counter = TRUE
	can_be_holstered = FALSE
	var/alarmed = FALSE
	var/should_alarm_when_empty = FALSE
	var/can_be_silenced = FALSE

/obj/item/weapon/gun/projectile/automatic/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"
	if(!item_state)
		item_state = "[initial(icon_state)]"
	cut_overlays()
	if(magazine && magazine.overlay)
		var/image/magazine_icon = image('icons/obj/gun.dmi', "[magazine.overlay]")
		add_overlay(magazine_icon)
	if(silenced)
		var/image/silencer_icon = image('icons/obj/gun_40x32.dmi', "[initial(icon_state)]-silencer")
		add_overlay(silencer_icon)

/obj/item/weapon/gun/projectile/automatic/attackby(obj/item/I, mob/user, params)
	if(..() && chambered)
		alarmed = FALSE

/obj/item/weapon/gun/projectile/automatic/afterattack(atom/target, mob/user, proximity, params)
	..()
	if(!chambered && !get_ammo() && !alarmed && should_alarm_when_empty)
		playsound(user, 'sound/weapons/guns/empty_alarm.ogg', VOL_EFFECTS_MASTER, 40)
		update_icon()
		alarmed = TRUE

/obj/item/weapon/gun/projectile/automatic/attack_hand(mob/user)
	if(loc == user && silenced && can_be_silenced && remove_silencer(user))
		return
	..()

/obj/item/weapon/gun/projectile/automatic/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/silencer))
		return install_silencer(I, user, params)
	return ..()

/obj/item/weapon/gun/projectile/automatic/mini_uzi
	name = "Mac-10"
	desc = "Легкий и скорострельный пистолет-пулемёт для тех случаев, когда нужно кого-то быстро убить. Использует патроны калибра 9мм."
	icon_state = "mac"
	item_state = "mac"
	w_class = SIZE_SMALL
	can_be_holstered = TRUE
	origin_tech = "combat=5;materials=2;syndicate=8"
	initial_mag = /obj/item/ammo_box/magazine/mac10
	can_be_silenced = TRUE

/obj/item/weapon/gun/projectile/automatic/c20r
	name = "C-20r SMG"
	desc = "Легкий компактный пистолет-пулемет типа булл-пап. Использует патроны .45 ACP в магазинах средней емкости и имеет нарезной ствол для установки глушителя. На прикладе виднеется клеймо: blahblahblah ."
	icon_state = "c20r"
	item_state = "c20r"
	w_class = SIZE_SMALL
	origin_tech = "combat=5;materials=2;syndicate=8"
	initial_mag = /obj/item/ammo_box/magazine/c20r
	suitable_mags = list(/obj/item/ammo_box/magazine/c20r, /obj/item/ammo_box/magazine/c20r/hp, /obj/item/ammo_box/magazine/c20r/hv, /obj/item/ammo_box/magazine/c20r/imp)
	fire_sound = 'sound/weapons/guns/gunshot_light.ogg'
	should_alarm_when_empty = TRUE
	can_be_silenced = TRUE
	has_ammo_counter = TRUE

/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "L6 SAW"
	desc = "Сильно модифицированный легкий пулемет с тактической рамкой из пластали, опирающейся на довольно традиционную баллистическую систему. На ствольной коробке выгравировано 'Оружейная мастерская Aussec - 2531', кроме того используются патроны '7.62x51мм' ."
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = SIZE_BIG
	origin_tech = "combat=5;materials=1;syndicate=2"
	initial_mag = /obj/item/ammo_box/magazine/saw
	fire_sound = 'sound/weapons/guns/Gunshot2.ogg'
	has_cover = TRUE
	two_hand_weapon = ONLY_TWOHAND
	has_ammo_counter = TRUE

/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? CEIL(get_ammo(0) / 12.5) * 25 : "-empty"]"
	item_state = "l6[cover_open ? "open" : "closed"][magazine ? "mag" : "nomag"]"

/obj/item/weapon/gun/projectile/automatic/l6_saw/afterattack(atom/target, mob/user, proximity, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		to_chat(user, "<span class='notice'>Крышка [src] открыта! Закройте ее перед стрельбой!</span>")
	else
		..()
		update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_hand(mob/user)
	if(loc != user)
		return ..()//let them pick it up
	if(user.get_inactive_hand() != src)
		return ..()//let them take it from inventory
	if(!cover_open)
		cover_open = !cover_open
		to_chat(user, "<span class='notice'>Вы открыли крышку [src].</span>")
		update_icon()
	else if(cover_open && magazine)
		//drop the mag
		magazine.update_icon()
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		playsound(src, 'sound/weapons/guns/reload_mag_out.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>Вы вытащили магазин из [src].</span>")
	else
		if(chambered)
			playsound(src, bolt_slide_sound, VOL_EFFECTS_MASTER)
			process_chamber()


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(obj/item/I, mob/user, params)
	if(!cover_open)
		to_chat(user, "<span class='notice'> Крышка [src] закрыта! Вы не можете вставить новый магазин!</span>")
		return
	return ..()

/obj/item/weapon/gun/projectile/automatic/l13
	name = "security submachine gun"
	desc = "Индивидуальное оружие самообороны 'L13', предназначенное для контртеррористических операций. Использует .38 калибр."
	icon_state = "l13"
	item_state = "l13"
	w_class = SIZE_SMALL
	origin_tech = "combat=4;materials=2"
	initial_mag = /obj/item/ammo_box/magazine/l13
	suitable_mags = list(/obj/item/ammo_box/magazine/l13, /obj/item/ammo_box/magazine/l13/lethal)
	fire_sound = 'sound/weapons/guns/gunshot_l13.ogg'
	can_be_silenced = TRUE

/obj/item/weapon/gun/projectile/automatic/tommygun
	name = "tommy gun"
	desc = "Подлинная 'Чикагская пишущая машинка'."
	icon_state = "tommygun"
	item_state = "tommygun"
	w_class = SIZE_BIG
	two_hand_weapon = DESIRABLE_TWOHAND
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	initial_mag = /obj/item/ammo_box/magazine/tommygun
	fire_sound = 'sound/weapons/guns/gunshot_light.ogg'
	can_be_silenced = TRUE

/obj/item/weapon/gun/projectile/automatic/bar
	name = "Browning M1918"
	desc = "Автоматическая винтовка Браунинга"
	icon_state = "bar"
	item_state = "bar"
	w_class = SIZE_BIG
	two_hand_weapon = DESIRABLE_TWOHAND
	origin_tech = "combat=5;materials=2"
	initial_mag = /obj/item/ammo_box/magazine/bar
	fire_sound = 'sound/weapons/guns/Gunshot2.ogg'

/obj/item/weapon/gun/projectile/automatic/borg
	name = "Robot SMG"
	icon_state = "borg_smg"
	initial_mag = /obj/item/ammo_box/magazine/borg45
	fire_sound = 'sound/weapons/guns/gunshot_medium.ogg'
	has_ammo_counter = TRUE

/obj/item/weapon/gun/projectile/automatic/borg/update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/borg/attack_self(mob/user)
	if (magazine)
		magazine.loc = get_turf(src.loc)
		magazine.update_icon()
		magazine = null
		playsound(src, 'sound/weapons/guns/reload_mag_out.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>Вы вытаскиваете магазин из [src]!</span>")
	else
		to_chat(user, "<span class='notice'>Внутри [src] нет обоймы.</span>")
	return

/obj/item/weapon/gun/projectile/automatic/bulldog
	name = "V15 Bulldog shotgun"
	desc = "Малогабаритный самозарядный полуавтоматический дробовик для ведения огня в узких коридорах. Совместим лишь со специальными магазинами."
	icon_state = "bulldog"
	item_state = "bulldog"
	w_class = SIZE_SMALL
	origin_tech = "combat=5;materials=4;syndicate=6"
	initial_mag = /obj/item/ammo_box/magazine/bulldog
	fire_sound = 'sound/weapons/guns/gunshot_shotgun.ogg'
	suitable_mags = list(/obj/item/ammo_box/magazine/bulldog, /obj/item/ammo_box/magazine/bulldog/stun, /obj/item/ammo_box/magazine/bulldog/incendiary)
	should_alarm_when_empty = TRUE

/obj/item/weapon/gun/projectile/automatic/a28
	name = "A28 assault rifle"
	desc = "Автоматическая винтовка типа булл-пап с воздушным охлаждением, используемая военным корпусом пехоты НаноТрейзен. На ствольной коробке выгравировано - 'Сэр, я заканчиваю этот бой'. Использует патроны калибром 5.56мм."
	icon_state = "a28"
	item_state = "a28"
	w_class = SIZE_SMALL
	two_hand_weapon = DESIRABLE_TWOHAND
	origin_tech = "combat=5;materials=4;syndicate=6"
	initial_mag = /obj/item/ammo_box/magazine/a28
	suitable_mags = list(/obj/item/ammo_box/magazine/a28, /obj/item/ammo_box/magazine/a28/nonlethal, /obj/item/ammo_box/magazine/a28/incendiary)
	fire_sound = 'sound/weapons/guns/gunshot_medium.ogg'

/obj/item/weapon/gun/projectile/automatic/a74
	name = "A74 assault rifle"
	desc = "Stradi and Practican Maid Bai Spess soviets corporation, bazed he original design of 20 centuriyu fin about baars and vodka vile patrimonial it, saunds of balalaika place minvile, yuzes 7.74 caliber"
	initial_mag = /obj/item/ammo_box/magazine/a74
	suitable_mags = list(/obj/item/ammo_box/magazine/a74, /obj/item/ammo_box/magazine/a74/krinkov)
	w_class = SIZE_SMALL
	two_hand_weapon = DESIRABLE_TWOHAND
	icon_state = "a74"
	item_state = "a74"
	origin_tech = "combat=5;materials=4;syndicate=6"
	fire_sound = 'sound/weapons/guns/gunshot_ak74.ogg'

/obj/item/weapon/gun/projectile/automatic/a74/krinkov
	name = "Krinkov"
	desc = "Маленький и смертоносный A74U легче своего старшего брата, но, тем не менее, обладает серьезной мощью."
	initial_mag = /obj/item/ammo_box/magazine/a74/krinkov
	recoil = 1.5
	two_hand_weapon = FALSE
	icon_state = "krinkov"
	item_state = "krinkov"

/obj/item/weapon/gun/projectile/automatic/drozd
	name = "OTs-114 assault rifle"
	desc = "Известный также как Дрозд, этот маленький сукин сын оснащен чертовым гранатометом! Как же это круто!"
	icon_state = "drozd"
	item_state = "drozd"
	initial_mag = /obj/item/ammo_box/magazine/drozd
	w_class = SIZE_SMALL
	two_hand_weapon = DESIRABLE_TWOHAND
	fire_sound = 'sound/weapons/guns/gunshot_drozd.ogg'
	fire_delay = 7
	var/using_gl = FALSE
	var/obj/item/weapon/gun/projectile/grenade_launcher/underslung/gl
	item_action_types = list(/datum/action/item_action/hands_free/toggle_gl)

/datum/action/item_action/hands_free/toggle_gl
	name = "Toggle GL"

/datum/action/item_action/hands_free/toggle_gl/Activate()
	var/obj/item/weapon/gun/projectile/automatic/drozd/S = target
	S.toggle_gl(usr)

/obj/item/weapon/gun/projectile/automatic/drozd/examine(mob/user)
	. = ..()
	to_chat(user, "It's [gl.name] is [gl.get_ammo() ? "loaded" : "unloaded"].")

/obj/item/weapon/gun/projectile/automatic/drozd/proc/toggle_gl(mob/user)
	using_gl = !using_gl
	if(using_gl)
		user.visible_message("<span class='warning'>[user] щелкает маленький переключатель, активируя [gl]!</span>",\
		"<span class='warning'>Вы активируете ваш [gl].</span>",\
		"You hear an ominous click.")
	else
		user.visible_message("<span class='notice'>[user] щелкает маленьким переключателем, принимая решение прекратить все взрывать.</span>",\
		"<span class='notice'>Вы деактивируете ваш [gl].</span>",\
		"You hear a click.")
	playsound(src, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)
	update_icon()

/obj/item/weapon/gun/projectile/automatic/drozd/atom_init()
	. = ..()
	gl = new (src)

/obj/item/weapon/gun/projectile/automatic/drozd/update_icon()
	..()
	if(using_gl)
		var/image/gl = image('icons/obj/gun.dmi', "drozd-gl")
		add_overlay(gl)

/obj/item/weapon/gun/projectile/automatic/drozd/afterattack(atom/target, mob/user, proximity, params)
	if(!using_gl)
		return ..()
	gl.afterattack(target, user, proximity, params)

/obj/item/weapon/gun/projectile/automatic/drozd/attackby(obj/item/I, mob/user, params)
	if(!using_gl)
		return ..()
	gl.attackby(I, user)

/obj/item/weapon/gun/projectile/automatic/drozd/attack_self(mob/user)
	if(!using_gl)
		return ..()
	gl.attack_self(user)

/obj/item/weapon/gun/projectile/automatic/m41a
	name = "M41A pulse rifle"
	desc = "Импульсная винтовка М41А, принятая на вооружение в КМП НТ. Малая поражающая способность с лихвой компенсируется количеством свинца, выпускаемого по противнику. Использует безгильзовые патроны 10х24 мм."
	icon_state = "pulserifle"
	item_state = "pulserifle"
	fire_sound = 'sound/weapons/guns/gunshot_m41.ogg'
	initial_mag = /obj/item/ammo_box/magazine/m41a
	w_class = SIZE_SMALL
	two_hand_weapon = DESIRABLE_TWOHAND
	fire_delay = 1

/obj/item/weapon/gun/projectile/automatic/m41a/process_chamber()
	return ..(1, 1, 1)

/obj/item/weapon/gun/projectile/automatic/m41a/launcher
	desc = "\"Я хочу познакомить тебя со своим другом. Это - импульсная винтовка М41, десять миллиметров, здесь и здесь есть тридцатимиллиметровый гранатомет. Держи.\""
	icon_state = "pulseriflegl"
	var/using_gl = FALSE
	var/obj/item/weapon/gun/projectile/grenade_launcher/underslung/marines/launcher
	item_action_types = list(/datum/action/item_action/hands_free/toggle_gl_m41)

/datum/action/item_action/hands_free/toggle_gl_m41
	name = "Toggle GL"

/datum/action/item_action/hands_free/toggle_gl_m41/Activate()
	var/obj/item/weapon/gun/projectile/automatic/m41a/launcher/S = target
	S.toggle_gl(usr)

/obj/item/weapon/gun/projectile/automatic/m41a/launcher/examine(mob/user)
	. = ..()
	to_chat(user, "It's [launcher.name] is [launcher.get_ammo() ? "loaded" : "unloaded"].")

/obj/item/weapon/gun/projectile/automatic/m41a/launcher/proc/toggle_gl(mob/user)
	using_gl = !using_gl
	if(using_gl)
		user.visible_message("<span class='warning'>[user] presses a button, activating their [launcher]!</span>",\
		"<span class='warning'>You activate your [launcher].</span>",\
		"You hear an ominous click.")
	else
		user.visible_message("<span class='notice'>[user] presses a button, deciding to stop the bombings.</span>",\
		"<span class='notice'>You deactivate your [launcher].</span>",\
		"You hear a click.")
	playsound(src, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)
	update_icon()

/obj/item/weapon/gun/projectile/automatic/m41a/launcher/atom_init()
	. = ..()
	launcher = new (src)

/obj/item/weapon/gun/projectile/automatic/m41a/launcher/update_icon()
	..()
	if(using_gl)
		var/image/gl = image('icons/obj/gun.dmi', "pulseriflegl1")
		add_overlay(gl)

/obj/item/weapon/gun/projectile/automatic/m41a/launcher/afterattack(atom/target, mob/user, proximity, params)
	if(!using_gl)
		return ..()
	launcher.afterattack(target, user, proximity, params)

/obj/item/weapon/gun/projectile/automatic/m41a/launcher/attackby(obj/item/I, mob/user, params)
	if(!using_gl)
		return ..()
	launcher.attackby(I, user)

/obj/item/weapon/gun/projectile/automatic/m41a/launcher/attack_self(mob/user)
	if(!using_gl)
		return ..()
	launcher.attack_self(user)
