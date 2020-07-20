/obj/item/weapon/gun/medbeam
	name = "prototype retrosynchronizer"
	desc = "A prototype healgun, which slowly reverts organic matter to it's previous state, 'healing' it. Don't cross the streams!"
	icon_state = "medigun"
	item_state = "medigun"
	var/mob/living/current_target
	var/last_check = 0
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	var/max_range = 8
	var/active = 0
	var/datum/beam/current_beam = null

/obj/item/weapon/gun/medbeam/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/gun/medbeam/Destroy(mob/user)
	STOP_PROCESSING(SSobj, src)
	LoseTarget()
	return ..()

/obj/item/weapon/gun/medbeam/dropped(mob/user)
	..()
	LoseTarget()

/obj/item/weapon/gun/medbeam/equipped(mob/user)
	..()
	LoseTarget()

/obj/item/weapon/gun/medbeam/proc/LoseTarget()
	if(active)
		qdel(current_beam)
		current_beam = null
		active = 0
		on_beam_release(current_target)
	current_target = null

/obj/item/weapon/gun/medbeam/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(isliving(user))
		add_fingerprint(user)

	if(current_target)
		LoseTarget()
	if(!isliving(target))
		return

	current_target = target
	active = TRUE
	current_beam = new(user,current_target,time=6000,beam_icon_state="medbeam",btype=/obj/effect/ebeam/medical)
	INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)
	user.visible_message("<span class='notice'>[user] aims their [src] at [target]!</span>")


/obj/item/weapon/gun/medbeam/process()

	var/source = loc
	if(!isliving(source))
		LoseTarget()
		return

	if(!current_target)
		LoseTarget()
		return

	if(world.time <= last_check+check_delay)
		return

	last_check = world.time

	if(get_dist(source, current_target)>max_range || !los_check(source, current_target))
		LoseTarget()
		if(isliving(source))
			to_chat(source, "<span class='warning'>You lose control of the beam!</span>")
		return

	if(current_target)
		on_beam_tick(current_target)

/obj/item/weapon/gun/medbeam/proc/los_check(atom/movable/user, mob/target)
	var/turf/user_turf = user.loc
	if(!istype(user_turf))
		return 0
	var/obj/dummy = new(user_turf)
	dummy.pass_flags |= PASSTABLE|PASSGLASS|PASSGRILLE //Grille/Glass so it can be used through common windows
	for(var/turf/turf in getline(user_turf,target))
		if(turf.density)
			qdel(dummy)
			return 0
		for(var/atom/movable/AM in turf)
			if(!AM.CanPass(dummy,turf,1))
				qdel(dummy)
				return 0
		for(var/obj/effect/ebeam/medical/B in turf)// Don't cross the str-beams!
			if(B.owner.origin != current_beam.origin)
				explosion(B.loc,0,3,5,8)
				qdel(dummy)
				return 0
	qdel(dummy)
	return 1

/obj/item/weapon/gun/medbeam/proc/on_beam_hit(var/mob/living/target)
	return

/obj/item/weapon/gun/medbeam/proc/on_beam_tick(var/mob/living/target)
	target.adjustBruteLoss(-5)
	target.adjustFireLoss(-5)
	target.adjustToxLoss(-2)
	target.adjustOxyLoss(-2)
	return

/obj/item/weapon/gun/medbeam/proc/on_beam_release(var/mob/living/target)
	return

/obj/effect/ebeam/medical
	name = "medical beam"
	icon_state = "medbeam"
