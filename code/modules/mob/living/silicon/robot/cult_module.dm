//We get unique variant of broken module
/datum/robot_component/actuator/cult/destroy()
	if(wrapped)
		qdel(wrapped)

	wrapped = new/obj/item/broken_device/cult_heart

	// The thing itself isn't there anymore, but some fried remains are.
	installed = -1
	uninstall()

//Unique variant of actuator that allows us to use cult tome and can be repaired even after full destruction
/datum/robot_component/actuator/cult
	name = "artifical heart"
	idle_usage = 13
	active_usage = 80
	external_type = /obj/item/robot_parts/robot_component/actuator/cult
	max_damage = 99

/obj/item/robot_parts/robot_component/actuator/cult
	name = "artifical heart"
	icon_state = "motor_cult"
	icon_state_broken = "motor_cult_broken"

//Broken variant
/obj/item/broken_device/cult_heart
	name = "broken artifical heart"
	icon_state = "motor_cult_broken"

/obj/item/broken_device/cult_heart/attacked_by(obj/item/attacking_item, mob/living/user, def_zone, power)
	. = ..()
	if(istype(attacking_item, /obj/item/weapon/storage/bible/tome))
		if(!iscultist(user))
			return
		playsound(user, 'sound/effects/Heart Beat.ogg', VOL_EFFECTS_MASTER)
		var/obj/item/robot_parts/robot_component/actuator/cult/A = new()
		A.brute = 50
		A.burn = 35
		var/old_loc = loc
		qdel(src)
		forceMove(old_loc)
		var/static/list/waddle_angles = list(-28, -14, 0, 14, 28)
		waddle(pick(waddle_angles), 0)

/obj/item/robot_parts/robot_component/actuator/cult/attacked_by(obj/item/attacking_item, mob/living/user, def_zone, power)
	. = ..()
	if(istype(attacking_item, /obj/item/weapon/storage/bible/tome))
		if(!iscultist(user))
			return
		if(brute + burn < 1)
			to_chat(user, "<span class='notice'>[src] has no need in repairing!</span>")
			return
		brute -= 10
		burn -= 10
		if(brute + burn < 1)
			to_chat(user, "<span class='notice'>[src] fully repaired!</span>")
			playsound(user, 'sound/effects/Heart Beat.ogg', VOL_EFFECTS_MASTER)
		var/static/list/waddle_angles = list(-28, -14, 0, 14, 28)
		waddle(pick(waddle_angles), 0)

/obj/item/weapon/storage/bible/tome/cyborg
	name = "strange book"
	icon_state = "strange_book"
	build_cd = 60 SECONDS
	rune_cd = 12 SECONDS
	scribe_time = 2 SECONDS
	cost_coef = 2
	flags = NODROP

/obj/item/weapon/storage/bible/tome/cyborg/attack_self(mob/user)
	if(!isrobot(user))
		CRASH("Предмет для киборгов оказался в руках не-киборга [loc]!")
	if(!religion && user.my_religion)
		religion = user.my_religion
	var/mob/living/silicon/robot/R = user
	if(!istype(R.components["actuator"], /datum/robot_component/actuator/cult))
		to_chat(user, "<span class='notice'>Внимание! Не обнаружено необходимого аппаратного обеспечения для взаимодействия с данным оборудованием!</span>")
		playsound(src, 'sound/machines/roboboop.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
		return
	var/datum/robot_component/actuator/cult/A = R.components["actuator"]
	var/obj/item/robot_parts/robot_component/actuator/cult/C = A.wrapped
	if(!C) //Just in case
		to_chat(user, "<span class='notice'>Внимание! Компонент \"Сердце\" не исправно. Обратитесь в сервисный центр!</span>")
		playsound(src, 'sound/machines/roboboop.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
		return
	if(C.brute + C.burn > 75)
		to_chat(user, "<span class='notice'>[pick("Ваше С5рдЦ5", "Моё сердце")] слишком повреждено, что бы использовать данный ко-мПон5нт!</span>") //Lemee play a theatre that a cyborg can feel emotions with heart
		playsound(src, 'sound/machines/roboboop.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
		return
	. = ..()

/mob/living/silicon/robot/cultist
/mob/living/silicon/robot/cultist/atom_init(mapload, name_prefix, laws_type, ai_link, datum/religion/R)
	. = ..()
	build_cultist_borg()

/mob/living/silicon/robot/cultist/LateLogin()
	. = ..()
	if(iscultist(src))
		return
	if(global.cult_religion)
		global.cult_religion.add_member(src, CULT_ROLE_HIGHPRIEST)
	else
		create_faction(/datum/faction/cult, FALSE, FALSE)
		global.cult_religion.add_member(src, CULT_ROLE_HIGHPRIEST)// religion was created in faction
