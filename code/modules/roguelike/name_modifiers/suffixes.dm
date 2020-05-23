/datum/name_modifier/suffix
	group = RL_GROUP_SUFFIX

/datum/name_modifier/suffix/affect(atom/A)
	A.name = "[A.name] [get_txt()]"
