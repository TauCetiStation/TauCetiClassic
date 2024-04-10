// AI (i.e. game AI, not the AI player) controlled bots

#define BOT_IDLE         0  // idle
#define BOT_HUNT         1  // found target, hunting
#define BOT_PREP_ARREST  2  // at target, preparing to arrest (secbots)
#define BOT_ARREST       3  // arresting target (secbots)
#define BOT_START_PATROL 4  // start patrol
#define BOT_PATROL       5  // patrolling
#define BOT_SUMMON       6  // summoned by PDA

/mob/living/simple_animal/bot
    var/icon_living = ""
	var/icon_dead = ""
	var/icon_gib = null	
	var/icon_move = null
	var/obj/item/weapon/card/id/botcard			// the ID card that the bot "holds"
	var/on = 1
    var/heat_damage_per_tick = 0
	var/cold_damage_per_tick = 0
    var/unsuitable_atoms_damage = 0
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = 0
	var/locked = 1
	var/emagged = 0 
	var/x_last
	var/y_last
	var/same_pos_count
    var/wander = FALSE

/mob/living/simple_animal/bot()
	. = ..()
	bots_list += src

/obj/machinery/bot/death()
	bots_list -= src
	gib()
	return ..()

/mob/living/simple_animal/bot/proc/turn_on()
	if(stat)	return 0
	on = 1
	set_light(initial(light_range))
	return 1

/mob/living/simple_animal/bot/proc/turn_off()
	on = 0
	set_light(0)

/mob/living/simple_animal/bot/emag_act(mob/user)
	if(emagged >= 2)
		return FALSE
	if(locked)
		locked = 0
		emagged = 1
		to_chat(user, "<span class='warning'>You bypass [src]'s controls.</span>")
		return TRUE
	if(!locked && open)
		emagged = 2
		return TRUE
	return FALSE

/obj/machinery/bot/examine(mob/user)
	..()
	if(maxHealth == health)
		return
	if(maxHealth > health / 3)
		to_chat(user, "<span class='warning'>[src]'s parts look loose.</span>")
	else
		to_chat(user, "<span class='danger'>[src]'s parts look very loose!</span>")

/mob/living/simple_animal/bot/attackby(obj/item/weapon/W, mob/user)
	if(isscrewing(W))
		if(!locked)
			open = !open
			to_chat(user, "<span class='notice'>Maintenance panel is now [src.open ? "opened" : "closed"].</span>")
	else if(iswelding(W))
		if(W.use(0, user))
			if(maxHealth < health)
				if(open)
					user.visible_message("<span class='warning'>[user] start repair [src]!</span>","<span class='notice'>You start repair [src]!</span>")
					if(W.use_tool(src, user, 20, volume = 50))
						heal_overall_damage(10,10)
						user.visible_message("<span class='warning'>[user] repaired [src]!</span>","<span class='notice'>You repaired [src]!</span>")
				else
					to_chat(user, "<span class='notice'>Unable to repair with the maintenance panel closed.</span>")
			else
				to_chat(user, "<span class='notice'>[src] does not need a repair.</span>")
	else
		..()

/mob/living/simple_animal/bot/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
			return
		if(EXPLODE_HEAVY)
			adjustBruteLoss(20)
		if(EXPLODE_LIGHT)
			if(prob(50))
				adjustBruteLoss(5)

/mob/living/simple_animal/bot/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	new /obj/effect/overlay/pulse2(loc, 2)

	if (on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if (was_on)
			turn_on()


/mob/living/simple_animal/bot/attack_ai(mob/user)
	attack_hand(user)

/mob/living/simple_animal/bot/proc/inaction_check()
	if(is_on_patrol() && (x_last == x && y_last == y))
		same_pos_count++
		if(same_pos_count >= 15)
			turn_off()
			return FALSE
	else
		same_pos_count = 0

	x_last = x
	y_last = y

	return TRUE

/mob/living/simple_animal/bot/proc/is_on_patrol()
	return FALSE