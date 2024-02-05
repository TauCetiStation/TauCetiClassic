/obj/effect/temp_visual/cult/sparks/purple
	name = "purple sparks"
	icon_state = "purplesparkles"

/obj/effect/temp_visual/cult/sparks/quantum
	name = "quantum sparks"
	icon_state = "quantum_sparks"

/obj/effect/temp_visual/maelstrom/blood
	name = "blood teleport"
	duration = 12
	icon_state = "cultin"

/obj/effect/temp_visual/maelstrom/blood/out
	icon_state = "cultout"

/obj/effect/forcefield/cult/blue
	icon_state = "techno_field"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/forcefield/cult/blue/proc/register_holder(obj/holder)
	RegisterSignal(holder, COMSIG_PARENT_QDELETING, PROC_REF(on_holder_qdel))

/obj/effect/forcefield/cult/blue/proc/on_holder_qdel()
	SIGNAL_HANDLER
	qdel(src)

