// Nebula-dev\code\game\objects\__objs.dm (objs.dm)

/obj/try_fluid_push(volume, strength)
	return ..() && w_class <= round(strength/20)
