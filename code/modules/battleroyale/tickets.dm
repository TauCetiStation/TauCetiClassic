/obj/item/weapon/br_ticket
	name = "Battle Royal ticket"
	desc = "Ticket on show."
	var/role = "Observer"
	icon = 'icons/obj/br_tickets.dmi'
	icon_state = "observer"
	w_class = 1

/obj/item/weapon/br_ticket/observer
	name = "\"Observer\" Battle Royal ticket"
	desc = "You will see all the things."

/obj/item/weapon/br_ticket/budget
	name = "\"Budget\" Battle Royal ticket"
	desc = "Budgete (or maybe hardcore?) participant ticket, you start in only you pants."
	role = "Budget"
	icon_state = "budget"

/obj/item/weapon/br_ticket/participant
	name = "\"Participant\" Battle Royal ticket"
	role = "Participant"
	desc = "A regular ticket. No advantages."
	icon_state = "participant"

/obj/item/weapon/br_ticket/vip
	name = "\"VIP\" Battle Royal ticket"
	role = "VIP"
	desc = "You start with some bonus weapon."
	icon_state = "vip"

/obj/item/weapon/br_ticket/donator
	name = "\"Donator\" Battle Royal ticket"
	role = "Donator"
	desc = "You start with some bonus Durand."
	icon_state = "donator"