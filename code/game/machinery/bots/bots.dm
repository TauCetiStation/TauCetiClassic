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
	var/health = 0 //do not forget to set health for your bot!
	var/maxhealth = 0
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

/obj/machinery/bot/proc/healthcheck()
	if (src.health <= 0)
		src.explode()

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
	if (health < maxhealth)
		if (health > maxhealth/3)
			to_chat(user, "<span class='warning'>[src]'s parts look loose.</span>")
		else
			to_chat(user, "<span class='danger'>[src]'s parts look very loose!</span>")

/obj/machinery/bot/attack_alien(mob/living/carbon/xenomorph/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	src.health -= rand(15,30)*brute_dam_coeff
	src.visible_message("<span class='warning'><B>[user] has slashed [src]!</B></span>")
	playsound(src, 'sound/weapons/slice.ogg', VOL_EFFECTS_MASTER, 25)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()


/obj/machinery/bot/attack_animal(mob/living/simple_animal/attacker)
	..()
	if(attacker.melee_damage == 0)
		return
	src.health -= attacker.melee_damage
	src.visible_message("<span class='warning'><B>[attacker] has [attacker.attacktext] [src]!</B></span>")
	attacker.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()




/obj/machinery/bot/attackby(obj/item/weapon/W, mob/user)
	if(isscrewdriver(W))
		if(!locked)
			open = !open
			to_chat(user, "<span class='notice'>Maintenance panel is now [src.open ? "opened" : "closed"].</span>")
	else if(iswelder(W))
		if(W.use(0, user))
			if(health < maxhealth)
				if(open)
					user.visible_message("<span class='warning'>[user] start repair [src]!</span>","<span class='notice'>You start repair [src]!</span>")
					if(W.use_tool(src, user, 20, volume = 50))
						health = min(maxhealth, health+10)
						user.visible_message("<span class='warning'>[user] repaired [src]!</span>","<span class='notice'>You repaired [src]!</span>")
				else
					to_chat(user, "<span class='notice'>Unable to repair with the maintenance panel closed.</span>")
			else
				to_chat(user, "<span class='notice'>[src] does not need a repair.</span>")
	else
		if(hasvar(W,"force") && hasvar(W,"damtype"))
			switch(W.damtype)
				if("fire")
					src.health -= W.force * fire_dam_coeff
				if("brute")
					src.health -= W.force * brute_dam_coeff
			..()
			healthcheck()
		else
			..()

/obj/machinery/bot/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()

/obj/machinery/bot/blob_act()
	src.health -= rand(20,40)*fire_dam_coeff
	healthcheck()
	return

/obj/machinery/bot/ex_act(severity)
	switch(severity)
		if(1.0)
			src.explode()
			return
		if(2.0)
			src.health -= rand(5,10)*fire_dam_coeff
			src.health -= rand(10,20)*brute_dam_coeff
			healthcheck()
			return
		if(3.0)
			if (prob(50))
				src.health -= rand(1,5)*fire_dam_coeff
				src.health -= rand(1,5)*brute_dam_coeff
				healthcheck()
				return
	return

/obj/machinery/bot/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	var/obj/effect/overlay/pulse2 = new /obj/effect/overlay(loc)
	pulse2.icon = 'icons/effects/effects.dmi'
	pulse2.icon_state = "empdisable"
	pulse2.name = "emp sparks"
	pulse2.anchored = 1
	pulse2.dir = pick(cardinal)

	spawn(10)
		qdel(pulse2)
	if (on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if (was_on)
			turn_on()


/obj/machinery/bot/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/bot/is_operational_topic()
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
