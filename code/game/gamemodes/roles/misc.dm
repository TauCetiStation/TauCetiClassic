/datum/role/protector
	name = PROTECTOR
	id = PROTECTOR

	logo_state = "protector-logo"

/datum/role/protector/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "���� ������� �������� ����-�� �� �������!")
	to_chat(antag.current, "������, ���� �� ��� ��������� ������� �������, � ��������� ��������� ���� �� ��������� � �������� ���� ������� ���� � ������� ������.")
	to_chat(antag.current, "���, �������������� ������� ������ �� �������������.")

/datum/role/protector/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/target/assassinate)
	AppendObjective(/datum/objective/escape)
	return TRUE
