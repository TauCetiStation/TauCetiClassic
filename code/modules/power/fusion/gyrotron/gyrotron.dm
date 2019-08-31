#define GYRO_POWER 25000

var/list/gyrotrons = list()

/obj/machinery/power/emitter/gyrotron
	name = "gyrotron"
	icon = 'icons/obj/machines/power/fusion.dmi'
	desc = "It is a heavy duty industrial gyrotron suited for powering fusion reactors."
	icon_state = "emitter-off"
	req_access = list(access_engine)
	use_power = IDLE_POWER_USE
	active_power_usage = GYRO_POWER

	var/id_tag
	var/rate = 3
	var/mega_energy = 1

/obj/machinery/power/emitter/gyrotron/atom_init_late()
	..(board_path = /obj/item/weapon/circuitboard/emitter/gyrotron)

/obj/machinery/power/emitter/gyrotron/anchored
	anchored = TRUE
	state = 2

/obj/machinery/power/emitter/gyrotron/atom_init()
	gyrotrons += src
	active_power_usage = mega_energy * GYRO_POWER
	. = ..()

/obj/machinery/power/emitter/gyrotron/Destroy()
	gyrotrons -= src
	return ..()

/obj/machinery/power/emitter/gyrotron/process()
	active_power_usage = mega_energy * GYRO_POWER
	. = ..()

/obj/machinery/power/emitter/gyrotron/get_rand_burst_delay()
	return rate*10

/obj/machinery/power/emitter/gyrotron/get_burst_delay()
	return rate*10

/obj/machinery/power/emitter/gyrotron/get_emitter_beam()
	var/obj/item/projectile/beam/emitter/E = ..()
	E.damage = mega_energy * 50
	return E

/obj/machinery/power/emitter/gyrotron/attackby(obj/item/W, mob/user)
	if(ismultitool(W))
		var/new_ident = sanitize_safe(input("Enter a new ident tag.", "Gyrotron", input_default(id_tag)) as null|text, MAX_LNAME_LEN)
		if(new_ident && user.Adjacent(src))
			id_tag = new_ident
		return
	return ..()

#undef GYRO_POWER
