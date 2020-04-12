/*
n_Json v11.3.21
*/

//outdated, use json_decode
/proc/json2list(json)
	var/static/json_reader/_jsonr = new()
	return _jsonr.ReadObject(_jsonr.ScanJson(json))

//outdated, use json_encode
/proc/list2json(list/L, var/cached_data = null)
	var/static/json_writer/_jsonw = new()
	return _jsonw.WriteObject(L, cached_data)
