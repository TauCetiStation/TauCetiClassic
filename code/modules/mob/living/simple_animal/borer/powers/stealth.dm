/obj/effect/proc_holder/borer/stealth
	name = "Stealth"
	desc = "You won't be visible on Medical HUDs when controlling someone."
	cost = 1
	requires_t = list(/obj/effect/proc_holder/borer/active/hostless/invis)

/obj/effect/proc_holder/borer/stealth/on_gain(mob/living/simple_animal/borer/B)
	B.stealthy = TRUE

/obj/effect/proc_holder/borer/stealth/on_lose(mob/living/simple_animal/borer/B)
	B.stealthy = FALSE
