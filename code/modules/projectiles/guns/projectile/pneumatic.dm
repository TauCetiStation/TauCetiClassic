#define PNEUMATIC_SPEED_CAP 40
#define PNEUMATIC_SPEED_DIVISOR 800

/obj/item/weapon/storage/pneumatic
	name = "pneumatic cannon"
	desc = "Пушка высокого давления."
	icon = 'icons/obj/gun.dmi'
	icon_state = "pneumatic"
	item_state = "pneumatic"
	w_class = SIZE_BIG
	flags =  CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	max_w_class = SIZE_SMALL
	storage_slots = 7

	var/obj/item/weapon/tank/tank = null                // Tank of gas for use in firing the cannon.
	var/obj/item/weapon/storage/tank_container          // Something to hold the tank item so we don't accidentally fire it.
	var/pressure_setting = 10                           // Percentage of the gas in the tank used to fire the projectile.
	var/possible_pressure_amounts = list(5,10,20,25,50) // Possible pressure settings.
	var/minimum_tank_pressure = 10                      // Minimum pressure to fire the gun.
	var/cooldown = 0                                    // Whether or not we're cooling down.
	var/cooldown_time = 50                              // Time between shots.

/obj/item/weapon/storage/pneumatic/atom_init()
	. = ..()
	tank_container = new()

/obj/item/weapon/storage/pneumatic/verb/set_pressure() //set amount of tank pressure.

	set name = "Установить желаемое давление"
	set category = "Object"
	set src in range(0)
	var/N = input("Сколько % давления использовать для выстрела:","[src]") as null|anything in possible_pressure_amounts
	if (N)
		pressure_setting = N
		to_chat(usr, "Вы крутите вентиль до [pressure_setting]%.")

/obj/item/weapon/storage/pneumatic/verb/eject_tank() //Remove the tank.

	set name = "Вытащить баллон"
	set category = "Object"
	set src in range(0)

	if(tank)
		to_chat(usr, "Вы поворачиваете вентиль и откручиваете баллон.")
		tank.loc = usr.loc
		tank = null
		icon_state = "pneumatic"
		item_state = "pneumatic"
		usr.update_icons()
	else
		to_chat(usr, "Нет баллона.")

/obj/item/weapon/storage/pneumatic/attackby(obj/item/I, mob/user, params)
	if(!tank && istype(I, /obj/item/weapon/tank))
		user.remove_from_mob(I)
		tank = I
		tank.loc = src.tank_container
		user.visible_message("[user] прикручивает баллон к пневматической пушке.","Вы прикручиваете баллон к пневматической пушке.")
		icon_state = "pneumatic-tank"
		item_state = "pneumatic-tank"
		user.update_icons()
	else
		return ..()

/obj/item/weapon/storage/pneumatic/examine(mob/user)
	..()
	if(src in view(2, user))
		to_chat(user, "Вентиль установлен на [pressure_setting]%.")
		if(tank)
			to_chat(user, "На манометре баллона [tank.air_contents.return_pressure()] кПа.")
		else
			to_chat(user, "Нет газового баллона!")

/obj/item/weapon/storage/pneumatic/afterattack(atom/target, mob/user, proximity, params)
	if (target.loc == user.loc)
		return
	else if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if (length(contents) == 0)
		to_chat(user, "Загрузите предмет для выстрела!")
		return 0
	else
		spawn(0) Fire(target,user,params)

/obj/item/weapon/storage/pneumatic/attack(mob/living/M, mob/living/user, def_zone)
	if (length(contents) > 0)
		if(user.a_intent == INTENT_HARM)
			user.visible_message("<span class='warning'><b> [user] стреляет в упор по [M] из пневматической пушки!</b></span>")
			Fire(M,user)
			return
		else
			Fire(M,user)
			return

/obj/item/weapon/storage/pneumatic/proc/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/V = H.wear_suit
			V.attack_reaction(H, REACTION_GUN_FIRE)

	if (!tank)
		to_chat(user, "Вставьте газовый баллон!")
		return 0

	if (cooldown)
		to_chat(user, "Низкое давление на манометре!")
		return 0

	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	var/fire_pressure = (tank.air_contents.return_pressure()/100)*pressure_setting

	if (fire_pressure < minimum_tank_pressure)
		to_chat(user, "Давления в баллоне недостаточно для выстрела.")
		return 0

	var/obj/item/object = contents[1]
	var/speed = min(PNEUMATIC_SPEED_CAP, ((fire_pressure*tank.volume)/object.w_class)/PNEUMATIC_SPEED_DIVISOR) //projectile speed.

	playsound(src, 'sound/weapons/guns/gunshot_pneumaticgun.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -2)
	user.visible_message("<span class='danger'>[user] fires [src] and launches [object] at [target]!</span>","<span class='danger'>You fire [src] and launch [object] at [target]!</span>")

	remove_from_storage(object,user.loc)
	object.throw_at(target, speed + 1, speed, user)

	var/lost_gas_amount = tank.air_contents.total_moles*(pressure_setting/100)
	var/datum/gas_mixture/removed = tank.air_contents.remove(lost_gas_amount)
	user.loc.assume_air(removed)

	cooldown = 1
	spawn(cooldown_time)
		cooldown = 0
		to_chat(user, "Манометр показывает достаточное давление для выстрела.")

/obj/item/weapon/storage/pneumatic/Destroy()
	QDEL_NULL(tank)
	QDEL_NULL(tank_container)
	return ..()

// *(PNEUMATOIC GUN craft in recipes.dm)*

/obj/item/weapon/cannonframe1
	name = "pneumo-gun(1 stage)"
	desc = "Для завершения сборки: вставьте и приварите трубу; добавьте и приварите 5 листов металла; прикрутите вентиль и заварите швы."
	icon_state = "pneumaticframe1"
	item_state = "pneumatic"

/obj/item/weapon/cannonframe2
	name = "pneumo-gun(2 stage)"
	desc = "Для завершения сборки: приварите трубу; добавьте и приварите 5 листов металла; прикрутите вентиль и заварите швы."
	icon_state = "pneumaticframe2"
	item_state = "pneumatic"

/obj/item/weapon/cannonframe3
	name = "pneumo-gun(3 stage)"
	desc = "Для завершения сборки: добавьте и приварите 5 листов металла; прикрутите вентиль и заварите швы."
	icon_state = "pneumaticframe3"
	item_state = "pneumatic"

/obj/item/weapon/cannonframe4
	name = "pneumo-gun(4 stage)"
	desc = "Для завершения сборки: приварите металл; прикрутите вентиль и заварите швы."
	icon_state = "pneumaticframe4"
	item_state = "pneumatic"

/obj/item/weapon/cannonframe5
	name = "pneumo-gun(5 stage)"
	desc = "Для завершения сборки: прикрутите вентиль и заварите швы."
	icon_state = "pneumaticframe5"
	item_state = "pneumatic"

/obj/item/weapon/cannonframe6
	name = "pneumo-gun(6 stage)"
	desc = "Для завершения сборки: заварите швы."
	icon_state = "pneumaticframe6"
	item_state = "pneumatic"

#undef PNEUMATIC_SPEED_CAP
#undef PNEUMATIC_SPEED_DIVISOR
