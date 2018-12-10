/obj/effect/proc_holder/spell/aoe_turf/scp939_voice
	name = "Mimic voice"
	desc = ""
	panel = "SCP"
	charge_max = 50
	clothes_req = 0
	range = 1

/obj/effect/proc_holder/spell/aoe_turf/scp939_voice/cast(list/targets)
	var/newvoice = sanitize_safe(input("Enter the name of your new voice", "What voice would you like to mimic?") as text)
	if(!newvoice)
		newvoice = "SCP-939"

	var/mob/living/simple_animal/scp939/owner = usr
	if(owner)
		owner.fake_voice = newvoice
		owner.voice_name = newvoice
		to_chat(owner, "<span class='notice'>You mimic the voice of [newvoice].</span>")

/obj/effect/proc_holder/spell/aoe_turf/scp939_eat
	name = "Eat"
	desc = ""
	panel = "SCP"
	charge_max = 10
	clothes_req = 0
	range = 1
	var/mob/living/simple_animal/scp939/owner = null
	var/mob/living/carbon/human/eating = null
	var/eat_time = 30
	var/health_regen = 10
	var/timer_active = FALSE

/obj/effect/proc_holder/spell/aoe_turf/scp939_eat/cast(list/targets)
	//aaaaaaaaaaaaaaaaaaaaaaaaaaaaa
	var/mob/living/simple_animal/scp939/SCP = usr

	if(!istype(SCP) || SCP.is_busy(SCP))
		return

	owner = SCP
	eating = null
	var/list/mytargets = list(SCP.loc, get_step(SCP.loc, SCP.dir),get_step(SCP.loc, EAST), get_step(SCP.loc, WEST), get_step(SCP.loc, NORTH), get_step(SCP.loc, SOUTH))
	for(var/turf/T in mytargets)
		for(var/obj/item/weapon/reagent_containers/food/snacks/Food in T.contents)
			SCP.visible_message("<span class='warning'>[SCP] eats [Food] in one bite!</span>")
			SCP.health = min(SCP.health + Food.bitesize*5, SCP.maxHealth)
			qdel(Food)
			playsound(SCP, pick('sound/weapons/zilla_eat.ogg','sound/weapons/bite.ogg'), 50, 2)
			return
		for(var/mob/living/carbon/human/H in T.contents)
			if(H.stat != CONSCIOUS)
				eating = H
				break

	if(!eating)
		to_chat(SCP, "<span class='warning'>There is nothing to eat!</span>")
		return

	if(!timer_active)
		timer_active = TRUE
		addtimer(CALLBACK(src, .proc/eatsound), 1)

	while(eating)
		if(SCP.health >= SCP.maxHealth)
			to_chat(SCP, "<span class='warning'>You are full!</span>")
			eating = null
			return
		if(eating.getBruteLoss() >= 300)
			to_chat(SCP, "<span class='warning'>There is nothing left to eat from [eating]!</span>")
			eating = null
			return

		SCP.visible_message("<span class='warning'>[SCP] tears off pieces of flesh from [eating] and eats them!</span>")
		if(eating.stat == CONSCIOUS || SCP.health<=0 || !do_mob(SCP, eating, eat_time))
			to_chat(SCP, "<span class='warning'>You are no longer eating!</span>")
			eating = null
			return
		eating.take_overall_damage(rand(5,10), used_weapon = "teeth marks")
		SCP.health = min(SCP.health + health_regen, SCP.maxHealth)

/obj/effect/proc_holder/spell/aoe_turf/scp939_eat/proc/eatsound()
	if(!eating)
		timer_active = FALSE
		return

	playsound(owner, pick('sound/weapons/zilla_eat.ogg','sound/weapons/bite.ogg'), 50, 2)

	addtimer(CALLBACK(src, .proc/eatsound), rand(6,15))

/obj/effect/proc_holder/spell/aoe_turf/scp939_breath
	name = "Ammonia breath"
	desc = ""
	panel = "SCP"
	charge_max = 450
	clothes_req = 0
	range = 1
	var/ammount = 12

/obj/effect/proc_holder/spell/aoe_turf/scp939_breath/cast(list/targets)
	var/datum/reagents/evaporate = new /datum/reagents
	evaporate.my_atom = usr
	evaporate.add_reagent("psilocybin", ammount/3)
	evaporate.add_reagent("space_drugs", ammount/3)
	evaporate.add_reagent("cryptobiolin", ammount/3)
	var/location = get_turf(usr)
	var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem
	S.attach(location)
	S.set_up(evaporate, ammount, 0, location)
	S.start()

	usr.visible_message("<span class='warning'>[usr] exhales some kind of gas!</span>")
	playsound(usr, 'sound/effects/bamf.ogg', 50, 1)

/obj/effect/proc_holder/spell/aoe_turf/scp939_stealth
	name = "Hide"
	desc = ""
	panel = "SCP"
	charge_max = 30
	clothes_req = 0
	range = 1
	var/active = FALSE
	var/mob/living/owner
	var/turf/last_loc
	var/minalpha = 10
	var/hidespeed = 55

