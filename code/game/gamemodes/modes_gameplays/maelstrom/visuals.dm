/obj/effect/temp_visual/cult/sparks/purple
	name = "purple sparks"
	icon_state = "purplesparkles"
	icon = 'icons/effects/maelstrom_effects/purple_sparks.dmi'

/obj/effect/temp_visual/cult/sparks/quantum
	name = "quantum sparks"
	icon_state = "quantum_sparks"
	icon = 'icons/effects/maelstrom_effects/quantum_sparks.dmi'

/obj/effect/temp_visual/maelstrom/blood
	name = "blood teleport"
	duration = 12
	icon_state = "cultin"
	icon = 'icons/effects/maelstrom_effects/teleport_animation.dmi'

/obj/effect/temp_visual/maelstrom/blood/out
	icon_state = "cultout"
	icon = 'icons/effects/maelstrom_effects/teleport_animation.dmi'

/obj/effect/forcefield/cult/blue
	icon_state = "techno_field"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/maelstrom_effects/blue_forcefield.dmi'

/obj/effect/forcefield/cult/blue/proc/register_holder(obj/holder)
	RegisterSignal(holder, COMSIG_PARENT_QDELETING, PROC_REF(on_holder_qdel))

/obj/effect/forcefield/cult/blue/proc/on_holder_qdel()
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/temp_visual/portal
	icon = 'icons/obj/objects.dmi'
	icon_state = "bluespace_wormhole_exit"
