// Nebula-dev\code\game\atoms_movable.dm

/atom/movable/proc/pushed(pushdir)
	set waitfor = FALSE
	step(src, pushdir)
