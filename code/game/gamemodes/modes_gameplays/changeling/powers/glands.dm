/obj/effect/proc_holder/changeling/glands
	name = "Engorged Chemical Glands"
	desc = "Our chemical glands swell, permitting us to store more chemicals inside of them."
	helptext = "Allows us to store an extra 25 units of chemicals."
	genomecost = 2
	chemical_cost = -1

/obj/effect/proc_holder/changeling/glands/on_purchase(mob/user)
	..()
	role.chem_storage += 25

/obj/effect/proc_holder/changeling/glands/Destroy()
	. = ..()
	role.chem_storage -= 25
	role.chem_charges = min(role.chem_charges, role.chem_storage)
