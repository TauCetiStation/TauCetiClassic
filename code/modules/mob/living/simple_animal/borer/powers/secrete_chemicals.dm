/obj/effect/proc_holder/borer/active/noncontrol/secrete_chemicals
	name = "Secrete Chemicals"
	desc = "Push some chemicals into your host's bloodstream."
	chemicals = 50
	check_docility = FALSE // cause we want to inject sucrase to wake up from docility and also why not

/obj/effect/proc_holder/borer/active/noncontrol/secrete_chemicals/on_gain(mob/living/simple_animal/borer/B)
	..()
	B.synthable_chems += list("bicaridine" = 15, "alkysine" = 15, "tramadol" = 15, "hyperzine" = 10)

/obj/effect/proc_holder/borer/active/noncontrol/secrete_chemicals/on_lose(mob/living/simple_animal/borer/B)
	B.synthable_chems -= list("bicaridine" = 15, "alkysine" = 15, "tramadol" = 15, "hyperzine" = 10)

/obj/effect/proc_holder/borer/active/noncontrol/secrete_chemicals/activate()
	var/chem = input("Select a chemical to secrete.", "Chemicals") as null|anything in holder.synthable_chems
	if(!chem)
		return

	if(!can_activate(holder)) //Sanity check.
		return

	if(!use_chemicals())
		return
	to_chat(holder, "<span class='warning'><b>You squirt a measure of [chem] from your reservoirs into [holder.host]'s bloodstream.</b></span>")
	holder.host.reagents.add_reagent(chem, holder.synthable_chems[chem])
