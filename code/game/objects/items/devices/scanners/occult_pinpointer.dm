
var/global/list/ancestor_wisps = list()

/mob/living/simple_animal/ancestor_wisp
    New()
        ..()
        ancestor_wisps += src

    Destroy()
        ancestor_wisps -= src
        return ..()

/obj/item/weapon/occult_pinpointer
    name = "occult locator"
    icon = 'icons/obj/device.dmi'
    icon_state = "locoff"
    flags = CONDUCT
    slot_flags = SLOT_FLAGS_BELT
    w_class = SIZE_TINY
    item_state = "electronic"
    throw_speed = 4
    throw_range = 20
    m_amt = 500
    var/target = null
    var/target_type = /obj/item/weapon/reagent_containers/food/snacks/ectoplasm // Проверьте путь!
    var/active = FALSE

    // Процедура активации/деактивации
    attack_self(mob/user)
        if(!active)
            to_chat(user, "<span class='notice'>You activate the [name]</span>")
            START_PROCESSING(SSobj, src)
            active = TRUE
        else
            icon_state = "locoff"
            target = null
            to_chat(user, "<span class='notice'>You deactivate the [name]</span>")
            STOP_PROCESSING(SSobj, src)
            active = FALSE

    // Взаимодействие с Occult Scanner
    attackby(obj/item/I, mob/user, params)
        if(istype(I, /obj/item/device/occult_scanner))
            var/obj/item/device/occult_scanner/OS = I
            if(OS.scanned_type) // Убедитесь, что scanned_type существует
                target_type = OS.scanned_type
                target = null
                to_chat(user, "<span class='notice'>[src] extracted knowledge from [I].</span>")
        else
            return ..()

    // Обработка уничтожения
    Destroy()
        active = FALSE
        STOP_PROCESSING(SSobj, src)
        target = null
        return ..()

    // Логика работы
    process()
        if(!active)
            return

        if(!target)
            if(length(ancestor_wisps))
                target = pick(ancestor_wisps)
                message_admins("Target set: [target]")
            else
                target = locate(target_type) // Ищем объект, если виспов нет

        if(!target)
            icon_state = "locnull"
            return

        set_dir(get_dir(src, target))
        icon_state = (get_dist(src, target) > 0) ? "locon" : "locoff"
