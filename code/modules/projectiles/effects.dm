/obj/effect/projectile
	icon = 'icons/effects/projectiles.dmi'
	icon_state = "bolt"
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	light_shadows = FALSE
	var/time_to_live = 3

/obj/effect/projectile/atom_init()
	. = ..()
	if(light_special_on)
		set_light(light_range,light_power,light_color)

/obj/effect/projectile/proc/set_transform(matrix/M)
	if(istype(M))
		transform = M

/obj/effect/projectile/proc/activate()
	if(time_to_live)
		QDEL_IN(src, time_to_live)

//----------------------------
// Laser beam
//----------------------------
/obj/effect/projectile/laser/tracer
	icon_state = "beam"
	light_special_on = TRUE
	light_range = 2
	light_power = 2
	light_color = "#ff0000"

/obj/effect/projectile/laser/muzzle
	icon_state = "muzzle_laser"

/obj/effect/projectile/laser/impact
	icon_state = "impact_laser"

//----------------------------
// Blue laser beam
//----------------------------
/obj/effect/projectile/laser_blue/tracer
	icon_state = "beam_blue"
	light_special_on = TRUE
	light_range = 2
	light_power = 2
	light_color = "#0000ff"

/obj/effect/projectile/laser_blue/muzzle
	icon_state = "muzzle_blue"

/obj/effect/projectile/laser_blue/impact
	icon_state = "impact_blue"

//----------------------------
// Omni laser beam
//----------------------------
/obj/effect/projectile/laser_omni/tracer
	icon_state = "beam_omni"
	light_special_on = TRUE
	light_range = 2
	light_power = 2
	light_color = "#00ffff"

/obj/effect/projectile/laser_omni/muzzle
	icon_state = "muzzle_omni"

/obj/effect/projectile/laser_omni/impact
	icon_state = "impact_omni"

//----------------------------
// Xray laser beam
//----------------------------
/obj/effect/projectile/xray/tracer
	icon_state = "xray"
	light_special_on = TRUE
	light_range = 2
	light_power = 2
	light_color = "#00ff00"

/obj/effect/projectile/xray/muzzle
	icon_state = "muzzle_xray"

/obj/effect/projectile/xray/impact
	icon_state = "impact_xray"

//----------------------------
// Heavy laser beam
//----------------------------
/obj/effect/projectile/laser_heavy/tracer
	icon_state = "beam_heavy"
	light_special_on = TRUE
	light_range = 2
	light_power = 3
	light_color = "#ff0000"

/obj/effect/projectile/laser_heavy/muzzle
	icon_state = "muzzle_beam_heavy"

/obj/effect/projectile/laser_heavy/impact
	icon_state = "impact_beam_heavy"

//----------------------------
// Pulse laser beam
//----------------------------
/obj/effect/projectile/laser_pulse/tracer
	icon_state = "u_laser"
	light_special_on = TRUE
	light_range = 2
	light_power = 2
	light_color = "#0000ff"

/obj/effect/projectile/laser_pulse/muzzle
	icon_state = "muzzle_u_laser"

/obj/effect/projectile/laser_pulse/impact
	icon_state = "impact_u_laser"

//----------------------------
// Pulse muzzle effect only
//----------------------------
/obj/effect/projectile/pulse/muzzle
	icon_state = "muzzle_pulse"
	light_special_on = TRUE
	light_range = 2
	light_power = 2
	light_color = "#0000ff"

//----------------------------
// Emitter beam
//----------------------------
/obj/effect/projectile/emitter/tracer
	icon_state = "emitter"
	//light_range = 1.5
	//light_power = 2
	//light_color = "#01df74"

/obj/effect/projectile/emitter/muzzle
	icon_state = "muzzle_emitter"

/obj/effect/projectile/emitter/impact
	icon_state = "impact_emitter"

//----------------------------
// Stun beam
//----------------------------
/obj/effect/projectile/stun/tracer
	icon_state = "stun"
	light_special_on = TRUE
	light_range = 2
	light_power = 2
	light_color = "#f2f5a9"

/obj/effect/projectile/stun/muzzle
	icon_state = "muzzle_stun"

/obj/effect/projectile/stun/impact
	icon_state = "impact_stun"

//----------------------------
// Bullet
//----------------------------
/obj/effect/projectile/bullet/tracer
	icon_state = "tracer_bullet"

/obj/effect/projectile/bullet/muzzle
	icon_state = "muzzle_bullet"
	light_special_on = TRUE
	light_range = 3
	light_power = 2
	light_color = "#f2f5a9"

/obj/effect/projectile/bullet/impact
	icon_state = "impact_bullet"

//----------------------------
// New
//----------------------------
/obj/effect/projectile/energy/muzzle
	icon_state = "muzzle_energy"
	light_special_on = TRUE
	light_range = 2
	light_power = 2
	light_color = "#2be4b8"

/obj/effect/projectile/rails
	time_to_live = 15

/obj/effect/projectile/rails/tracer
	icon_state = "rails_beam"

/obj/effect/projectile/rails/impact
	icon_state = "rails_impact"
