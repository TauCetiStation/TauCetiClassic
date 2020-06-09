/obj/item/weapon/gun/magic
	name = "staff of nothing"
	desc = "This staff is boring to watch because even though it came first you've seen everything it can do in other staves for years."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	item_state = "staff"
	fire_sound = 'sound/weapons/guns/gunpulse_emitter.ogg'
	flags =  CONDUCT
	slot_flags = SLOT_FLAGS_BACK
	w_class = ITEM_SIZE_LARGE
	var/max_charges = 3
	var/charges = 0
	var/recharge_rate = 14
	var/charge_tick = 0
	var/can_charge = 1
	var/ammo_type = /obj/item/ammo_casing/magic
	var/global_access = FALSE
	origin_tech = null
	action_button_name = null
	clumsy_check = 0
	can_suicide_with = FALSE
	can_be_holstered = FALSE

	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi' //not really a gun and some toys use these inhands
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'

/obj/item/weapon/gun/magic/afterattack(atom/target, mob/user, proximity, params)
	newshot()
	..()

/obj/item/weapon/gun/magic/special_check(mob/M, atom/target)
	var/area/A = get_area(M)
	if(istype(A, /area/custom/wizard_station))
		to_chat(M, "<span class='warning'>You know better than to violate the security of The Den, best wait until you leave to use [src].</span>")
		return FALSE
	if(M.mind.special_role != "Wizard" && !global_access)
		to_chat(M, "<span class='warning'>You have no idea how to use [src].</span>")
		return FALSE
	return TRUE

/obj/item/weapon/gun/magic/examine(mob/user)
	..()
	to_chat(user, "The [name] has [charges] charges.")

/obj/item/weapon/gun/magic/proc/newshot()
	if (charges && chambered)
		chambered.newshot()
		charges--
		charge_tick = 0

/obj/item/weapon/gun/magic/atom_init()
	. = ..()
	charges = max_charges
	chambered = new ammo_type(src)
	if(can_charge)
		START_PROCESSING(SSobj, src)


/obj/item/weapon/gun/magic/Destroy()
	if(can_charge)
		STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/weapon/gun/magic/process()
	charge_tick++
	if(charge_tick < recharge_rate || charges >= max_charges) return 0
	charge_tick = 0
	charges++
	return 1

/obj/item/weapon/gun/magic/update_icon()
	return

/obj/item/weapon/gun/magic/shoot_with_empty_chamber(mob/living/user)
	to_chat(user, "<span class='warning'>The [name] whizzles quietly.</span>")
	return
