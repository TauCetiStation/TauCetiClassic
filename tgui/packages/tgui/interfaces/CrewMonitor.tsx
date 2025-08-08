import { InfernoNode } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import {
  Stack,
  Section,
  Icon,
  Tabs,
  Box,
  NanoMap,
  Table,
  Input,
  Tooltip,
} from '../components';
import { Window } from '../layouts';
import { flow } from 'common/fp';
import { filter, sortBy, map, uniqBy } from 'common/collections';

import { createSearch } from 'common/string';
import { BoxProps } from '../components/Box';

const createAbbreviation = (text: string): string => {
  const words = text.split(' ');

  if (words.length <= 1 || (words.length <= 3 && text.length < 10)) {
    return text;
  }

  const abbreviation =
    words.map((word) => word.charAt(0).toUpperCase()).join('.') + '.';

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
  } else if (totalDamage > 50) {
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
  stationMapName: string;
  mineMapName: string;
  mineZLevels: number[];
};

export const selectMembers = (
  crewMembers: CrewMember[],
  searchText = '',
  zLevel = undefined
): [CrewMember] => {
  const testSearch = createSearch(
    searchText,
    (crewMember: CrewMember) =>
      crewMember.name +
      crewMember.assignment +
      (crewMember.position?.area ?? '')
  );
  return flow([
    filter((crewMember: CrewMember) => crewMember?.name),
    // Optional search term
    searchText && filter(testSearch),
    // Optional zlevel filter
    zLevel &&
      filter(
        (crewMember: CrewMember) =>
          !crewMember.position || crewMember.position.z === zLevel
      ),
    // Slightly expensive, but way better than sorting in BYOND
    sortBy((crewMember: CrewMember) => crewMember.name),
  ])(crewMembers);
};

export const CrewMonitor = (_, context: any) => {
  const { act, data } = useBackend<Data>(context);

  const { crewMembers, currentZ } = data;

  const [searchText, setSearchText] = useLocalState<string>(
    context,
    'crewMonitorSearchText',
    ''
  );

  const [zLevel, setZLevel] = useLocalState<number>(
    context,
    'crewMonitorZLevel',
    currentZ
  );

  const [hoveredMemberRef, hoverMemberRef] = useLocalState<string>(
    context,
    'crewMonitorHoveredMember',
    ''
  );

  const filteredCrewMembers = selectMembers(crewMembers, searchText, zLevel);

  return (
    <Window width={800} height={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <CrewMonitorDataContent
              crewMembers={filteredCrewMembers}
              searchText={searchText}
              setSearchText={setSearchText}
              hoveredMemberRef={hoveredMemberRef}
              hoverMemberRef={hoverMemberRef}
            />
          </Stack.Item>
          <Stack.Item>
            <CrewMonitorMapContent
              crewMembers={filteredCrewMembers}
              zLevel={zLevel}
              setZLevel={setZLevel}
              hoveredMemberRef={hoveredMemberRef}
              hoverMemberRef={hoverMemberRef}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CrewMonitorDataContent = (
  props: {
    crewMembers: CrewMember[];
    searchText: string;
    setSearchText: (value: string) => void;
    hoveredMemberRef: string;
    hoverMemberRef: (value: string) => void;
  },
  context: any
) => {
  const {
    crewMembers,
    searchText,
    setSearchText,
    hoveredMemberRef,
    hoverMemberRef,
  } = props;

  return (
    <Section fill scrollable textAlign="center">
      <Table>
        <Table.Row header>
          <Table.Cell width="45%">Name</Table.Cell>
          <Table.Cell>Status</Table.Cell>
          <Table.Cell width="45%">Location</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Stack>
            <Stack.Item grow>
              <Input
                fluid
                onInput={(e, value) => setSearchText(value)}
                placeholder="Search.."
              />
            </Stack.Item>
          </Stack>
        </Table.Row>
        {crewMembers.map((crewMember: CrewMember) => {
          const { icon, color } = pickCrewIcon(crewMember);
          return (
            <Table.Row
              key={crewMember.ref}
              onMouseEnter={() => hoverMemberRef(crewMember.ref)}
              onMouseLeave={() => hoverMemberRef('')}
              backgroundColor={hoveredMemberRef === crewMember.ref && 'white'}
              textColor={hoveredMemberRef === crewMember.ref && 'black'}>
              <Table.Cell>
                <Tooltip
                  content={`${crewMember.name} (${crewMember.assignment})`}>
                  <Box m={0.5}>
                    {crewMember.name}(
                    {createAbbreviation(crewMember.assignment)})
                  </Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing textAlign="center">
                <Box
                  inline
                  m={0.5}
                  textAlign="center"
                  width="100%"
                  height="100%">
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
                    }>
                    <Icon name={icon} color={color} size={2} />
                  </Tooltip>
                </Box>
              </Table.Cell>
              <Table.Cell>
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
  );
};

const CrewMonitorMapContent = (
  props: {
    crewMembers: CrewMember[];
    zLevel: number;
    setZLevel: (number: number) => void;
    hoveredMemberRef: string;
    hoverMemberRef: (val: string) => void;
  },
  context: any
) => {
  const { data } = useBackend<Data>(context);
  const { stationMapName, mineMapName, mineZLevels, currentZ } = data;
  const allCrewMembers = data.crewMembers;
  const { zLevel, setZLevel, crewMembers, hoveredMemberRef, hoverMemberRef } =
    props;

  const availableZLevels: number[] = flow([
    filter((crewMember: CrewMember) => crewMember.position),
    map((crewMember: CrewMember) => crewMember.position?.z),
    (zLevels: number[]) => zLevels.concat(currentZ),
    uniqBy(),
    sortBy(),
  ])(allCrewMembers);

  const tooltipForMember = (crewMember: CrewMember) => (
    <Box textAlign="center">
      {`${crewMember.name} (${crewMember.assignment})`}
      {crewMember.vitals && <VitalsDisplay vitals={crewMember.vitals} />}
    </Box>
  );

  return (
    <Box width="100%" height="100%" overflow="hidden">
      <NanoMap
        stationMapName={stationMapName}
        mineMapName={mineMapName}
        mineZLevels={mineZLevels}
        zLevel={zLevel}
        setZLevel={setZLevel}
        availableZLevels={availableZLevels}
        pixelsPerTurf={2}
        controlsOnTop>
        {crewMembers
          .filter((crewMember: CrewMember) => crewMember.position)
          .map((crewMember: CrewMember) => {
            let { color, icon } = pickCrewIcon(crewMember);

            if (crewMember.ref === hoveredMemberRef) {
              color = 'white';
            }

            return (
              <NanoMap.MarkerIcon
                onMouseEnter={() => hoverMemberRef(crewMember.ref)}
                onMouseLeave={() => hoverMemberRef('')}
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
