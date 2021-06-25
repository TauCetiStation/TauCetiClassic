/obj/effect/proc_holder/borer/stealth
	name = "Stealth"
	desc = "You won't be visible on Medical HUDs when controlling someone."
	cost = 1
	requires_upgrades = list(/obj/effect/proc_holder/borer/active/hostless/invis)

/obj/effect/proc_holder/borer/stealth/on_gain()
	holder.stealthy = TRUE
