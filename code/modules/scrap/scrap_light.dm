/obj/item/device/flashlight/flare/torch
	name = "torch"
	desc = "A torch fashioned from some rags and a plank."
	w_class = 3
	icon_state = "torch"
	item_state = "torch"
	light_color = "#E25822"
	on_damage = 10
	slot_flags = null
	action_button_name = null

/obj/item/device/flashlight/flare/torch/attackby(obj/item/W, mob/user, params) // ravioli ravioli here comes stupid copypastoli
	..()
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.isOn()) //Badasses dont get blinded by lighting their candle with a welding tool
			light(user)
	else if(istype(W, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = W
		if(L.lit)
			light(user)
	else if(istype(W, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = W
		if(M.lit)
			light(user)
	else if(istype(W, /obj/item/device/flashlight/flare/torch))
		var/obj/item/device/flashlight/flare/torch/M = W
		if(M.on)
			light(user)
	else if(istype(W, /obj/item/candle))
		var/obj/item/candle/C = W
		if(C.lit)
			light(user)

/obj/item/device/flashlight/flare/torch/proc/light(mob/user)
	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='notice'>It's out of fuel.</span>")
		return
	if(on)
		return
	user.visible_message("<span class='notice'>[user] lits the [src] on.</span>", "<span class='notice'>You had lt on the [src]!</span>")
	src.force = on_damage
	src.damtype = "fire"
	on = !on
	update_brightness(user)
	item_state = icon_state
	if(user.hand && loc == user)
		user.update_inv_r_hand()
	else
		user.update_inv_l_hand()
	START_PROCESSING(SSobj, src)

/obj/item/device/flashlight/flare/torch/attack_self()
	return

/obj/item/stack/sheet/wood/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/medical/bruise_pack/rags))
		use(1)
		new /obj/item/device/flashlight/flare/torch(get_turf(user))
		qdel(W)
	..()

/obj/item/stack/medical/bruise_pack/rags
	name = "rags"
	singular_name = "rag"
	desc = "Some rags. May infect your wounds."
	amount = 1
	max_amount = 1
	icon = 'icons/obj/items.dmi'
	icon_state = "gauze"

/obj/item/stack/medical/bruise_pack/rags/New(var/newloc, old = 0)
	..()
	if(prob(33) || old)
		make_old()
