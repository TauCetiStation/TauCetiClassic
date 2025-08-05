/obj/structure/ivent/star_wars/artifact
	name = "bluespace crystal"
	desc = "A green strange crystal"
	icon = 'icons/obj/xenoarchaeology/artifacts.dmi'
	icon_state = "artifact_11"
	density = TRUE
	anchored = TRUE
	light_color = COLOR_GREEN
	light_range = 2
	light_power = 1
	resistance_flags = FULL_INDESTRUCTIBLE

	var/list/force_users = list()
	var/next_touch = 0
	var/next_pulse = 0

/obj/structure/ivent/star_wars/artifact/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/ivent/star_wars/artifact/attack_hand(mob/living/user)
	if(!isliving(user))
		return

	if((world.time < next_touch) || (user in force_users))
		user.adjustFireLoss(15)
		return

	activate()
	force_users += user
	next_touch = world.time + pick(10, 11, 12, 13, 14, 15) MINUTE

/obj/structure/ivent/star_wars/artifact/proc/activate()
	//playsound
	set_light(4, 2)
	icon_state = "artifact_11_active"
	addtimer(CALLBACK(src, PROC_REF(deactivate)), 2 SECOND)

/obj/structure/ivent/star_wars/artifact/proc/deactivate()
	set_light(2, 1)
	icon_state = "artifact_11"

/obj/structure/ivent/star_wars/artifact/process()
	if(world.time > next_pulse)
		pulse()

/obj/structure/ivent/star_wars/artifact/proc/pulse()
	activate()
	next_pulse = world.time + pick(10, 11, 12, 13, 14, 15) MINUTE
	var/list/candidates = player_list - force_users

	for(var/i in 1 to pick(2, 3))
		if(candidates.len == 0)
			break
		force_users += pick_n_take(candidates)
