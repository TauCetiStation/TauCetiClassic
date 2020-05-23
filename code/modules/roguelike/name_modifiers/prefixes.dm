/datum/name_modifier/prefix
	group = RL_GROUP_PREFIX

/datum/name_modifier/prefix/affect(atom/A)
	A.name = "[get_txt()] [A.name]"



/datum/name_modifier/prefix/healthy
	text = "healthy"

/datum/name_modifier/prefix/frail
	text = "frail"

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
