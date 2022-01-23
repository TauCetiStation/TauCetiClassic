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
	if(user.mind.getSkillRating(SKILL_FIREARMS) < SKILL_FIREARMS_TRAINED)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to deploy [src].</span>", "<span class='notice'>You fumble around figuring out how to deploy [src]...</span>")
		if(!do_after(user, SKILL_TASK_EASY, target = src))
			return
	var/planting_time =  max(SKILL_TASK_VERY_EASY, SKILL_TASK_AVERAGE - 1 SECONDS *  (2 * user.mind.getSkillRating(SKILL_FIREARMS)  + user.mind.getSkillRating("engineering")))
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
	try_trigger(AM)

/obj/item/mine/Bumped(atom/movable/AM)
	try_trigger(AM)

/obj/item/mine/bullet_act(obj/item/projectile/Proj)
	trigger_act(Proj)
	qdel(src)

/obj/item/mine/proc/try_trigger(atom/movable/AM)
	if(iscarbon(AM) || issilicon(AM) || istype(AM, /obj/mecha))
		if(anchored)
			AM.visible_message("<span class='danger'>[AM] steps on [src]!</span>")
			trigger_act(AM)
			qdel(src)

/obj/item/mine/proc/trigger_act(obj)
	explosion(loc, 1, 1, 3, 3)

/obj/item/mine/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ismultitool(I) || !anchored)
		return

	user.visible_message("<span class='notice'>[user] starts disarming [src].</span>", "<span class='notice'>You start disarming [src].</span>")
	if(I.use_tool(src, user, 40, volume = 50))
		user.visible_message("<span class='notice'>[user] finishes disarming [src].</span>", "<span class='notice'>You finish disarming [src].</span>")

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
	explosion(loc, 0.5, 1, 1)
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
	empulse(src, 2, 3)

/obj/item/mine/emp/anchored
	anchored = TRUE
