/datum/unit_test/skills
    name = "SKILLS: Base" // change this if you creating new test

/datum/unit_test/skills/proc/create_dummy(skillset = null)
    var/mob/living/carbon/human/H = new /mob/living/carbon/human()
    H.mind = new /datum/mind(555)
    if(!isnull(skillset))
        H.mind.skills.add_available_skillset(skillset)
        H.mind.skills.maximize_active_skills()
    return H

/datum/unit_test/skills/proc/create_multiple_dummies(skillsets)
    var/result = list()
    for(var/skillset in skillsets)
        result += create_dummy(skillset)
    return result

/datum/unit_test/skills/start_test()
    var/mob/living/carbon/human/dummy = create_dummy()
    dummy.mind.skills.add_available_skillset(/datum/skillset/max)
    dummy.mind.skills.maximize_active_skills()
    pass("Created dummy with skills")
    return TRUE

/datum/unit_test/skills/fumbling
	name = "SKILLS: Handle fumbling"

//no fumbling if you are skilled enough
/datum/unit_test/skills/fumbling/start_test()
    var/mob/living/carbon/human/max_dummy = create_dummy(/datum/skillset/max)
    var/t = world.time
    handle_fumbling(max_dummy, max_dummy, SKILL_TASK_AVERAGE, all_skills)
    t = t - world.time
    assert_equal(t, 0)
    return TRUE

/datum/unit_test/skills/melee
	name = "SKILLS: Melee testing"

/datum/unit_test/skills/melee/start_test()
    var/list/test_dummies = create_multiple_dummies(list(/datum/skillset/clown,/datum/skillset/test_subject, 
                                                        /datum/skillset/cadet, /datum/skillset/officer))
    var/list/expected_damage = list(10.4, 13, 15.6, 18.2)
    var/base_damage = 13 //combat knife
    var/list/result = list()
    for(var/mob/living/carbon/human/dummy in test_dummies)
        result += apply_skill_bonus(dummy, base_damage, list(/datum/skill/melee), 0.2)
    return assert_equal_list(expected_damage, result)

/datum/unit_test/skills/civ_mecha
	name = "SKILLS: Civ Mecha skill speed testing"

/datum/unit_test/skills/civ_mecha/start_test()
    var/list/test_dummies = create_multiple_dummies(list(/datum/skillset/test_subject, /datum/skillset/research_assistant, /datum/skillset/engineer, /datum/skillset/recycler, /datum/skillset/quartermaster))
    var/list/expected_speeds = list(8.4, 7.2, 6, 4.8, 3.6)
    var/list/result = list()
    for(var/mob/living/carbon/human/dummy in test_dummies)
        result += apply_skill_bonus(dummy, 6, list(/datum/skill/civ_mech/trained), -0.2)
    return assert_equal_list(expected_speeds, result)


/datum/unit_test/skills/combat_mecha
	name = "SKILLS: Combat Mecha skill speed testing"

/datum/unit_test/skills/combat_mecha/start_test()
    var/list/test_dummies = create_multiple_dummies(list(/datum/skillset/test_subject, /datum/skillset/officer, /datum/skillset/hos))
    var/list/expected_speeds = list(8.4, 7.2, 6)
    var/list/result = list()
    for(var/mob/living/carbon/human/dummy in test_dummies)
        result += apply_skill_bonus(dummy, 6, list(/datum/skill/combat_mech/master), -0.2)
    return assert_equal_list(expected_speeds, result)

/datum/unit_test/skills/police_handcuffs
	name = "SKILLS: Police handcuffing testing"

/datum/unit_test/skills/police_handcuffs/start_test()
    var/list/test_dummies = create_multiple_dummies(list(/datum/skillset/test_subject, /datum/skillset/cadet, /datum/skillset/officer))
    var/list/expected_speeds = list(HUMAN_STRIP_DELAY, 28, 16)
    var/list/result = list()
    for(var/mob/living/carbon/human/dummy in test_dummies)
        result += apply_skill_bonus(dummy, HUMAN_STRIP_DELAY, list(/datum/skill/police), multiplier = -0.3)
    return assert_equal_list(expected_speeds, result)

/datum/unit_test/skills/surgeon
	name = "SKILLS: Surgeon is better than cyborg"

