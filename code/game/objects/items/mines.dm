/obj/item/mine
	name = "mine"
	desc = "A friendly-looking pancake with a happy light on top. Absolute opposite of libertarian - this mine BEGS to be stepped on."
	icon = 'icons/obj/mines.dmi'
	icon_state = "mine"
	layer = 3

/obj/item/mine/atom_init()
	. = ..()
	if(anchored)
		update_icon()

/obj/item/mine/attack_self(mob/living/user)
	if(locate(/obj/item/mine) in get_turf(src))
		to_chat(user, "<span class='warning'>There already is a mine at this position!</span>")
		return

	if(!user.loc || user.loc.density)
		to_chat(user, "<span class='warning'>You can't plant a mine here.</span>")
		return
	if(!handle_fumbling(user, src, SKILL_TASK_EASY, list(/datum/skill/firearms = SKILL_LEVEL_TRAINED), message_self =  "<span class='notice'>You fumble around figuring out how to deploy [src]...</span>"))
		return
	var/planting_time = apply_skill_bonus(user, SKILL_TASK_AVERAGE, list(/datum/skill/firearms = SKILL_LEVEL_TRAINED, /datum/skill/engineering = SKILL_LEVEL_TRAINED), -0.1)
	user.visible_message("<span class='notice'>[user] starts deploying [src].</span>", "<span class='notice'>You start deploying [src].</span>")
	if(!do_after(user, planting_time, target = src))
		user.visible_message("<span class='notice'>[user] stops deploying [src].</span>", "<span class='notice'>You stop deploying \the [src].</span>")
		return
	user.visible_message("<span class='notice'>[user] finishes deploying [src].</span>", "<span class='notice'>You finish deploying [src].</span>")
	user.drop_from_inventory(src, user.loc)

	anchored = TRUE
	update_icon()

/obj/item/mine/update_icon()
	if(anchored)
		icon_state = "[icon_state]armed"
		alpha = 45
	else
		icon_state = initial(icon_state)
		alpha = 255

/obj/item/mine/Crossed(atom/movable/AM)
	if(HAS_TRAIT(AM, TRAIT_ARIBORN)) // oh no, he is flying, not stepping. Cheater!
		return
	try_trigger(AM)

/obj/item/mine/Bumped(atom/movable/AM)
	if(HAS_TRAIT(AM, TRAIT_ARIBORN))
		return
	try_trigger(AM)

/obj/item/mine/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	trigger_act(Proj)
	qdel(src)

/obj/item/mine/proc/try_trigger(atom/movable/AM)
	if(isliving(AM) || istype(AM, /obj/mecha))
		if(anchored)
			AM.visible_message("<span class='danger'>[AM] steps on [src]!</span>")
			trigger_act(AM)
			qdel(src)

/obj/item/mine/proc/trigger_act(obj)
	explosion(loc, 0, 1, 3)

/obj/item/mine/proc/try_disarm(obj/item/I, mob/user)
	if((I && !ispulsing(I)) || !anchored)
		return

	user.visible_message("<span class='notice'>[user] starts disarming [src].</span>", "<span class='notice'>You start disarming [src].</span>")
	if(I.use_tool(src, user, 40, volume = 50))
		user.visible_message("<span class='notice'>[user] finishes disarming [src].</span>", "<span class='notice'>You finish disarming [src].</span>")

		disarm()

/obj/item/mine/attackby(obj/item/I, mob/user, params)
	. = ..()

	try_disarm(I, user)

/obj/item/mine/proc/disarm()
	anchored = FALSE
	update_icon()

/obj/item/mine/anchored
	anchored = TRUE

/obj/item/mine/shock
	name = "shock mine"
	desc = "A security issued less-than-lethal mine, this one will shock and stun anyone unfortunate to step on it."
	icon_state = "shockmine"
	var/stepped_by = BP_R_LEG

/obj/item/mine/shock/atom_init()
	. = ..()
	stepped_by = pick(BP_R_LEG, BP_L_LEG)

/obj/item/mine/shock/trigger_act(obj)
	if(isliving(obj))
		var/mob/living/M = obj
		M.electrocute_act(30, src, siemens_coeff = 1.0, def_zone = stepped_by) // electrocute act does a message.
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(3, 1, src)
	s.start()

/obj/item/mine/shock/anchored
	anchored = TRUE

/obj/item/mine/incendiary
	name = "incendiary mine"
	desc = "This thing definitely violates Space Geneva Convention."
	icon_state = "incendiarymine"

/obj/item/mine/incendiary/trigger_act(obj)
	explosion(loc, 0, 0, 2)
	if(isliving(obj))
		var/mob/living/M = obj
		M.adjust_fire_stacks(10)
		M.IgniteMob()

/obj/item/mine/incendiary/anchored
	anchored = TRUE

/obj/item/mine/emp
	name = "ion mine"
	desc = "When you hate your roomba really, really much."
	icon_state = "empmine"

/obj/item/mine/emp/trigger_act(obj)
	empulse(src, 2, 3, custom_effects = EMP_SEBB)

/obj/item/mine/emp/anchored
	anchored = TRUE
