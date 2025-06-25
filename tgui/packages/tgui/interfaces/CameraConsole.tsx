import { filter, sortBy, map, uniqBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import {
  Button,
  ByondUi,
  Input,
  Section,
  Box,
  NanoMap,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Data = {
  mapRef: string;
  activeCamera: CameraObject;
  cameras: CameraObject[];
  stationMapName: string;
  mineMapName?: string;
  mineZLevels: number[];
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
  cameras: [CameraObject],
  activeCamera: CameraObject
) => {
  if (!activeCamera) {
    return [];
  }
  const index = cameras.findIndex(
    (camera) => camera.name === activeCamera.name
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
  searchText = '',
  zLevel = undefined
): [CameraObject] => {
  const testSearch = createSearch(
    searchText,
    (camera: CameraObject) => camera.name
  );
  return flow([
    // Null camera filter
    filter((camera: CameraObject) => camera?.name),
    // Optional search term
    searchText && filter(testSearch),
    // Optional zlevel filter
    zLevel && filter((camera: CameraObject) => camera.z === zLevel),
    // Slightly expensive, but way better than sorting in BYOND
    sortBy((camera) => camera.name),
  ])(cameras);
};

export const CameraConsole = (_, context: any) => {
  Byond.winget('mapwindow.map', 'style').then((style) => {
    Byond.winset(mapRef, 'style', style);
  });

  const [isMinimapShown, setMinimapShown] = useLocalState(
    context,
    'isMinimapShown',
    false
  );

  const { act, data } = useBackend<Data>(context);
  const { mapRef, activeCamera } = data;
  const cameras = selectCameras(data.cameras);
  const [prevCameraName, nextCameraName] = prevNextCamera(
    cameras,
    activeCamera
  );

  return (
    <Window width={800} height={600} maxHeight={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item>
            <CameraConsoleContent
              isMinimapShown={isMinimapShown}
              setMinimapShown={setMinimapShown}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Stack vertical fill>
              <Stack.Item>
                <Stack fill>
                  <Stack.Item grow mx="5px" mt="8px" mb="2px">
                    <b>Camera: </b>
                    {(activeCamera && activeCamera.name) || '—'}
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
                  updateProp={isMinimapShown} // For size updates
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

export const CameraConsoleContent = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { stationMapName, mineMapName, mineZLevels } = data;

  const availableZLevels = flow([
    map((camera: CameraObject) => camera.z),
    uniqBy(),
    sortBy(),
  ])(data.cameras);

  const [zLevel, setZLevel] = useLocalState<number>(
    context,
    'zLevel',
    availableZLevels.at(0)
  );
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const cameras = selectCameras(data.cameras, searchText, zLevel);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <CameraConsoleListContent
          setSearchText={setSearchText}
          cameras={cameras}
        />
      </Stack.Item>
      <Stack.Item>
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

export const CameraMinimapContent = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { activeCamera, stationMapName, mineMapName, mineZLevels } = data;
  const { zLevel, setZLevel, availableZLevels, cameras } = props;

  return (
    <Box height="100%" overflow="hidden">
      <NanoMap
        zLevel={zLevel}
        setZLevel={setZLevel}
        stationMapName={stationMapName}
        mineMapName={mineMapName}
        mineLevels={mineZLevels}
        availableZLevels={availableZLevels}>
        {cameras.map((camera) => (
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
            onClick={() => {
              act('switch_camera', { name: camera.name });
            }}
          />
        ))}
      </NanoMap>
    </Box>
  );
};

export const CameraConsoleListContent = (props, context) => {
  const { act, data } = useBackend<Data>(context);
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
          onInput={(e, value) => setSearchText(value)}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {cameras.map((camera) => (
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
              }>
              {camera.name}
            </div>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
