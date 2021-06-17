/obj/effect/proc_holder/borer/active/noncontrol/secrete_chemicals
	name = "Secrete Chemicals"
	desc = "Push some chemicals into your host's bloodstream."
	chemicals = 50

/obj/effect/proc_holder/borer/active/noncontrol/secrete_chemicals/activate(mob/living/simple_animal/borer/B)
	if(B.incapacitated())
		to_chat(B, "You cannot secrete chemicals in your current state.")
		return

	if(B.docile)
		to_chat(B, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return

	var/chem = input("Select a chemical to secrete.", "Chemicals") as null|anything in list("bicaridine","tramadol","hyperzine","alkysine")
	if(!chem)
		return

	if(!B.host || B.controlling || B.docile || B.incapacitated()) //Sanity check.
		return

	if(!..())
		return
	to_chat(B, "<span class='warning'><B>You squirt a measure of [chem] from your reservoirs into [B.host]'s bloodstream.</B></span>")
	B.host.reagents.add_reagent(chem, 15)
