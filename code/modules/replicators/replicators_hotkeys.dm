/mob/living/simple_animal/hostile/replicator/mode()
	var/obj/effect/proc_holder/spell/no_target/toggle_corridor_construction/TCC = locate() in src
	if(TCC)
		TCC.Click()

/mob/living/simple_animal/hostile/replicator/drop_item(atom/Target)
	var/obj/effect/proc_holder/spell/no_target/replicator_construct/trap/T = locate() in src
	if(T)
		T.Click()

/mob/living/simple_animal/hostile/replicator/swap_hand()
	var/obj/effect/proc_holder/spell/no_target/transfer_to_idle/TTI = locate() in src
	if(TTI)
		TTI.Click()
