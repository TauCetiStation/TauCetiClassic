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
	if(isalien(src) || target.vessel.total_volume <= 0 || target.species.flags[NO_BLOOD])
		to_chat(src, "<span class='red'>There appears to be no blood in this prey...</span>")
		return
	if(target == src)
		return
	if(!target || !src || src.stat)
		return
	if(!Adjacent(target))
		return
	if(last_special > world.time)
		return
	var/obj/item/organ/external/BP = target.get_bodypart(BP_HEAD)
	last_special = world.time + 600
	src.visible_message("<span class='warning bold'>[src] moves their head next to [target]'s neck, seemingly looking for something!</span>")
	if(do_after(src, 300, target)) //Thrirty seconds.
		src.visible_message("<span class='warning bold'>[src] suddenly extends their fangs and plunges them down into [target]'s neck!</span>")
		target.vessel.remove_reagent("blood", 80)
		src.nutrition = min(src.nutrition + 300, 400)
		BP.take_damage(5, null, DAM_SHARP, "Fangs") //You're getting fangs pushed into your neck. What do you expect?

/datum/quirk/Hematophagus/on_spawn()
    quirk_holder.verbs += /mob/living/carbon/human/proc/Bite