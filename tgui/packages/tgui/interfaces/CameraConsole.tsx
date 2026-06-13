import { sortBy } from 'es-toolkit';
import { uniq } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Box,
  Button,
  ByondUi,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';
import { useBackend } from '../backend';
import { NanoMap, type NanoMapStaticPayload } from '../components/NanoMap';
import { Window } from '../layouts';

function pauseEvent(
  e: React.MouseEvent | React.PointerEvent | React.WheelEvent,
) {
  if (e.stopPropagation) e.stopPropagation();
  if (e.preventDefault && e.cancelable) e.preventDefault();
  return false;
}

type Data = {
  mapRef: string;
  activeCamera: CameraObject;
  cameras: CameraObject[];
  nanomapPayload: NanoMapStaticPayload;
};

type CameraObject = {
  name: string;
  x: number;
  y: number;
  z: number;
  status: boolean;
};

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
export const prevNextCamera = (
  cameras: CameraObject[],
  activeCamera: CameraObject,
) => {
  if (!activeCamera) {
    return [];
  }
  const index = cameras.findIndex(
    (camera) => camera.name === activeCamera.name,
  );
  return [cameras[index - 1]?.name, cameras[index + 1]?.name];
};

/**
 * Camera selector.
 *
 * Filters cameras, applies search terms and sorts the alphabetically.
 */
export const selectCameras = (
  cameras: CameraObject[],
  searchText?: string,
  zLevel?: number,
): CameraObject[] => {
  let queriedCameras = cameras.filter((camera) => camera?.name);
  if (searchText && searchText.trim() !== '') {
    const testSearch = createSearch(
      searchText,
      (camera: CameraObject) => camera.name,
    );
    queriedCameras = queriedCameras.filter(testSearch);
  }
  if (zLevel !== undefined) {
    queriedCameras = queriedCameras.filter(
      (camera: CameraObject) => camera.z === zLevel,
    );
  }
  return sortBy(queriedCameras, [(camera) => camera.name]);
};

export const CameraConsole = () => {
  Byond.winget('mapwindow.map', 'style').then((style) => {
    Byond.winset(mapRef, 'style', style);
  });

  const { act, data } = useBackend<Data>();
  const { mapRef, activeCamera } = data;
  const cameras = selectCameras(data.cameras);
  const [prevCameraName, nextCameraName] = prevNextCamera(
    cameras,
    activeCamera,
  );

  return (
    <Window width={890} height={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={2}>
            <CameraConsoleContent />
          </Stack.Item>
          <Stack.Item grow={3}>
            <Stack vertical fill>
              <Stack.Item>
                <Stack fill>
                  <Stack.Item grow mx="5px" mt="8px" mb="2px">
                    <b>Camera: </b>
                    {activeCamera?.name || '—'}
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="chevron-left"
                      disabled={!prevCameraName}
                      onClick={() =>
                        act('switch_camera', {
                          name: prevCameraName,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="chevron-right"
                      disabled={!nextCameraName}
                      onClick={() =>
                        act('switch_camera', {
                          name: nextCameraName,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <ByondUi
                  position="relative"
                  height="100%"
                  params={{
                    id: mapRef,
                    type: 'map',
                  }}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const CameraConsoleContent = () => {
  const { data } = useBackend<Data>();

  const availableZLevels = (() => {
    const zLevels = data.cameras
      .map((camera: CameraObject) => camera.z)
      .filter((z) => z !== undefined);
    return uniq(zLevels).toSorted();
  })();

  const propZLevel = availableZLevels.at(0);

  if (propZLevel === undefined) {
    return <NoticeBox info>No cameras available.</NoticeBox>;
  }

  const [zLevel, setZLevel] = useState<number>(propZLevel);
  const [searchText, setSearchText] = useState<string>('');

  const cameras = selectCameras(data.cameras, searchText, zLevel);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <CameraConsoleListContent
          setSearchText={setSearchText}
          cameras={cameras}
        />
      </Stack.Item>
      <Stack.Item grow>
        <CameraMinimapContent
          zLevel={zLevel}
          setZLevel={setZLevel}
          availableZLevels={availableZLevels}
          cameras={cameras}
        />
      </Stack.Item>
    </Stack>
  );
};

export const CameraMinimapContent = (props: {
  zLevel: number;
  setZLevel: (_: number) => void;
  availableZLevels: number[];
  cameras: CameraObject[];
}) => {
  const { act, data } = useBackend<Data>();
  const { activeCamera, nanomapPayload } = data;
  const { zLevel, setZLevel, availableZLevels, cameras } = props;

  return (
    <Box height="100%" overflow="hidden">
      <NanoMap
        zLevel={zLevel}
        onZLevel={setZLevel}
        nanomapPayload={nanomapPayload}
        availableZLevels={availableZLevels}
      >
        {cameras.map((camera: CameraObject) => (
          <NanoMap.MarkerIcon
            key={camera.name}
            x={camera.x}
            y={camera.y}
            icon="circle"
            tooltip={camera.name}
            color={
              camera?.name === activeCamera?.name
                ? 'green'
                : camera.status
                  ? 'blue'
                  : 'red'
            }
            onClick={(e: React.MouseEvent) => {
              act('switch_camera', { name: camera.name });
              pauseEvent(e);
            }}
          />
        ))}
      </NanoMap>
    </Box>
  );
};

export const CameraConsoleListContent = (props: {
  setSearchText: (_: string) => void;
  cameras: CameraObject[];
}) => {
  const { act, data } = useBackend<Data>();
  const { setSearchText, cameras } = props;
  const { activeCamera } = data;
  return (
    <Stack vertical fill>
      <Stack.Item>
        <Input
          autoFocus
          fluid
          mt={1}
          placeholder="Search for a camera"
          onChange={setSearchText}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {cameras.map((camera: CameraObject) => (
            // We're not using the component here because performance
            // would be absolutely abysmal (50+ ms for each re-render).
            <div
              key={camera.name}
              title={camera.name}
              className={classes([
                'Button',
                'Button--fluid',
                'Button--color--transparent',
                'Button--ellipsis',
                !camera.status && 'Button--disabled',
                activeCamera &&
                  camera.name === activeCamera.name &&
                  'Button--selected',
              ])}
              onClick={() =>
                act('switch_camera', {
                  name: camera.name,
                })
              }
            >
              {camera.name}
            </div>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
