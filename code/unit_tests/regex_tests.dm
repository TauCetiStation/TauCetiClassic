// Since BYOND seems rather unreliable with them.
/datum/unit_test/regex_IP
	name = "REGEX: IP_pattern should return only valid IPs."

	var/static/list/ips_to_test = list(
		"192.168.1.0" = TRUE,
		"255.0.0.0" = TRUE,
		"0.0.0.0" = TRUE,
		"256.0.0.0" = FALSE,
		"255.0.0.0.0" = FALSE,
		"255.0.0" = FALSE,
		"255.255.255.000" = FALSE,
		"09.09.09.09" = FALSE,
		"1.1.1.01" = FALSE,
		"-1.0.0.0" = FALSE,
		"3...3" = FALSE,
		"3.0.0.0." = FALSE,
		".3.0.0.0" = FALSE,
		"0.test.0.0" = FALSE,
	)

/datum/unit_test/regex_IP/start_test()
	var/failure = ""
	for(var/addr in ips_to_test)
		var/res = ips_to_test[addr]

		var/real_res = !isnull(sanitize_ip(addr))

		if(real_res != res)
			failure += "\nIP address failed sanitization: [addr]. It was considered [real_res ? "valid" : "invalid"] when it was not."

	if(failure)
		fail(failure)
	else
		pass("IP address sanitization works correctly.")
	return TRUE
