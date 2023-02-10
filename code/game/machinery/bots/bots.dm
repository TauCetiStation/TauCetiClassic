// AI (i.e. game AI, not the AI player) controlled bots

#define SECBOT_IDLE         0  // idle
#define SECBOT_HUNT         1  // found target, hunting
#define SECBOT_PREP_ARREST  2  // at target, preparing to arrest
#define SECBOT_ARREST       3  // arresting target
#define SECBOT_START_PATROL 4  // start patrol
#define SECBOT_PATROL       5  // patrolling
#define SECBOT_SUMMON       6  // summoned by PDA

/obj/machinery/bot
	icon = 'icons/obj/aibots.dmi'
	layer = MOB_LAYER
	light_range = 3
	use_power = NO_POWER_USE
	allowed_checks = ALLOWED_CHECK_NONE
	var/obj/item/weapon/card/id/botcard			// the ID card that the bot "holds"
	var/on = 1
	max_integrity = 1
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = 0//Maint panel
	var/locked = 1
	//var/emagged = 0 //Urist: Moving that var to the general /bot tree as it's used by most bots
	var/x_last
	var/y_last
	var/same_pos_count

/obj/machinery/bot/atom_init()
	. = ..()
	bots_list += src

/obj/machinery/bot/Destroy()
	bots_list -= src
	return ..()

/obj/machinery/bot/proc/turn_on()
	if(stat)	return 0
	on = 1
	set_light(initial(light_range))
	return 1

/obj/machinery/bot/proc/turn_off()
	on = 0
	set_light(0)

/obj/machinery/bot/proc/explode()
	qdel(src)

/obj/machinery/bot/deconstruct(disassembled)
	explode()
	..()

/obj/machinery/bot/emag_act(mob/user)
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
	if(get_integrity() == max_integrity)
		return
	if(get_integrity() > max_integrity / 3)
		to_chat(user, "<span class='warning'>[src]'s parts look loose.</span>")
	else
		to_chat(user, "<span class='danger'>[src]'s parts look very loose!</span>")

/obj/machinery/bot/run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir)
	switch(damage_type)
		if(BRUTE)
			return damage_amount * brute_dam_coeff
		if(BURN)
			return damage_amount * fire_dam_coeff

/obj/machinery/bot/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	if(.)
		new /obj/effect/decal/cleanable/blood/oil(loc)

/obj/machinery/bot/attack_alien(mob/living/carbon/xenomorph/user)
	. = ..()
	if(.)
		visible_message("<span class='warning'><B>[user] has slashed [src]!</B></span>")

/obj/machinery/bot/attack_animal(mob/living/simple_animal/user)
	. = ..()
	if(.)
		visible_message("<span class='warning'><B>[user] has slashed [src]!</B></span>")

/obj/machinery/bot/attackby(obj/item/weapon/W, mob/user)
	if(isscrewing(W))
		if(!locked)
			open = !open
			to_chat(user, "<span class='notice'>Maintenance panel is now [src.open ? "opened" : "closed"].</span>")
	else if(iswelding(W))
		if(W.use(0, user))
			if(get_integrity() < max_integrity)
				if(open)
					user.visible_message("<span class='warning'>[user] start repair [src]!</span>","<span class='notice'>You start repair [src]!</span>")
					if(W.use_tool(src, user, 20, volume = 50))
						repair_damage(10)
						user.visible_message("<span class='warning'>[user] repaired [src]!</span>","<span class='notice'>You repaired [src]!</span>")
				else
					to_chat(user, "<span class='notice'>Unable to repair with the maintenance panel closed.</span>")
			else
				to_chat(user, "<span class='notice'>[src] does not need a repair.</span>")
	else
		..()

/obj/machinery/bot/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct()
			return
		if(EXPLODE_HEAVY)
			take_damage(20, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			if(prob(50))
				take_damage(5, BRUTE, BOMB)

/obj/machinery/bot/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	new /obj/effect/overlay/pulse2(loc, 2)

	if (on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if (was_on)
			turn_on()


/obj/machinery/bot/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/bot/is_operational()
	return TRUE

/obj/machinery/bot/proc/inaction_check()
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

/obj/machinery/bot/proc/is_on_patrol()
	return FALSE
