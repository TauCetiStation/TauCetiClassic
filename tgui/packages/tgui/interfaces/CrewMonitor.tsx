import { sortBy } from 'es-toolkit';
import { uniq } from 'es-toolkit/compat';
import { useEffect, useMemo, useState } from 'react';
import {
  Box,
  Icon,
  Input,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';
import { useBackend } from '../backend';
import { NanoMap, type NanoMapStaticPayload } from '../components';
import { Window } from '../layouts';

type BoxProps = React.ComponentProps<typeof Box>;

const pauseEvent = (e: React.MouseEvent) => {
  if (e.stopPropagation) e.stopPropagation();
  if (e.preventDefault && e.cancelable) e.preventDefault();
  return false;
};

const createAbbreviation = (text: string): string => {
  const words = text.split(' ');

  if (words.length <= 1 || (words.length <= 3 && text.length < 10)) {
    return text;
  }

  const abbreviation = `${words.map((word) => word.charAt(0).toUpperCase()).join('.')}.`;

  return abbreviation;
};

type CrewIcon = {
  icon: string;
  color: string;
};

const pickCrewIcon = (crewMember: CrewMember): CrewIcon => {
  let totalDamage = 0;
  const { vitals } = crewMember;
  if (vitals) {
    totalDamage = vitals.brute + vitals.fire + vitals.tox + vitals.oxy;
  }

  let icon: string | string[] = 'user';
  let color = 'good';
  if (crewMember.dead) {
    icon = 'skull';
    color = 'bad';
  } else if (totalDamage > 100) {
    icon = 'user-injured';
    color = 'orange';
  } else if (totalDamage > 30) {
    icon = 'user-injured';
    color = 'yellow';
  }

  return { icon, color };
};

enum SensorType {
  off = 0,
  binary = 1,
  vital = 2,
  tracking = 3,
}

type CrewMemberPosition = {
  area: string;
  x: number;
  y: number;
  z: number;
};

type CrewMemberVitals = {
  oxy: number;
  tox: number;
  fire: number;
  brute: number;
};

type CrewMember = {
  name: string;
  rank: string;
  assignment: string;
  sensorType: SensorType;
  ref: string;
  dead: boolean;
  vitals?: CrewMemberVitals;
  position?: CrewMemberPosition;
};

type Data = {
  crewMembers: CrewMember[];
  currentZ: number;
  nanomapPayload: NanoMapStaticPayload;
};

export const selectMembers = (
  crewMembers: CrewMember[],
  searchText: string = '',
  zLevel?: number,
): CrewMember[] => {
  let queriedCrewMembers = crewMembers.filter((crewMember) => crewMember?.name);
  if (searchText) {
    const testSearch = createSearch(
      searchText,
      (crewMember: CrewMember) =>
        crewMember.name +
        crewMember.assignment +
        (crewMember.position?.area ?? ''),
    );
    queriedCrewMembers = queriedCrewMembers.filter(testSearch);
  }
  if (zLevel) {
    queriedCrewMembers = queriedCrewMembers.filter(
      (crewMember) => !crewMember.position || crewMember.position.z === zLevel,
    );
  }
  return sortBy(queriedCrewMembers, [(crewMember) => crewMember.name]);
};

export const CrewMonitor = (_: any, context: any) => {
  const { data } = useBackend<Data>();
  const { crewMembers, currentZ } = data;

  const [searchText, setSearchText] = useState<string>('');
  const [zLevel, setZLevel] = useState<number>(currentZ);
  const [hoveredMemberRef, hoverMemberRef] = useState<string>('');
  const [selectedMemberRef, selectMemberRef] = useState<string>('');

  const filteredCrewMembers = selectMembers(crewMembers, searchText, zLevel);

  return (
    <Window width={820} height={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item minWidth={25}>
            <CrewMonitorDataContent
              crewMembers={filteredCrewMembers}
              searchText={searchText}
              setSearchText={setSearchText}
              hoveredMemberRef={hoveredMemberRef}
              hoverMemberRef={hoverMemberRef}
              selectedMemberRef={selectedMemberRef}
              selectMemberRef={selectMemberRef}
            />
          </Stack.Item>
          <Stack.Item grow>
            <CrewMonitorMapContent
              crewMembers={filteredCrewMembers}
              zLevel={zLevel}
              setZLevel={setZLevel}
              hoveredMemberRef={hoveredMemberRef}
              hoverMemberRef={hoverMemberRef}
              selectedMemberRef={selectedMemberRef}
              selectMemberRef={selectMemberRef}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CrewMonitorDataContent = (props: {
  crewMembers: CrewMember[];
  searchText: string;
  setSearchText: (value: string) => void;
  hoveredMemberRef: string;
  hoverMemberRef: (value: string) => void;
  selectedMemberRef: string;
  selectMemberRef: (value: string) => void;
}) => {
  const {
    crewMembers,
    searchText,
    setSearchText,
    hoveredMemberRef,
    hoverMemberRef,
    selectedMemberRef,
    selectMemberRef,
  } = props;

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Input fluid onChange={setSearchText} placeholder="Search..." />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable textAlign="center">
          <Table>
            <Table.Row header>
              <Table.Cell width="45%">Name</Table.Cell>
              <Table.Cell>Status</Table.Cell>
              <Table.Cell width="45%">Location</Table.Cell>
            </Table.Row>
            {crewMembers.map((crewMember: CrewMember) => {
              const { icon, color } = pickCrewIcon(crewMember);
              let highlightColor: string = '';
              if (crewMember.ref === selectedMemberRef) {
                highlightColor = 'yellow';
              } else if (crewMember.ref === hoveredMemberRef) {
                highlightColor = 'white';
              }

              return (
                <Table.Row
                  key={crewMember.ref}
                  onMouseEnter={() => hoverMemberRef(crewMember.ref)}
                  onMouseLeave={() => hoverMemberRef('')}
                  onMouseDown={() =>
                    selectMemberRef(
                      selectedMemberRef === crewMember.ref
                        ? ''
                        : crewMember.ref,
                    )
                  }
                  backgroundColor={highlightColor ?? undefined}
                  textColor={!!highlightColor && 'black'}
                >
                  <Table.Cell verticalAlign="middle">
                    <Tooltip
                      content={`${crewMember.name} (${crewMember.assignment})`}
                    >
                      <Box m={0.5}>
                        <Stack vertical>
                          <Stack.Item>{crewMember.name}</Stack.Item>
                          <Stack.Item mt={0} fontSize="10px" textColor="label">
                            {createAbbreviation(crewMember.assignment)}
                          </Stack.Item>
                        </Stack>
                      </Box>
                    </Tooltip>
                  </Table.Cell>
                  <Table.Cell collapsing verticalAlign="middle">
                    <Box
                      inline
                      m={0.5}
                      textAlign="center"
                      width="100%"
                      height="100%"
                    >
                      <Tooltip
                        content={
                          crewMember.vitals ? (
                            <VitalsDisplay vitals={crewMember.vitals} />
                          ) : crewMember.dead ? (
                            <Box inline color="bad">
                              Dead
                            </Box>
                          ) : (
                            <Box inline color="good">
                              Alive
                            </Box>
                          )
                        }
                      >
                        <Icon name={icon} color={color} size={2} />
                      </Tooltip>
                    </Box>
                  </Table.Cell>
                  <Table.Cell verticalAlign="middle">
                    {crewMember.position ? (
                      <Tooltip content={crewMember.position.area}>
                        <Box m={0.5} verticalAlign="center">
                          ({crewMember.position.x},{crewMember.position.y},
                          {crewMember.position.z})
                        </Box>
                      </Tooltip>
                    ) : (
                      'N/A'
                    )}
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const CrewMonitorMapContent = (props: {
  crewMembers: CrewMember[];
  zLevel: number;
  setZLevel: (number: number) => void;
  hoveredMemberRef: string;
  hoverMemberRef: (val: string) => void;
  selectedMemberRef: string;
  selectMemberRef: (value: string) => void;
}) => {
  const { data } = useBackend<Data>();
  const { currentZ, nanomapPayload } = data;
  const allCrewMembers = data.crewMembers;
  const {
    zLevel,
    setZLevel,
    crewMembers,
    hoveredMemberRef,
    hoverMemberRef,
    selectedMemberRef,
    selectMemberRef,
  } = props;

  const availableZLevels = ((crewMembers: CrewMember[]) => {
    let zLevels = crewMembers
      .filter((crewMember: CrewMember) => crewMember.position)
      .map((crewMember: CrewMember) => crewMember.position?.z)
      .filter((z) => z !== undefined)
      .concat(currentZ);
    zLevels = uniq(zLevels);
    return zLevels.toSorted();
  })(allCrewMembers);

  const tooltipForMember = (crewMember: CrewMember) => (
    <Box textAlign="center">
      {`${crewMember.name} (${crewMember.assignment})`}
      {crewMember.vitals && <VitalsDisplay vitals={crewMember.vitals} />}
    </Box>
  );

  const trackPosition = useMemo(() => {
    if (!selectedMemberRef) return undefined;
    const foundCrewmember = allCrewMembers.find(
      (crewMember: CrewMember) => crewMember.ref === selectedMemberRef,
    );
    if (foundCrewmember?.position) {
      return {
        x: foundCrewmember.position.x,
        y: foundCrewmember.position.y,
        z: foundCrewmember.position.z,
      };
    }
  }, [selectedMemberRef, allCrewMembers]);

  useEffect(() => {
    if (trackPosition) {
      setZLevel(trackPosition.z);
    }
  }, [trackPosition?.z, setZLevel]);

  return (
    <Box width="100%" height="100%" overflow="hidden">
      <NanoMap
        nanomapPayload={nanomapPayload}
        centerX={trackPosition?.x || undefined}
        centerY={trackPosition?.y || undefined}
        zLevel={trackPosition?.z || zLevel}
        stopTracking={() => selectMemberRef('')}
        zoom={trackPosition ? 4 : undefined}
        onZLevel={setZLevel}
        availableZLevels={availableZLevels}
        controlsOnTop
      >
        {crewMembers.map((crewMember: CrewMember) => {
          if (!crewMember.position) return null;
          let { color, icon } = pickCrewIcon(crewMember);

          if (crewMember.ref === hoveredMemberRef) {
            color = 'white';
          }

          return (
            <NanoMap.MarkerIcon
              onMouseEnter={() => hoverMemberRef(crewMember.ref)}
              onMouseLeave={() => hoverMemberRef('')}
              onMouseDown={(e: React.MouseEvent) => {
                selectMemberRef(
                  selectedMemberRef === crewMember.ref ? '' : crewMember.ref,
                );
                pauseEvent(e);
              }}
              key={crewMember.name}
              x={crewMember.position.x}
              y={crewMember.position.y}
              icon={icon}
              tooltip={tooltipForMember(crewMember)}
              color={color}
            />
          );
        })}
      </NanoMap>
    </Box>
  );
};

const VitalsDisplay = (props: { vitals: CrewMemberVitals } & BoxProps) => {
  const { vitals, ...rest } = props;
  return (
    <Box inline {...rest}>
      &nbsp;(
      <Box inline color="blue" bold={vitals.oxy > 50}>
        {vitals.oxy}
      </Box>
      ,
      <Box inline color="green" bold={vitals.tox > 50}>
        {vitals.tox}
      </Box>
      ,
      <Box inline color="orange" bold={vitals.fire > 50}>
        {vitals.fire}
      </Box>
      ,
      <Box inline color="red" bold={vitals.brute > 50}>
        {vitals.brute}
      </Box>
      )
    </Box>
  );
};
