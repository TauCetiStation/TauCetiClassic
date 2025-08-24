import { map } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { Box, ProgressBar } from '../components';
import { Window } from '../layouts';

import {
  NanoMap,
  NanoMapMarkerIcon,
  NanoMapStaticPayload,
  NanoMapTrackData,
} from '../components/NanoMap';

const pickColor = (machine: VendingObject) => {
  let color = 'green';
  if (machine.status === 2) {
    color = 'grey';
  } else if (machine.status === 3) {
    color = 'red';
  } else if (machine.load < 75) {
    color = 'yellow';
  } else if (machine.load < 50)  {
    color = 'orange';
  } else if (machine.load < 25) {
    color = 'red';
  }

  return { color };
};

const pauseEvent = (e: MouseEvent) => {
  if (e.stopPropagation) {
    e.stopPropagation();
  }
  if (e.preventDefault) {
    e.preventDefault();
  }
  e.cancelBubble = true;
  e.returnValue = false;
  return false;
};

const tooltipForMachine = (machine: VendingObject) => (
    <Box textAlign="center">
      {<b>{machine.name}</b>}: {<i>{machine.status === 3
                  ? 'Сломан'
                  : machine.status === 2
                  ? 'Обесточен' : 'Работает'}</i>}
      {machine.status === 1 && (
        <ProgressBar
          ranges={{
            green: [75, Infinity],
            yellow: [50, 75],
            orange: [25, 50],
            red: [-Infinity, 25],
          }}
          minValue={0}
          maxValue={100}
          value={machine.load}
        />
      )}
    </Box>
  );

type Data = {
  vending_machines: VendingObject[];
  currentZ: number;
  nanomapPayload: NanoMapStaticPayload;
};

type VendingObject = {
  name: string;
  x: number;
  y: number;
  status: number;
  load: number;
};

export const VendingConsole = (_: any, context: any) => {
  Byond.winget('mapwindow.map', 'style').then((style) => {
    Byond.winset('Vending Console', 'style', style);
  });

  const { act, data } = useBackend<Data>(context);
  const {
    currentZ,
    nanomapPayload,
    vending_machines,
  } = data;

  const [zLevel, setZLevel] = useLocalState<number>(
    context,
    'crewMonitorZLevel',
    currentZ
  );

  const availableZLevels: number[] = [
    currentZ,
  ];

  let trackData: NanoMapTrackData | undefined;

  return (
    <Window width={500} height={500}>
      <Window.Content>
        <Box width="100%" height="100%" overflow="hidden">
          <NanoMap
            nanomapPayload={nanomapPayload}
            zLevel={zLevel}
            setZLevel={setZLevel}
            availableZLevels={availableZLevels}
            pixelsPerTurf={2}
            trackData={trackData}
            controlsOnTop>
            {vending_machines.map((machine: VendingObject) => {
              let {color} = pickColor(machine);
              return (
                <NanoMapMarkerIcon
                  key={machine.name}
                  x={machine.x}
                  y={machine.y}
                  icon="circle"
                  tooltip={tooltipForMachine(machine)}
                  color={color}
                />
              );
            })}
          </NanoMap>
        </Box>
      </Window.Content>
    </Window>
  );
};
