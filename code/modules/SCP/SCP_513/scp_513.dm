#define STAGE_WAIT		0
#define STAGE_MESSAGE	1
#define STAGE_SLEEP		2
#define STAGE_DAMAGE	3

/obj/item/scp513
	name = "SCP-513"
	desc = "An old cowbell, covered in immense amounts of rust."
	icon = 'code/modules/SCP/SCP_513/cow_bell.dmi'
	icon_state = "scp513"
	var/global/mob/living/carbon/list/victims = list()
	var/global/mob/living/carbon/list/next_braindamage_stage = list()
	var/global/mob/living/carbon/list/braindamage_stage = list()
	var/global/mob/living/carbon/list/wake_up_timing = list()
	var/static/list/paranoia_messages = list("You feel as if something is watching you...", "It feels as if something is stalking you")
	var/static/list/assault_messages = list("A horrifying monster attacks you, before running off!", "You are bolted awake by a horrifying entity attacking you!")
	var/static/list/spook_messages = list("You see a disturbing entity lingering in your peripheral vision", "You swear you can see an abomination lurking...", "A strange entity stares at you, and sends chiils to your very core.")
	var/static/list/insomnia_messages = list("You feel so tired... but you can't sleep.", "You feel like... like.... sleep is.... can't.... sleep....")

/obj/item/scp513/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/scp513/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/scp513/proc/ring(mob/living/user)
	for(var/mob/living/carbon/M in hear(7, get_turf(src)))
		to_chat(M, "<span class='danger'><i>\The [src] rings, sending chills to your very bone.</i></span>")
		M << pick('code/modules/SCP/SCP_513/Bell2.ogg', 'code/modules/SCP/SCP_513/Bell3.ogg')
		if(!(M in victims))
			victims += M
			braindamage_stage[M] = STAGE_WAIT
			next_braindamage_stage[M] = world.time + rand(300, 420) //Funnily enough, 420 seconds is 7 minutes. Which makes for good weed jokes.

/obj/item/scp513/pickup(mob/living/user)
	. = ..()
	if(user.a_intent == I_HURT)
		to_chat(user, "<span class='danger'><b><i>You accidentally ring \the [src]!</i></b></span>")
		ring(user)

/obj/item/scp513/attack_self(mob/living/user)
	if(user in victims)
		to_chat(user, "<span class='notice'>I rang it once, and I felt terrible. Why the hell would I do that again?!</span>")
		return
	ring(user)

/obj/item/scp513/process()
	for(var/mob/living/carbon/M in victims)
		if(!M.client)
			continue
		if(prob(2.5))
			to_chat(M, "<span class='warning'><i>[pick(paranoia_messages)]</i></span>")
		var/next_scare = victims[M]
		if (M.sleeping >= 10 && !(M in wake_up_timing))
			wake_up_timing[M] = world.time + rand(100, 150)
		else if(wake_up_timing[M] && world.time >= wake_up_timing[M])
			to_chat(M, "<span class='danger'>[pick(assault_messages)]</span>")
			M.sleeping = 0
			wake_up_timing -= M
			M.adjustBruteLoss(rand(1,7))
			display_513_1(get_step(get_turf(src), pick(cardinal)), M, 17)
		else if (world.time >= next_scare)
			victims[M] = world.time + rand(100,1200)
			display_513_1(find_safe_spot(get_turf(M), M.client.view), M, 17)
			to_chat(M, "<span class='warning'><i>[pick(spook_messages)]</i></span>")
		else if (next_braindamage_stage[M] && world.time >= next_braindamage_stage[M])
			switch(braindamage_stage[M])
				if(STAGE_WAIT)
					braindamage_stage[M] = STAGE_MESSAGE
				if(STAGE_MESSAGE)
					next_braindamage_stage[M] = world.time + rand(120, 300)
					braindamage_stage[M] = STAGE_SLEEP
				if(STAGE_SLEEP)
					next_braindamage_stage[M] = world.time + rand(600, 720)
					braindamage_stage[M] = STAGE_DAMAGE
		else
			switch(braindamage_stage[M])
				if(STAGE_MESSAGE)
					if(prob(3.5))
						to_chat(M, "<span class='warning'>[pick(insomnia_messages)]</span>")
				if(STAGE_SLEEP)
					if(prob(4))
						M.sleeping = 50
				if(STAGE_DAMAGE)
					M.adjustBrainLoss(rand(4,6))

/obj/item/scp513/proc/display_513_1(turf/spot, mob/living/target, length = 20, fade=TRUE)
	var/image/img = image('code/modules/SCP/SCP_513/SCP-513.dmi', spot, "scp513_1")
	img.layer = 4 + 0.1
	img.plane = 3
	target.client.images |= img
	spawn(length)
		target.client.images -= img
		qdel(img)

/obj/item/scp513/proc/find_safe_spot(turf/spot, range=7, min_dist = 3)
	var/list/valid_turfs = list()
	for(var/turf/T in view(spot, range))
		if((istype(T, /turf/simulated/floor) || istype(T, /turf/unsimulated/floor)) && get_dist(spot, T) >= min_dist)
			valid_turfs += T
	return pick(valid_turfs)