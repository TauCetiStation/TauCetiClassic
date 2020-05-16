/obj/item/clothing/glasses/sunglasses/chaplain
	name = "faithful sunglasses"
	desc = "Sometimes you just feel like watching them ghosts sin."
	action_button_name = "Assess Holyness"

	var/next_assessment = 0
	var/assessment_cooldown = 6 SECONDS

/obj/item/clothing/glasses/sunglasses/chaplain/proc/gen_holy_overlay(turf/simulated/floor/F)
	var/image/I = image('icons/effects/effects.dmi', "water_light")
	if(F.holy.religion == global.chaplain_religion)
		I.color = "#40e0d0"
	else
		I.color = "#dc143c"
	I.alpha = 0
	I.loc = F
	return I

/obj/item/clothing/glasses/sunglasses/chaplain/proc/animate_holy_overlay(image/holy_overlay)
	animate(holy_overlay, alpha = 200, time = assessment_cooldown * 0.3)
	sleep(assessment_cooldown * 0.3)
	animate(holy_overlay, alpha = 0, time = assessment_cooldown  * 0.3)

/obj/item/clothing/glasses/sunglasses/chaplain/attack_self(mob/user)
	assess_holyness(user)

/obj/item/clothing/glasses/sunglasses/chaplain/proc/assess_holyness(mob/user = usr)
	set name = "Assess Holyness"
	set desc = "Scan your surrounding area on subject of holy land."
	set category = "Object"

	if(user.incapacitated())
		return

	if(!user.client)
		return

	if(!user.mind || !user.mind.holy_role)
		to_chat(user, "<span class='notice'>You do not know how this works.</span>")
		return

	if(next_assessment > world.time)
		return
	next_assessment = world.time + assessment_cooldown

	var/turf/T = get_turf(user)
	for(var/turf/simulated/floor/F in RANGE_TURFS(12, T))
		if(!F.holy)
			continue
		var/image/I = gen_holy_overlay(F)
		INVOKE_ASYNC(src, .proc/animate_holy_overlay, I)
		flick_overlay(I, list(user.client), assessment_cooldown)
