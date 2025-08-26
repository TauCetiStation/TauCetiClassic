import { map } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { classes } from 'common/react';
import { Section, Box, Stack, ProgressBar, Dimmer, Icon } from '../components';
import { Window } from '../layouts';

import {
  NanoMap,
  NanoMapMarkerIcon,
  NanoMapStaticPayload,
  NanoMapTrackData,
} from '../components/NanoMap';

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

const tooltipForDock = (dock: DockObject) => (
  <Box textAlign="center">{<b>{dock.name}</b>}</Box>
);

type Data = {
  shuttlename: string;
  ismoving: boolean;
  docks: DockObject[];
  levels: LevelObject[];
  birthplace: DockObject;
  docked_to_id: number;
  currentZ: number;
  nanomapPayload: NanoMapStaticPayload;
};

type DockObject = {
  name: string;
  dir: number;
  bounds_x: number;
  bounds_y: number;
  x: number;
  y: number;
  occupied: boolean;
  reserved: boolean;
  dock_id: number;
};

type LevelObject = {
  name: string;
  z: number;
};

export const ShuttleConsole = (_: any, context: any) => {
  const { act, data } = useBackend<Data>(context);
  const {
    shuttlename,
    currentZ,
    nanomapPayload,
    docks,
    ismoving,
    levels,
    birthplace,
    docked_to_id,
  } = data;

  const pickColor = (dock: DockObject) => {
    let color = 'green';
    if (dock.reserved || dock.occupied) {
      color = 'grey';
    }

    if (dock.dock_id === docked_to_id) {
      color = 'red';
    }

    return { color };
  };

  const pickIcon = (dock: DockObject) => {
    let icon = 'circle';

    switch (dock.dir) {
      case 1:
        icon = 'caret-square-up';
        break;
      case 2:
        icon = 'caret-square-down';
        break;
      case 4:
        icon = 'caret-square-right';
        break;
      case 8:
        icon = 'caret-square-left';
        break;
    }

    if (dock.dock_id === docked_to_id) {
      icon = 'rocket';
    }

    return { icon };
  };

  const [zLevel, setZLevel] = useLocalState<number>(
    context,
    'crewMonitorZLevel',
    currentZ
  );

  const availableZLevels: number[] = [currentZ];

  let trackData: NanoMapTrackData | undefined;

  return (
    <Window title={'Консоль шаттла: ' + shuttlename} width={700} height={500}>
      <Window.Content>
        <Box
          width="30%"
          height="100%"
          overflow="hidden"
          left="0px"
          position="absolute">
          <Stack vertical fill>
            <Stack.Item textAlign="center" bold={1}>
              Список доступных секторов:
            </Stack.Item>
            <Stack.Item grow>
              <Section fill scrollable>
                {birthplace && (
                  <div
                    key={birthplace.dock_id}
                    title={birthplace.name}
                    className={classes([
                      'Button',
                      'Button--fluid',
                      'Button--color--transparent',
                      'Button--ellipsis',
                      birthplace.dock_id === docked_to_id && 'Button--selected',
                    ])}
                    onClick={() =>
                      act('fly_to_dock', {
                        dock_id: birthplace.dock_id,
                      })
                    }>
                    {birthplace.name}
                  </div>
                )}
                {levels.map((level: LevelObject) => (
                  <div
                    key={level.z}
                    title={level.name}
                    className={classes([
                      'Button',
                      'Button--fluid',
                      'Button--color--transparent',
                      'Button--ellipsis',
                      level.z === currentZ && 'Button--selected',
                    ])}
                    onClick={() =>
                      act('fly_to_level', {
                        level_id: level.z,
                      })
                    }>
                    {level.name}{' '}
                    {level.z === currentZ && <Icon name="rocket" />}
                  </div>
                ))}
              </Section>
            </Stack.Item>
          </Stack>
        </Box>
        <Box
          width="70%"
          height="100%"
          overflow="hidden"
          right="0px"
          position="absolute">
          <NanoMap
            nanomapPayload={nanomapPayload}
            zLevel={zLevel}
            setZLevel={setZLevel}
            availableZLevels={availableZLevels}
            pixelsPerTurf={2}
            trackData={trackData}
            controlsOnTop>
            {docks.map((dock: DockObject) => {
              let { color } = pickColor(dock);
              let { icon } = pickIcon(dock);
              return (
                <NanoMapMarkerIcon
                  key={dock.dock_id}
                  x={dock.x + dock.bounds_x / 2 - 0.5}
                  y={dock.y + dock.bounds_y / 2 - 1}
                  icon={icon}
                  tooltip={tooltipForDock(dock)}
                  color={color}
                  onClick={(e: MouseEvent) => {
                    act('fly_to_dock', { dock_id: dock.dock_id });
                    pauseEvent(e);
                  }}
                />
              );
            })}
          </NanoMap>
        </Box>
        {!!ismoving && (
          <Dimmer textAlign="center">
            <h1>В процессе перелёта...</h1>
            <h3>Пожалуйста, подождите.</h3>
          </Dimmer>
        )}
      </Window.Content>
    </Window>
  );
};
