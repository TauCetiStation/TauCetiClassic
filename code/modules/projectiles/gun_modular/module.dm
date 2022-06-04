/obj/item/gun_modular/module
    name = "gun module"
    var/module_id = "default"
    var/list/allowed_module_id = list()
    var/datum/component/point_and_point/point_module
    var/datum/configuration_module/configuration
    var/obj/item/gun_modular/module/next_module
    var/obj/item/gun_modular/module/previous_module

/obj/item/gun_modular/module/atom_init(mapload, ...)
    . = ..()
    
    point_module = AddComponent(/datum/component/point_and_point, module_id)
    configuration = new(src)

/obj/item/gun_modular/module/attackby(obj/item/I, mob/user, params)
    . = ..()
    
    if(istype(I, /obj/item/gun_modular/module))

        user.drop_item()
        
        if(attach(I))
            to_chat(user, "Вы прикрепили модуль")

// проверяем, что модуль можно прицепить к этому модулю
/obj/item/gun_modular/module/proc/check_attach(/obj/item/gun_modular/module/M)

    if(!M.check_attach_to_module(src))
        return FALSE
    
    if(!allowed_module_id.Find(M.module_id))
        return FALSE
    
    return TRUE

// проверяем что этот модуль можно прицепить к другому
/obj/item/gun_modular/module/proc/check_attach_to_module(/obj/item/gun_modular/module/M)

    return TRUE

// прицепляем модуль к этому
/obj/item/gun_modular/module/proc/attach(/obj/item/gun_modular/module/M)

    if(!check_attach(M))
        return FALSE

    next_module = M
    point_module.AddPoint(M.point_module)
    M.attach_to_module(src)
    M.loc = src
    
    return TRUE

// прицепляем этот модуль к другому
/obj/item/gun_modular/module/proc/attach_to_module(/obj/item/gun_modular/module/M)

    previous_module = M

    return TRUE

// отцепляем модуль от этого
/obj/item/gun_modular/module/proc/detach(/obj/item/gun_modular/module/M)

    next_module = null
    M.loc = get_turf(src.loc)
    point_module.RemovePoint(M.point_module)
    M.detach_to_module(src)

    return TRUE

// отцепляем этот модуль от другого
/obj/item/gun_modular/module/proc/detach_to_module(/obj/item/gun_modular/module/M)

    previous_module = M

    return TRUE

// производим активацию модуля в цепочке, следующий после него модуль, будет активирован после завершения рабоыт этого
/obj/item/gun_modular/module/proc/activate(/datum/process_fire/process = null)

    if(!process)
        process = new /datum/process_fire()
    
    return process

// посылаем сигнал с запросом вперед по модулям, но никак не назад, во избежания зацикливания. 
// если модуль может принять сигнал, то он его принимает и возвращает результат который отправляющий может использовать 
// пример: патроннику нужен патрон, он запускает сигнал с запросом патрона, его принимает держатель магазина и если тот может, то он возвращает патрон
// если патрон вернуть не получилось, возвращает FALSE, на что реагирует патронник. 
// если патронник получил патрон, он его использует чтобы произвести выстрел и активировать следующий модуль, елси не получил, происходит click и цепочка прерывается
/obj/item/gun_modular/module/proc/send_signal(/datum/process_fire/process, signal)

    process.SetData(SIGNAL_INFO, signal)

    return relaying(process)

// метод на проверку наличия подходящего сигнала для модуля, если модуль может принять сигнал, он его принимает
/obj/item/gun_modular/module/proc/check_signal(/datum/process_fire/process)
    
    return FALSE

// метод приема сигнала, производит необходимые действия которые запрашивались в сигнале и возвращает результат
/obj/item/gun_modular/module/proc/receive_signal(/datum/process_fire/process)

    return FALSE

// метод перенаправления, если модуль не может принять сигнал, он посылает его в следующий модуль, если следующего модуля нет, то возвращается FALSE
/obj/item/gun_modular/module/proc/relaying(/datum/process_fire/process)

    if(check_signal(process))
        return receive_signal(process)
    
    return relay_next(process)

// метод отправки сигнала следующему модулю, вынесен на случай, если в одном модуле есть разветвление на несколько цепочек, чтобы можно было по очереди послать в них
/obj/item/gun_modular/module/proc/relay_next(/datum/process_fire/process)

    if(next_module)
        return next_module.relaying(process)
    
    return FALSE