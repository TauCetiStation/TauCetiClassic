/mob/var/skincmds = list()
/obj/proc/SkinCmd(mob/user, data)

/proc/SkinCmdRegister(mob/user, name, O)
	user.skincmds[name] = O

/mob/verb/skincmd(data as text)
	set hidden = 1

	var/ref = copytext(data, 1, findtext(data, ";"))
	if (src.skincmds[ref] != null)
		var/obj/a = src.skincmds[ref]
		a.SkinCmd(src, copytext(data, findtext(data, ";") + 1))
