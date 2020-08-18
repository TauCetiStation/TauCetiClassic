/obj/machinery/disease2/biodestroyer
	name = "Biohazard destroyer"
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "disposalbio"
	var/list/accepts = list(/obj/item/clothing,/obj/item/weapon/virusdish,/obj/item/weapon/cureimplanter,/obj/item/weapon/diseasedisk,/obj/item/weapon/reagent_containers)
	density = 1
	anchored = 1

/obj/machinery/disease2/biodestroyer/attackby(obj/I, mob/user)
	for(var/path in accepts)
		if(I.type in typesof(path))
			user.drop_item()
			qdel(I)
			add_overlay(image('icons/obj/pipes/disposal.dmi', "dispover-handle"))
			return

	user.drop_from_inventory(I, loc)

	audible_message("[bicon(src)] <span class='notice'>The [src.name] beeps</span>")
