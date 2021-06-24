/obj/effect/proc_holder/borer/active/noncontrol/secrete_chemicals
	name = "Secrete Chemicals"
	desc = "Push some chemicals into your host's bloodstream."
	chemicals = 50

/obj/effect/proc_holder/borer/active/noncontrol/secrete_chemicals/on_gain(mob/living/simple_animal/borer/B)
	B.synthable_chems += list("bicaridine" = 15, "alkysine" = 15, "tramadol" = 15, "hyperzine" = 10)

/obj/effect/proc_holder/borer/active/noncontrol/secrete_chemicals/on_lose(mob/living/simple_animal/borer/B)
	B.synthable_chems -= list("bicaridine" = 15, "alkysine" = 15, "tramadol" = 15, "hyperzine" = 10)

/obj/effect/proc_holder/borer/active/noncontrol/secrete_chemicals/activate(mob/living/simple_animal/borer/B)
	if(B.incapacitated())
		to_chat(B, "You cannot secrete chemicals in your current state.")
		return

	var/chem = input("Select a chemical to secrete.", "Chemicals") as null|anything in B.synthable_chems
	if(!chem)
		return

	if(!B.host || B.controlling || B.docile || B.incapacitated()) //Sanity check.
		return

	if(!use_chemicals(B))
		return
	to_chat(B, "<span class='warning'><B>You squirt a measure of [chem] from your reservoirs into [B.host]'s bloodstream.</B></span>")
	B.host.reagents.add_reagent(chem, B.synthable_chems[chem])
