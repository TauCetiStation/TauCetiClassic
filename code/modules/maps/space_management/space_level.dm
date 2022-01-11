/datum/space_level
	var/name = "NAME MISSING"
	var/list/traits
	var/z_value = 1 //actual z placement
	var/linkage = UNAFFECTED
	var/envtype = ENV_TYPE_SPACE // use SSenvironment.envtype[z_value] instead

/datum/space_level/New(new_z, new_name, list/new_traits = list())
	z_value = new_z
	name = new_name
	traits = new_traits
	linkage = new_traits[ZTRAIT_LINKAGE]
	envtype = new_traits[ZTRAIT_ENV_TYPE]

	SSenvironment.update(z_value, envtype)
