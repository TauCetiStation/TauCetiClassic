/datum/role/fanatic
	name = FANATIC
	id = FANATIC

	required_pref = ROLE_FANATIC
	restricted_jobs = list("Security Cadet", "AI", "Cyborg", "Security Officer", "Warden", "Head of Security", "Captain", "Internal Affairs Agent", "Blueshield Officer")
	restricted_species_flags = list(NO_BLOOD)

	antag_hud_type = ANTAG_HUD_FANATIC
	antag_hud_name = "hudfanatic"
	logo_state = "fanatics-logo"
	skillset_type = /datum/skillset/fanatic
	change_to_maximum_skills = TRUE

/datum/role/fanatic/Greet(greeting, custom)
	if(!..())
		return FALSE
	antag.current.playsound_local(null, 'sound/antag/fanatic_alert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	to_chat(antag.current, "<span class='fanatics'>Вы - последователь Ϻрα'αрχѣ, владыки Затимиса, совершенной реальности.</span>")
	to_chat(antag.current, "<span class='fanatics'>Ϻрα'αрχѣ поработило ваш разум и теперь вы готовы сделать всё что Оно прикажет.</span>")
	to_chat(antag.current, "<span class='fanatics'>Кроме того, Оно научило вас Чарами Крови, позволяющим связываться с Затимисом. Держа острый предмет в руке, вы можете рисовать кровавые руны с невероятными эффектами.</span>")

/datum/role/fanatic/proc/equip_fanatic(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	mob.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife/ritual(mob), SLOT_IN_BACKPACK)

/datum/role/fanatic/CanBeAssigned(datum/mind/M, laterole)
	if(laterole == FALSE)
		return ..()
	return TRUE

/datum/role/fanatic/OnPostSetup(laterole)
	..()
	antag.current.AddSpell(new /obj/effect/proc_holder/spell/no_target/draw_rune(antag.current))
	antag.current.AddSpell(new /obj/effect/proc_holder/spell/no_target/fanatics_cry(antag.current))
	antag.current.AddSpell(new /obj/effect/proc_holder/spell/no_target/draw_final_rune(antag.current))

	if(!laterole)
		equip_fanatic(antag.current)
	var/mob/living/carbon/human/H = antag.current
	var/datum/faction/fanatics/F = faction
	addtimer(CALLBACK(F,TYPE_PROC_REF(/datum/faction/fanatics, show_members), H), 1 SECOND)

/datum/role/fanatic/RemoveFromRole(datum/mind/M, msg_admins = TRUE)
	antag.current.RemoveSpell(/obj/effect/proc_holder/spell/no_target/draw_rune)
	antag.current.RemoveSpell(/obj/effect/proc_holder/spell/no_target/fanatics_cry)
	antag.current.RemoveSpell(/obj/effect/proc_holder/spell/no_target/draw_final_rune)
	..()
