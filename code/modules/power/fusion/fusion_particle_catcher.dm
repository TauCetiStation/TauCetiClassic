/obj/effect/fusion_particle_catcher
	icon = 'icons/effects/effects.dmi'
	density = TRUE
	anchored = TRUE
	invisibility = 101
	var/obj/effect/fusion_em_field/parent
	var/mysize = 0

	light_color = COLOR_BLUE

/obj/effect/fusion_particle_catcher/Destroy()
	. =..()
	parent.particle_catchers -= src
	parent = null

/obj/effect/fusion_particle_catcher/proc/SetSize(newsize)
	name = "collector [newsize]"
	mysize = newsize
	UpdateSize()

/obj/effect/fusion_particle_catcher/proc/AddParticles(name, quantity = 1)
	if(parent && parent.size >= mysize)
		parent.AddParticles(name, quantity)
		return TRUE
	return FALSE

/obj/effect/fusion_particle_catcher/proc/UpdateSize()
	if(parent.size >= mysize)
		density = TRUE
		name = "collector [mysize] ON"
	else
		density = FALSE
		name = "collector [mysize] OFF"

/obj/effect/fusion_particle_catcher/bullet_act(obj/item/projectile/Proj)
	parent.AddEnergy(Proj.damage)
	update_icon()
	return 0

/obj/effect/fusion_particle_catcher/Bumped(atom/AM)
	if(ismob(AM) && density)
		to_chat(AM, "<span class='warning'>A powerful force pushes you back.</span>")
	return 0
