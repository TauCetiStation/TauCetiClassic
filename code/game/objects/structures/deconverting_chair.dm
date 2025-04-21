
/obj/structure/stool/bed/chair/electrotherapy
	name = "electrotherapy chair"
	desc = "Latest development in the field of brainwashing. This thing is almost guaranteed to bring back loyalty to your crew! Or... No?"
	icon_state = "echair0"
	var/list/roles_to_deconvert = list(SHADOW_THRALL, CULTIST)
	var/on_cooldown = FALSE

/obj/structure/stool/bed/chair/electrotherapy/atom_init()
	. = ..()
	add_overlay(image('icons/obj/objects.dmi', src, "echair_over", MOB_LAYER + 1, dir))

/obj/structure/stool/bed/chair/electrotherapy/attackby(obj/item/weapon/W, mob/user)
	return

/obj/structure/stool/bed/chair/electrotherapy/AltClick(mob/user)
	if(!user.Adjacent(src))
		return
	if(!buckled_mob)
		to_chat(user, "<span class='warning'>Activation is not possible without a user in the chair.</span>")
		return
	if(!user.is_busy() && do_after(usr, 3 SECONDS, target = user))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, get_turf(src))
		s.start()
		deconvert(user, buckled_mob)
		if(prob(50))
			if(buckled_mob.ismindprotect())
				remove_protect_implants(user, buckled_mob)

/obj/structure/stool/bed/chair/electrotherapy/proc/deconvert(mob/user, mob/living/carbon/human/target)
	if(!ishuman(target) || on_cooldown)
		return
	target.electrocute_act(50, src)
	if(target.mind)
		for(var/role in roles_to_deconvert)
			var/datum/role/R = target.mind.GetRole(role)
			if(!R)
				continue
			if(prob(90))
				R.Deconvert()
		if(prob(50))
			target.adjustBrainLoss(rand(30, 90))
		if(prob(50))
			var/obj/item/organ/internal/brain/IO = target.organs_by_name[O_BRAIN]
			if(istype(IO))
				IO.damage += rand(10, 50)
		if(prob(50))
			target.ear_deaf += 20
		if(prob(50))
			target.eye_blind += 20

		playsound(src, 'sound/items/surgery/defib_zap.ogg', VOL_EFFECTS_MASTER)
		on_cooldown = TRUE
		addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), 1 MINUTE, TIMER_UNIQUE)

/obj/structure/stool/bed/chair/electrotherapy/proc/remove_protect_implants(mob/living/carbon/human/target)
	if(!target.ismindprotect())
		return

	for(var/obj/item/weapon/implant/mind_protect/mindshield/I in target.contents)
		if(I.implanted)
			qdel(I)
			to_chat(target, "<span class='notice'>Your mindshield implant has been deactivated.</span>")
	for(var/obj/item/weapon/implant/mind_protect/loyalty/I in target.contents)
		if(I.implanted)
			qdel(I)
			to_chat(target, "<span class='notice'>Your loyality implant has been deactivated.</span>")
		target.sec_hud_set_implants()



/obj/structure/stool/bed/chair/electrotherapy/proc/reset_cooldown()
	if(on_cooldown)
		on_cooldown = FALSE
		visible_message("<span class='notice'>[bicon(src)] [src] has recharged.</span>")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, get_turf(src))
		s.start()
