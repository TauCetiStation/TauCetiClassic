/**
 * handles adding/removing verbs and updating the stat panel browser
 *
 * pass the verb type path to this instead of adding it directly to verbs so the statpanel can update
 * Arguments:
 * * ... - typepath to a verb, or a list of verbs, supports lists of lists
 */

/mob/proc/add_verb(...)
	var/verbs_list = get_verbs_list(args)
	verbs += verbs_list
	src << output("[get_output_verbs_list(verbs_list)];", "statbrowser:add_verb_list")

/client/proc/add_verb(...)
	var/verbs_list = get_verbs_list(args)
	verbs += verbs_list
	src << output("[get_output_verbs_list(verbs_list)];", "statbrowser:add_verb_list")

/mob/proc/remove_verb(...)
	var/list/verbs_list = get_verbs_list(args)
	verbs -= verbs_list
	src << output("[get_output_verbs_list(verbs_list)];", "statbrowser:remove_verb_list")

/client/proc/remove_verb(...)
	var/list/verbs_list = get_verbs_list(args)
	verbs -= verbs_list
	src << output("[get_output_verbs_list(verbs_list)];", "statbrowser:remove_verb_list")

/proc/get_verbs_list(...)
	. = list()
	for(var/verb_or_list_to_add in args)
		if(!islist(verb_or_list_to_add))
			. += verb_or_list_to_add
		else
			var/list/verb_listref = verb_or_list_to_add
			var/list/elements_to_process = verb_listref.Copy()
			while(length(elements_to_process))
				var/element_or_list = elements_to_process[length(elements_to_process)] //Last element
				elements_to_process.len--
				if(islist(element_or_list))
					elements_to_process += element_or_list //list/a += list/b adds the contents of b into a, not the reference to the list itself
				else
					. += element_or_list

/proc/get_output_verbs_list(verbs_list)
	var/list/output_list = list()
	for(var/thing in verbs_list)
		var/procpath/verb_to_remove = thing
		output_list[++output_list.len] = list(verb_to_remove.category, verb_to_remove.name)
	return url_encode(json_encode(output_list))
