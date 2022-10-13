/obj/item/stack/sheet
	name = "sheet"
	full_w_class = SIZE_SMALL
	force = 5
	throwforce = 5
	max_amount = 50
	throw_speed = 3
	throw_range = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	var/perunit = 3750
	var/sheettype = null //this is used for girders in the creation of walls/false walls
	required_skills = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)
	var/can_be_wall = FALSE //this is used for allowed materials in the creation of walls/false walls
