/proc/is_incapacitated(mob/M, intentional)
	return M.incapacitated()

/proc/is_stat(stat, mob/M, intentional)
	return M.stat <= stat

/proc/is_not_intentional(mob/M, intentional)
	return !intentional
