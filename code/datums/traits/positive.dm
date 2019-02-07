/datum/quirk/Hematophagus
	name = "Hematophagus"
	desc = "Because of the special work of the body you quite successfully digest the blood."
	value = 2
	mob_trait = TRAIT_HEMATOPHAGUS
	gain_text = "<span class='notice'>You feel ready to drink someone's blood.</span>"
	lose_text = "<span class='danger'>You feel like your body needs regular food back.</span>"

/mob/living/carbon/human/proc/Bite(mob/living/carbon/human/target in oview(1, src))
	set category = "IC"
	set name = "Bite"
	set desc = "Bites prey and drains them of a significant portion of blood, feeding you in the process."

	var/bloodsucked = 0
	var/endblood = 0
	var/blood_in_target = target.vessel.total_volume
	var/obj/item/organ/external/BP = target.get_bodypart(BP_HEAD)
	var/bloodsuck_sound = sound('sound/effects/bloodsuck.ogg')

	if(src.nutrition > NUTRITION_LEVEL_STARVING)
		to_chat(src, "<span class='red'>I'm not hungry yet...</span>")
		return
	if(blood_in_target <= 0 || target.species.flags[NO_BLOOD])
		to_chat(src, "<span class='red'>There appears to be no blood in this prey...</span>")
		return
	if(isalien(src))
		return
	if(target == src)
		return
	if(!target || !src || src.stat)
		return
	if(!Adjacent(target))
		return

	src.visible_message("<span class='warning bold'>[src] moves their head next to [target]'s neck, seemingly looking for something!</span>")
	log_game("[key_name(src)] prepares use bloodsuck on [key_name(target)]")
	if(do_after(src, 5 SECONDS, target))
		src.visible_message("<span class='warning bold'>[src] suddenly extends their fangs and plunges them down into [target]'s neck!</span>")
		message_admins("[key_name_admin(src)] start use bloodsuck on [key_name_admin(target)] with [blood_in_target] blood. [ADMIN_JMP(src)]")
		for(var/i in 1 to 10)
			src.visible_message("<span class='warning bold'>[src] slowly sucks blood from [target]'s neck!</span>")
			if(do_after(src, 3 SECONDS, target))
				for(var/mob/living/M in hearers(4, src))
					M << playsound(src, bloodsuck_sound, 2, 0)
				target.vessel.remove_reagent("blood", 8)
				bloodsucked += 8
				src.nutrition = min(src.nutrition + 30, NUTRITION_LEVEL_WELL_FED - (src.get_nutrition() - src.nutrition))
			else
				break
		endblood = blood_in_target - bloodsucked
		log_attack("[key_name(src)] bloodsuck [key_name(target)] and drink [bloodsucked] blood")
		message_admins("[key_name_admin(src)] bloodsuck [key_name_admin(target)], drinks [bloodsucked] from [blood_in_target] blood (now [endblood]) for [bloodsucked/8] times [ADMIN_JMP(src)]")
		target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been bloodsucked by [src.name] ([src.ckey]) and loss [bloodsucked] of [blood_in_target] blood</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='red'>Bloodsuck from [target.name] ([target.ckey]) [bloodsucked] of [blood_in_target] blood</font>")
		BP.take_damage(5, null, DAM_SHARP, "Fangs")

/datum/quirk/Hematophagus/on_spawn()
    quirk_holder.verbs += /mob/living/carbon/human/proc/Bite