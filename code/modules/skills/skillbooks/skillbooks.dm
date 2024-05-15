/obj/item/weapon/book/skillbook
	name = "Skillbook"

	unique = TRUE
	dat = FALSE // no content, just skill boosts

	// will be set automatically
	var/datum/skillset/bonus_skillset

	var/list/skills

/obj/item/weapon/book/skillbook/atom_init()
	. = ..()
	desc = "Boosts work efficiency for following tasks while in hands:\n"

	bonus_skillset = new

	for(var/skill_type in skills)
		var/level = skills[skill_type]
		bonus_skillset.set_value(skill_type, level)

		var/datum/skill/S = all_skills[skill_type]
		desc += "[S.name]: up to [S.custom_ranks[level]] level; "

/obj/item/weapon/book/skillbook/equipped(mob/living/user, slot)
	..()

	if(!istype(user))
		return

	// well, about Ian - why not? idk if it even works
	if(slot == SLOT_L_HAND || slot == SLOT_R_HAND || (isIAN(user) && slot == SLOT_MOUTH))
		user.add_skills_buff(bonus_skillset)
	else
		user.remove_skills_buff(bonus_skillset)

/obj/item/weapon/book/skillbook/dropped(mob/living/user)
	..()

	if(!istype(user))
		return

	user.remove_skills_buff(bonus_skillset)

/* departments stuff */

/obj/item/weapon/book/skillbook/engineering
	name = "Skills 101: Engineering"

	skills = list(
		/datum/skill/construction = SKILL_LEVEL_TRAINED,
		/datum/skill/engineering = SKILL_LEVEL_TRAINED,
		/datum/skill/atmospherics = SKILL_LEVEL_TRAINED,
		/datum/skill/civ_mech = SKILL_LEVEL_TRAINED,
	)

/obj/item/weapon/book/skillbook/medical
	name = "Skills 101: Medicine"

	skills = list(
		/datum/skill/medical = SKILL_LEVEL_TRAINED,
		/datum/skill/surgery = SKILL_LEVEL_TRAINED,
		/datum/skill/chemistry = SKILL_LEVEL_TRAINED,
	)

/obj/item/weapon/book/skillbook/science
	name = "Skills 101: Science"

	skills = list(
		/datum/skill/research = SKILL_LEVEL_TRAINED,
		/datum/skill/medical = SKILL_LEVEL_NOVICE,
		/datum/skill/surgery = SKILL_LEVEL_NOVICE,
		/datum/skill/construction = SKILL_LEVEL_NOVICE,
		/datum/skill/engineering = SKILL_LEVEL_NOVICE,
		/datum/skill/chemistry = SKILL_LEVEL_NOVICE,
	)

/obj/item/weapon/book/skillbook/robust
	name = "Skills 101: Robust"

	skills = list(
		/datum/skill/firearms = SKILL_LEVEL_TRAINED,
		/datum/skill/melee = SKILL_LEVEL_TRAINED,
		/datum/skill/combat_mech = SKILL_LEVEL_TRAINED,
		/datum/skill/police = SKILL_LEVEL_TRAINED,
	)

/* more specialized stuff */

/obj/item/weapon/book/skillbook/chemistry
	name = "Skills 101: Chemistry"

	skills = list(
		/datum/skill/chemistry = SKILL_LEVEL_TRAINED,
	)

/obj/item/weapon/book/skillbook/exosuits
	name = "Skills 101: Exosuits"

	skills = list(
		/datum/skill/civ_mech = SKILL_LEVEL_TRAINED,
		/datum/skill/combat_mech = SKILL_LEVEL_TRAINED,
	)
