/datum/component/fishing
	var/list/catchable_things
	var/catch_time
	var/catchable_things_amount
	var/catch_chance

/datum/component/fishing/Initialize(catchable_things, catch_time = 5 SECONDS, catchable_things_amount = 15, catch_chance = 50)
	src.catchable_things = catchable_things
	src.catch_time = catch_time
	src.catchable_things_amount = catchable_things_amount
	src.catch_chance = catch_chance

	RegisterSignal(parent, list(COMSIG_PARENT_ATTACKBY), PROC_REF(try_catch))

/datum/component/fishing/proc/try_catch(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER

	if(istype(I, /obj/item/weapon/wirerod) && !user.is_busy())
		INVOKE_ASYNC(src, PROC_REF(start_fishing), I, user)
		return COMPONENT_NO_AFTERATTACK

/datum/component/fishing/proc/start_fishing(obj/item/I, mob/living/user)
	var/atom/A = parent
	if(catchable_things_amount < 3)
		to_chat(user, "<span class='warning'>Looks like there is almost no things left in this location.</span>")
	A.visible_message("<span class='notice'>[user] starts fishing.</span>")
	if(!do_after(user, catch_time, target = A))
		A.visible_message("<span class='notice'>[user] stops fishing.</span>")
		return
	if(!prob(catch_chance))
		A.visible_message("<span class='notice'>[user] fails to catch anything.</span>")
		return
	if(!catchable_things_amount)
		to_chat(user, "<span class='warning'>No things left here, time to change location.</span>")
		return
	catchable_things_amount--
	var/catchable_path = pickweight(catchable_things)
	var/thing = new catchable_path(get_turf(A), get_step(user, get_dir(A, user)))
	A.visible_message("<span class='notice'>[user] has caught [thing].</span>")