/obj/effect/proc_holder/spell/aoe_turf/scp939_stealth/process()
	if(owner.stat == DEAD)
		turn_off()

	owner.alpha = max(minalpha, owner.alpha - hidespeed)
	if(!owner.alpha)
		owner.invisibility = SEE_INVISIBLE_LIVING + 1 // formal invis to prevent AI TRACKING and alt-clicking, cmon, He merged with surroundings
	else
		owner.invisibility = 0

	if(last_loc && owner.loc != last_loc)
		turn_off()
	last_loc = owner.loc

/obj/effect/proc_holder/spell/aoe_turf/scp939_stealth/cast(list/targets)
	if(!active)
		owner = usr
		turn_on()
	else
		turn_off()

/obj/effect/proc_holder/spell/aoe_turf/scp939_stealth/proc/turn_on()
	to_chat(owner, "<span class='notice'>You start hiding.</span>")
	owner.alpha = 255
	START_PROCESSING(SSobj, src)
	active = TRUE
	last_loc = null

/obj/effect/proc_holder/spell/aoe_turf/scp939_stealth/proc/turn_off()
	to_chat(owner, "<span class='notice'>You stop hiding.</span>")
	owner.alpha = 255
	owner.invisibility = 0
	STOP_PROCESSING(SSobj, src)
	active = FALSE

/mob/living/simple_animal/scp939
	name = "SCP-939"
	real_name = "SCP-939"
	desc = "SCP-939 - endothermic predator with no eyes"
	icon = 'code/modules/SCP/SCP_939/scp64x32.dmi'
	icon_state = "scp939"
	icon_living = "scp939"
	icon_dead = "scp939_dead"
	maxHealth = 300
	health = 300
	response_help  = "pets"
	response_disarm = "flails at"
	response_harm = "punches"
	speak_emote = list("says")
	emote_hear = list("says")

	harm_intent_damage = 0
	melee_damage_lower = 15
	melee_damage_upper = 20
	attacktext = " brutally bites"
	environment_smash = 0

	speed = -1
	a_intent = "harm"
	stop_automated_movement = 1

	universal_speak = 1
	universal_understand = 1

	attack_sound = 'sound/weapons/polkan_atk.ogg'

	sight = SEE_MOBS

	var/health_regen = 2
	var/fake_voice = "SCP-939"

#define FULLSCREEN_LAYER 18
#define DAMAGE_LAYER FULLSCREEN_LAYER + 0.1
#define BLIND_LAYER DAMAGE_LAYER + 0.1
#define CRIT_LAYER BLIND_LAYER + 0.1

/obj/screen/fullscreen/scp_blind
	icon = 'code/modules/SCP/SCP_939/scp_full.dmi'
	icon_state = "scp_blind"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE

#undef FULLSCREEN_LAYER
#undef BLIND_LAYER
#undef DAMAGE_LAYER
#undef CRIT_LAYER

/mob/living/simple_animal/scp939/atom_init()
	..()
	//name = text("[initial(name)] ([rand(1, 1000)])")
	//real_name = name
	//status_flags ^= CANPUSH
	//for(var/spell in hulk_powers)
	//	spell_list += new spell(src)

	spell_list += new /obj/effect/proc_holder/spell/aoe_turf/scp939_breath(src)
	spell_list += new /obj/effect/proc_holder/spell/aoe_turf/scp939_stealth(src)
	spell_list += new /obj/effect/proc_holder/spell/aoe_turf/scp939_voice(src)
	spell_list += new /obj/effect/proc_holder/spell/aoe_turf/scp939_eat(src)
	var/matrix/Mx = matrix()
	Mx.Scale(1)
	Mx.Translate(-16,0)
	transform = Mx

/mob/living/simple_animal/scp939/Life()
	//if(health < 1)
	//	death()
	//	return
	if(client)
		overlay_fullscreen("scp_blind", /obj/screen/fullscreen/scp_blind)

		var/hurted = health / maxHealth
		damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
		if(hurted < 0.5)
			var/severity = 0
			switch(hurted)
				if(0.7 to 0.9)		severity = 1
				if(0.5 to 0.7)		severity = 2
				if(0.4 to 0.5)		severity = 3
				if(0.3 to 0.4)		severity = 4
				if(0.2 to 0.3)		severity = 5
				if(0 to 0.2)		severity = 6
			overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")

		if(health > 0)
			health = min(health + health_regen, maxHealth)

		hud_used.reload_fullscreen()
	..()

/mob/living/simple_animal/scp939/Stat()
	..()

	//if(statpanel("Status"))
	//	stat(null, "Health: [round((health / maxHealth) * 100)]%")

/mob/living/simple_animal/scp939/say(var/message)
	var/save_name = name
	var/save_realname = real_name
	if(fake_voice)
		name = fake_voice
		real_name = fake_voice
	..(message)
	spawn(3)
		name = save_name
		real_name = save_realname