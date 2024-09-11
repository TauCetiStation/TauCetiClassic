/*
	atom.particles
		Particle vars that affect the entire set (generators are not allowed for these)
			Var	Type	Description
			width	num	Size of particle image in pixels
			height
			count	num	Maximum particle count
			spawning	num	Number of particles to spawn per tick (can be fractional)
			bound1	vector	Minimum particle position in x,y,z space; defaults to list(-1000,-1000,-1000)
			bound2	vector	Maximum particle position in x,y,z space; defaults to list(1000,1000,1000)
			gravity	vector	Constant acceleration applied to all particles in this set (pixels per squared tick)
			gradient	color gradient	Color gradient used, if any
			transform	matrix	Transform done to all particles, if any (can be higher than 2D)
		Vars that apply when a particle spawns
			lifespan	num	Maximum life of the particle, in ticks
			fade	num	Fade-out time at end of lifespan, in ticks
			icon	icon	Icon to use, if any; no icon means this particle will be a dot
			Can be assigned a weighted list of icon files, to choose an icon at random
			icon_state	text	Icon state to use, if any
			Can be assigned a weighted list of strings, to choose an icon at random
			color	num or color	Particle color; can be a number if a gradient is used
			color_change	num	Color change per tick; only applies if gradient is used
			position	num	x,y,z position, from center in pixels
			velocity	num	x,y,z velocity, in pixels
			scale	vector (2D)	Scale applied to icon, if used; defaults to list(1,1)
			grow	num	Change in scale per tick; defaults to list(0,0)
			rotation	num	Angle of rotation (clockwise); applies only if using an icon
			spin	num	Change in rotation per tick
			friction	num	Amount of velocity to shed (0 to 1) per tick, also applied to acceleration from drift
		Vars that are evalulated every tick
			drift	vector	Added acceleration every tick; e.g. a circle or sphere generator can be applied to produce snow or ember effects
*/

//This should should have a default at some point
var/global/list/master_particle_info = list()

//some helpyers
/datum/particle_editor/proc/ListToMatrix(list/L)
	//Normal Matrixes allow 6
	switch(length(L))
		if(6)
			return matrix(L[1], L[2], L[3],
						  L[4], L[5], L[6])

/datum/particle_editor/proc/stringToList(str, toNum = FALSE)
	var/static/regex/regex = regex(@"(?<!\\),")
	. = splittext(str, regex)
	if(toNum)
		for(var/i = 1; i <= length(.); ++i)
			.[i] = text2num(.[i])

/datum/particle_editor/proc/stringToMatrix(str)
	return ListToMatrix(stringToList(str))

/datum/particle_editor
	var/atom/movable/target

/datum/particle_editor/New(atom/target)
	src.target = target

/datum/particle_editor/tgui_state(mob/user)
	return global.admin_state

/datum/particle_editor/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Particool")
		ui.open()

/datum/particle_editor/tgui_static_data(mob/user)
	var/list/data = list()
	data["particle_info"] = global.master_particle_info
	return data

/datum/particle_editor/tgui_data()
	var/list/data = list()
	data["target_name"] = target.name
	data["target_particle"] = getParticleVars()
	return data

/datum/particle_editor/proc/getParticleVars()
	. = target.particles ? target.particles.vars : null

//expects an assoc list of name, type, value - type must be in this list
/datum/particle_editor/proc/translate_value(list/L)
	//string/float/int come in as the correct type, so just whack em in

	switch(L["type"])
		if("string") return L["value"]
		if("float") return L["value"]
		if("int") return L["value"]
		if("color") return L["value"]
		if("list") return stringToList(L["value"])
		if("numList") return stringToList(L["value"],TRUE)
		if("matrix") return ListToMatrix(L["value"])
		if("generator") return generateGenerator(L["value"]) // This value should be a new list, if it isn't then we will explode

/datum/particle_editor/proc/generateGenerator(L)

	/*
	Generator type | Result | Description
	num            | num    | A random number between A and B.
	vector         | vector | A random vector on a line between A and B.
	box            | vector | A random vector within a box whose corners are at A and B.
	color          | color  | (string) or color matrix	Result type depends on whether A or B are matrices or not. The result is interpolated between A and B; components are not randomized separately.
	circle         | vector | A random XY-only vector in a ring between radius A and B, centered at 0,0.
	sphere         | vector | A random vector in a spherical shell between radius A and B, centered at 0,0,0.
	square         | vector | A random XY-only vector between squares of sizes A and B. (The length of the square is between A*2 and B*2, centered at 0,0.)
	cube           | vector | A random vector between cubes of sizes A and B. (The length of the cube is between A*2 and B*2, centered at 0,0,0.)
	*/

	// I write code like this because I hate myself
	var/a = length(stringToList(L["a"], TRUE)) > 1 ? stringToList(L["a"], TRUE) : text2num(L["a"])
	var/b = length(stringToList(L["b"], TRUE)) > 1 ? stringToList(L["b"], TRUE) : text2num(L["b"])

	switch(L["genType"])
		if("num")    return generator(L["genType"], a, b)
		if("vector") return generator(L["genType"], a, b)
		if("box")    return generator(L["genType"], a, b)
		if("color") //Color can be string or matrix
			a = length(a) > 1 ? ListToMatrix(a) : a
			b = length(a) > 1 ? ListToMatrix(b) : b
			return generator(L["genType"], a, b)
		if("circle") return generator(L["genType"], a, b)
		if("sphere") return generator(L["genType"], a, b)
		if("square") return generator(L["genType"], a, b)
		if("cube")   return generator(L["genType"], a, b)
	return null

/datum/particle_editor/tgui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("add_particle")
			target.add_particle()
			. = TRUE
		if("remove_particle")
			target.remove_particle()
			. = TRUE
		if("modify_particle_value")
			target.modify_particle_value(params["new_data"]["name"], translate_value(params["new_data"]))
			. = TRUE
		if("modify_color_value")
			var/new_color = input(usr, "Pick new particle color", "Particool Colors!") as color|null
			if(new_color)
				target.modify_particle_value("color",new_color)
				. = TRUE
		if("modify_icon_value")
			var/icon/new_icon = input("Pick icon:", "Icon") as null|icon
			if(new_icon && target.particles)
				target.modify_particle_value("icon", new_icon)
				. = TRUE


//movable procs n stuff

/atom/movable/proc/add_particle()
	particles = new /particles

/atom/movable/proc/remove_particle()
	particles = null

/atom/movable/proc/modify_particle_value(varName, varVal)
	if(!particles)
		return
	if(isnull(varVal))
		particles.vars[varName] = initial(particles.vars[varName])
	else
		particles.vars[varName] = varVal
