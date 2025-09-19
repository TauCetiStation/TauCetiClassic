// Nebula-dev\code\game\atoms_movable.dm

/atom/movable/proc/pushed(var/pushdir)
	set waitfor = FALSE
	step(src, pushdir)