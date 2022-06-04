/obj/item/gun_modular/module/chamber
    name = "патронник"
    module_id = CHAMBER_MODULE

/obj/item/gun_modular/module/chamber/activate(datum/process_fire/process)

    var/obj/item/projectile/chambered = send_signal_module(process, GET_AMMO)

    if(!chambered)
        process.SetData(ACTIVE_FIRE, FALSE)

    return ..()