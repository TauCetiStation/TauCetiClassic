import { useState } from 'react';
import { Box, ProgressBar } from 'tgui-core/components';
import { useBackend } from '../backend';
import { NanoMap, type NanoMapStaticPayload } from '../components';
import { Window } from '../layouts';

const pickColor = (machine: VendingObject): string => {
  let color = 'green';
  if (machine.status === 2) {
    color = 'grey';
  } else if (machine.status === 3) {
    color = 'red';
  } else if (machine.load < 75) {
    color = 'yellow';
  } else if (machine.load < 50) {
    color = 'orange';
  } else if (machine.load < 25) {
    color = 'red';
  }

  return color;
};

const pickTitleForTooltip = (status: number): string => {
  let text = 'Работает';
  switch (status) {
    case 3:
      text = 'Сломан';
      break;
    case 2:
      text = 'Обесточен';
      break;
  }

  return text;
};

const tooltipForMachine = (machine: VendingObject) => (
  <Box textAlign="center">
    <b>{machine.name}</b>: <i>{pickTitleForTooltip(machine.status)}</i>
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
  vendingMachines: VendingObject[];
  currentZ: number;
  nanomapPayload: NanoMapStaticPayload;
};

type VendingObject = {
  name: string;
  ref: string;
  x: number;
  y: number;
  status: number;
  load: number;
};

export const VendingConsole = () => {
  const { data } = useBackend<Data>();
  const { currentZ, nanomapPayload, vendingMachines } = data;

  const [zLevel, setZLevel] = useState<number>(currentZ);

  const availableZLevels: number[] = [currentZ];

  return (
    <Window width={500} height={500}>
      <Window.Content>
        <Box width="100%" height="100%" overflow="hidden">
          <NanoMap
            nanomapPayload={nanomapPayload}
            zLevel={zLevel}
            onZLevel={setZLevel}
            availableZLevels={availableZLevels}
            pixelsPerTurf={2}
            zoom={2}
            controlsOnTop
          >
            {vendingMachines.map((machine: VendingObject) => (
              <NanoMap.Marker
                key={machine.ref}
                x={machine.x}
                y={machine.y}
                tooltip={tooltipForMachine(machine)}
              >
                <div
                  style={{
                    width: '2px',
                    height: '2px',
                    backgroundColor: pickColor(machine),
                    borderRadius: '50%',
                  }}
                />
              </NanoMap.Marker>
            ))}
          </NanoMap>
        </Box>
      </Window.Content>
    </Window>
  );
};
