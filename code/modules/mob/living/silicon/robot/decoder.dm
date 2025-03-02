/obj/item/device/binary_decoder
	name = "binary decoder"
	icon_state = "binary_decoder"
	item_state_world = "binary_decoder_world"
	item_state = "analyzer"
	desc = "Инструмент для прямого чтения и редактирования прошивки электронных устройств."
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 3
	w_class = SIZE_TINY
	throw_speed = 4
	throw_range = 10
	origin_tech = "magnets=1;biotech=1"

/obj/item/device/binary_decoder/proc/print_laws(mob/living/silicon/S)
	playsound(src, 'sound/items/polaroid1.ogg', VOL_EFFECTS_MASTER)
	var/obj/item/weapon/paper/P = new(usr.loc)
	P.fields = 0
	P.name = "Законы [S.name]:"
	P.info = "<tt>[S.write_laws()]</tt>"
	P.updateinfolinks()
	P.update_icon()
	usr.put_in_hands(P)
