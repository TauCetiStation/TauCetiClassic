var/const/RADIO_WIRE_SIGNAL   = 1
var/const/RADIO_WIRE_RECEIVE  = 2
var/const/RADIO_WIRE_TRANSMIT = 4

/datum/wires/radio
	holder_type = /obj/item/device/radio
	wire_count = 3

/datum/wires/radio/can_use()
	var/obj/item/device/radio/R = holder
	return R.b_stat

/datum/wires/radio/update_pulsed(index)
	var/obj/item/device/radio/R = holder

	switch(index)
		if(RADIO_WIRE_SIGNAL)
			R.listening = !R.listening && !is_index_cut(RADIO_WIRE_RECEIVE)
			R.broadcasting = R.listening && !is_index_cut(RADIO_WIRE_TRANSMIT)

		if(RADIO_WIRE_RECEIVE)
			R.listening = !R.listening && !is_index_cut(RADIO_WIRE_SIGNAL)

		if(RADIO_WIRE_TRANSMIT)
			R.broadcasting = !R.broadcasting && !is_index_cut(RADIO_WIRE_SIGNAL)

/datum/wires/radio/update_cut(index, mended)
	var/obj/item/device/radio/R = holder

	switch(index)
		if(RADIO_WIRE_SIGNAL)
			R.listening = mended && !is_index_cut(RADIO_WIRE_RECEIVE)
			R.broadcasting = mended && !is_index_cut(RADIO_WIRE_TRANSMIT)

		if(RADIO_WIRE_RECEIVE)
			R.listening = mended && !is_index_cut(RADIO_WIRE_SIGNAL)

		if(RADIO_WIRE_TRANSMIT)
			R.broadcasting = mended && !is_index_cut(RADIO_WIRE_SIGNAL)