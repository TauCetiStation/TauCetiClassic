/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	var/btype = 0 // 0=radio, 1=prox, 2=time

/obj/effect/spawner/newbomb/timer
	btype = 2

/obj/effect/spawner/newbomb/timer/syndicate

/obj/effect/spawner/newbomb/proximity
	btype = 1

/obj/effect/spawner/newbomb/radio
	btype = 0


/obj/effect/spawner/newbomb/atom_init()
	..()

	var/obj/item/device/transfer_valve/V = new(loc)
	var/obj/item/weapon/tank/phoron/PT = new(V)
	var/obj/item/weapon/tank/oxygen/OT = new(V)

	V.tank_one = PT
	V.tank_two = OT

	PT.master = V
	OT.master = V

	PT.air_contents.gas["phoron"] = 12
	PT.air_contents.gas["carbon_dioxide"] = 8
	PT.air_contents.temperature = PHORON_MINIMUM_BURN_TEMPERATURE + 1
	PT.air_contents.update_values()

	OT.air_contents.gas["oxygen"] = 20
	OT.air_contents.temperature = PHORON_MINIMUM_BURN_TEMPERATURE + 1
	OT.air_contents.update_values()

	var/obj/item/device/assembly/S

	switch (btype)
		// radio
		if (0)

			S = new/obj/item/device/assembly/signaler(V)

		// proximity
		if (1)

			S = new/obj/item/device/assembly/prox_sensor(V)

		// timer
		if (2)

			S = new/obj/item/device/assembly/timer(V)


	V.attached_device = S

	S.holder = V
	S.toggle_secure()

	V.update_icon()

	return INITIALIZE_HINT_QDEL
