/obj/item/ammo_casing/proc/fire(atom/target, mob/living/user, params, quiet, obj/item/weapon/gun/G)
	for(var/i = max(1, pellets), i > 0, i--)
		var/curloc = user.loc
		var/targloc = get_turf(target)
		ready_proj(target, user, quiet)
		if(variance)
			targloc = spread(targloc, curloc, variance)
		if(!throw_proj(target, targloc, user, params, G))
			return 0
		if(i > 1)
			newshot()
	user.newtonian_move(get_dir(target, user))
	update_icon()
	return 1

/obj/item/ammo_casing/proc/ready_proj(atom/target, mob/living/user, quiet)
	if(!BB)
		return
	BB.original = target
	BB.firer = user
	BB.def_zone = user.zone_sel.selecting
	BB.silenced = quiet
	return

/obj/item/ammo_casing/proc/throw_proj(atom/target, turf/targloc, mob/living/user, params, obj/item/weapon/gun/G)
	var/turf/curloc = user.loc
	if (!istype(targloc) || !istype(curloc) || !BB)
		return 0
	if(G.w_mod)
		BB.dispersion += G.w_mod.accuracy
		BB.damage *= G.w_mod.damage
		if(G.w_mod.crit_chance && prob(G.w_mod.crit_chance))
			BB.damage *= G.w_mod.crit_mod
		BB.step_delay *= G.w_mod.speed
	if(targloc == curloc)
		if(target) //if the target is right on our location we go straight to bullet_act()
			target.bullet_act(BB, BB.def_zone)
		qdel(BB)
		BB = null
		return 1
	BB.loc = get_turf(user)
	BB.starting = get_turf(user)
	BB.current = curloc
	BB.yo = targloc.y - curloc.y
	BB.xo = targloc.x - curloc.x

	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			BB.p_x = text2num(mouse_control["icon-x"])
		if(mouse_control["icon-y"])
			BB.p_y = text2num(mouse_control["icon-y"])

	if(BB)
		//randomize clickpoint a bit based on dispersion
		if(BB.dispersion)
			var/radius = round((BB.dispersion*0.443)*world.icon_size*0.8) //0.443 = sqrt(pi)/4 = 2a, where a is the side length of a square that shares the same area as a circle with diameter = dispersion
			BB.p_x = between(0, BB.p_x + rand(-radius, radius), world.icon_size)
			BB.p_y = between(0, BB.p_y + rand(-radius, radius), world.icon_size)
		BB.process()
	BB = null
	return 1

/obj/item/ammo_casing/proc/spread(var/turf/target, var/turf/current, var/distro)
	var/dx = abs(target.x - current.x)
	var/dy = abs(target.y - current.y)
	return locate(target.x + round(gaussian(0, distro) * (dy+2)/8, 1), target.y + round(gaussian(0, distro) * (dx+2)/8, 1), target.z)
