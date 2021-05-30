/datum/name_modifier/prefix
	group = RL_GROUP_PREFIX

/datum/name_modifier/prefix/affect(atom/A)
	A.name = "[get_txt()] [A.name]"

/datum/name_modifier/prefix/affect_text(txt)
	return "[get_txt()] [txt]"


/datum/name_modifier/prefix/healthy
	text = "healthy"

	priority = 2

/datum/name_modifier/prefix/frail
	text = "frail"

	priority = 2

/datum/name_modifier/prefix/ghostly
	text = "ghostly"

/datum/name_modifier/prefix/slimy
	text = "slimy"

/datum/name_modifier/prefix/cursed
	text = "cursed"

/datum/name_modifier/prefix/friendly
	text = "friendly"

/datum/name_modifier/prefix/strong
	text = "strong"

	priority = 2

/datum/name_modifier/prefix/singular
	text = "singular"

/datum/name_modifier/prefix/invisible
	text = "invisible"

/datum/name_modifier/prefix/angelic
	text = "angelic"
