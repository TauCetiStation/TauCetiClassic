/obj/item/gun_modular/module
	name = "gun module"
	var/module_id = "default"
	var/list/allowed_module_id = list()
	var/datum/component/point_and_point/point_module
	var/datum/configuration_module/configuration
	var/list/obj/item/gun_modular/module/next_modules
	var/obj/item/gun_modular/module/previous_module
	var/list/datum/gun_modular/component/default_components_module

/obj/item/gun_modular/module/atom_init(mapload, ...)
	. = ..()

	point_module = AddComponent(/datum/component/point_and_point, module_id)
	configuration = new(src)
	init_default_components_module()
	init_allowed_modules()

/obj/item/gun_modular/module/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/gun_modular/module))

		user.drop_item()

		if(attach(I))
			to_chat(user, "Вы прикрепили модуль")

/obj/item/gun_modular/module/proc/prepare_default_components_list()

	LAZYINITLIST(default_components_module)

	return TRUE

// подготавливаем составляющие модуля для его работы.
// составляющие в идеале должны быть атомарными и отражать определенную функцию модуля, которую можно использовать в других модулях во избежания копипасты
/obj/item/gun_modular/module/proc/init_default_components_module()

	prepare_default_components_list()

	return TRUE

/obj/item/gun_modular/module/proc/add_default_component(datum/gun_modular/component/C)

	prepare_default_components_list()

	LAZYADD(default_components_module, C)

	return TRUE

/obj/item/gun_modular/module/proc/init_allowed_modules()
	return TRUE

// добавляем айди модуля в доступные для прицепления модули
/obj/item/gun_modular/module/proc/add_allow_module(module_id)

	LAZYINITLIST(allowed_module_id)

	if(allowed_module_id.Find(module_id))
		return FALSE

	LAZYADD(allowed_module_id, module_id)

	return TRUE

// удаляем айди модуля из доступных для прицепления модулей
/obj/item/gun_modular/module/proc/remove_allow_module(module_id)

	LAZYREMOVE(allowed_module_id, module_id)

	return TRUE

// проверяем, доступен ли модуль для прицепления
/obj/item/gun_modular/module/proc/check_allow_module(module_id)

	return allowed_module_id.Find(module_id)

// проверяем, что модуль можно прицепить к этому модулю
/obj/item/gun_modular/module/proc/check_attach(obj/item/gun_modular/module/M)

	if(!M.check_attach_to_module(src))
		return FALSE

	if(!check_allow_module(M.module_id))
		return FALSE

	return TRUE

// проверяем что этот модуль можно прицепить к другому
/obj/item/gun_modular/module/proc/check_attach_to_module(obj/item/gun_modular/module/M)

	return TRUE

/obj/item/gun_modular/module/proc/prepare_next_modules()

	LAZYINITLIST(next_modules)

	return TRUE

// прицепляем модуль к этому
/obj/item/gun_modular/module/proc/attach(obj/item/gun_modular/module/M)

	if(!check_attach(M))
		return FALSE

	prepare_next_modules()

	LAZYADD(next_modules, M)
	point_module.AddPoint(M.point_module)
	M.attach_to_module(src)
	M.loc = src

	return TRUE

// прицепляем этот модуль к другому
/obj/item/gun_modular/module/proc/attach_to_module(obj/item/gun_modular/module/M)

	previous_module = M

	return TRUE

// отцепляем модуль от этого
/obj/item/gun_modular/module/proc/detach(obj/item/gun_modular/module/M)

	LAZYREMOVE(next_modules, M)
	M.loc = get_turf(src.loc)
	point_module.RemovePoint(M.point_module)
	M.detach_to_module(src)

	return TRUE

// отцепляем этот модуль от другого
/obj/item/gun_modular/module/proc/detach_to_module(obj/item/gun_modular/module/M)

	previous_module = M

	return TRUE

/obj/item/gun_modular/module/proc/main_action(datum/process_fire/process)

	for(var/datum/gun_modular/component/component in default_components_module)
		process.AddComponentGun(component.CopyComponentGun())

	for(var/obj/item/gun_modular/module/next_module in next_modules)
		next_module.main_action(process)

	return TRUE

// производим активацию модуля в цепочке, следующий после него модуль, будет активирован после завершения работы этого
// когда цепочка завершится, произойдет пост активация, которая по результатам из процесса стрельбы, произведет необходимые действия
// пример: патронник получил патрон от магазина и отправился дальше, магазин не произвел никакой активации и отправил процесс дальше, ствол принял процесс и он оказался сломан
// из за сломанного ствола, выстрел произойти не может, но за выстрел отвечает патронник ранее, для этого нужна пост активация которая, по кторой модули могут прийти к итоговому результату и сделать действие
/obj/item/gun_modular/module/proc/activate(datum/process_fire/process)

	return TRUE

/obj/item/gun_modular/module/proc/post_activate(datum/process_fire/process)

	return TRUE

// посылаем сигнал с запросом вперед по модулям, но никак не назад, во избежания зацикливания.
// если модуль может принять сигнал, то он его принимает и возвращает результат который отправляющий может использовать
// пример: патроннику нужен патрон, он запускает сигнал с запросом патрона, его принимает держатель магазина и если тот может, то он возвращает патрон
// если патрон вернуть не получилось, возвращает FALSE, на что реагирует патронник.
// если патронник получил патрон, он его использует чтобы произвести выстрел и активировать следующий модуль, елси не получил, происходит click и цепочка прерывается
/obj/item/gun_modular/module/proc/send_signal_module(datum/process_fire/process, signal)

	//process.SetData(SIGNAL_INFO, signal)

	return relaying_module(process)

// метод на проверку наличия подходящего сигнала для модуля, если модуль может принять сигнал, он его принимает
/obj/item/gun_modular/module/proc/check_signal_module(datum/process_fire/process)

	return FALSE

// метод приема сигнала, производит необходимые действия которые запрашивались в сигнале и возвращает результат
/obj/item/gun_modular/module/proc/receive_signal_module(datum/process_fire/process)

	return FALSE

// метод перенаправления, если модуль не может принять сигнал, он посылает его в следующий модуль, если следующего модуля нет, то возвращается FALSE
/obj/item/gun_modular/module/proc/relaying_module(datum/process_fire/process)

	if(check_signal_module(process))
		var/result = receive_signal_module(process)
		if(result)
			return result

	return relay_next_modules(process)

// метод отправки сигнала следующему модулю, вынесен на случай, если в одном модуле есть разветвление на несколько цепочек, чтобы можно было по очереди послать в них
/obj/item/gun_modular/module/proc/relay_next_modules(datum/process_fire/process)

	for(var/obj/item/gun_modular/module/M in next_modules)
		var/result = M.relaying_module(process)
		if(result)
			return result

	return FALSE
