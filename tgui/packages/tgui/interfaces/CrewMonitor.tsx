import { InfernoNode } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Stack, Section, Icon, Tabs, NanoMap, Table } from '../components';
import { Window } from '../layouts';

enum SensorType {
  off = 0,
  binary = 1,
  vital = 2,
  tracking = 3,
}

type CrewMemberPosition = {
  area: string;
  x: string;
  y: string;
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
  dead: boolean;
  vitals?: CrewMemberVitals;
  position?: CrewMemberPosition;
};

interface NanoMapPayload {
  stationMapName: string;
  mineMapName: string;
  mineLevels: number[];
}

type Data = {
  crewMembers: CrewMember[];
  currentZ: number;
} & NanoMapPayload;

export const CrewMonitor = (_, context: any) => {
  const { act, data } = useBackend<Data>(context);

  const { crewMembers, currentZ, stationMapName, mineMapName, mineLevels } =
    data;

  const [searchText, setSearchText] = useLocalState<string>(
    context,
    'crewMonitorSearchText',
    ''
  );

  const tabView = (index: number): InfernoNode => {
    switch (index) {
      case 0:
        return <CrewMonitorDataContent crewMembers={crewMembers} />;
      case 1:
        return (
          <CrewMonitorMapContent
            currentZ={currentZ}
            crewMembers={crewMembers}
            stationMapName={stationMapName}
            mineMapName={mineMapName}
            mineLevels={mineLevels}
          />
        );
      default:
        return <div />;
    }
  };

  return (
    <Window>
      <Window.Content>
        <Stack fill>
          <Stack.Item>
            <CrewMonitorDataContent crewMembers={crewMembers} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CrewMonitorDataContent = (
  props: { crewMembers: CrewMember[] },
  context
) => {
  const { crewMembers } = props;

  return (
    <Section fill scrollable>
      <Table>
        <Table.Row header>
          <Table.Cell width="35%">Name</Table.Cell>
          <Table.Cell>Status</Table.Cell>
          <Table.Cell width="35%">Location</Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

type CrewMonitorMapContentProps = {
  currentZ: number;
  crewMembers: CrewMember[];
} & NanoMapPayload;

const CrewMonitorMapContent = (props: CrewMonitorMapContentProps, context) => {
  const { stationMapName, mineMapName, mineLevels, currentZ, crewMembers } =
    props;

  const [zLevel, setZLevel] = useLocalState<number>(
    context,
    'crewMonitorZLevel',
    currentZ
  );

  return (
    <NanoMap
      stationMapName={stationMapName}
      mineMapName={mineMapName}
      mineLevels={mineLevels}
      zLevel={zLevel}
      setZLevel={setZLevel}
      availableZLevels={mineLevels.concat([currentZ])}></NanoMap>
  );
};
