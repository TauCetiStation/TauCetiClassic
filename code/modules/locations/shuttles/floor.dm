/turf/simulated/shuttle/floor/mining
	icon = 'code/modules/locations/shuttles/shuttle_mining.dmi'

/turf/simulated/shuttle/floor/shuttle_new
	icon = 'code/modules/locations/shuttles/shuttle.dmi'

/turf/simulated/shuttle/floor/wagon
	name = "floor"
	icon = 'code/modules/locations/shuttles/wagon.dmi'
	icon_state = "floor"

/turf/simulated/shuttle/floor/erokez
	name = "floor"
	icon = 'code/modules/locations/shuttles/erokez.dmi'
	icon_state = "floor1"

/turf/simulated/shuttle/floor/cargo
	name = "floor"
	icon = 'code/modules/locations/shuttles/cargofloor.dmi'
	icon_state = "1"

//��������� � ����� ������ ������� ��� �������, � ���������������� �� �� ���������� �� ����������.
//����� ��� ������� ����������������, ��� � ������� �� �����������.
//======
//������! ��� ����?
/turf/space/shuttle
	icon = 'code/modules/locations/shuttles/space.dmi'
	icon_state = "1swall_s"

/turf/space/shuttle/New()
	icon_state = "[rand(1,4)]swall_s"
