import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { createRef } from 'inferno';
import {
  Button,
  ByondUi,
  Flex,
  Input,
  Section,
  Box,
  NanoMap,
  Icon,
  Stack,
} from '../components';
import { Window } from '../layouts';

interface Data {
  mapRef: string;
  activeCamera: CameraObject;
  cameras: CameraObject[];
}

interface CameraObject {
  name: string;
  z: number;
  ref: string;
  x: number;
  y: number;
  status: boolean;
}

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
export const selectCameras = (cameras, searchText = ''): [CameraObject] => {
  const testSearch = createSearch(
    searchText,
    (camera: CameraObject) => camera.name
  );
  return flow([
    // Null camera filter
    filter((camera) => camera?.name),
    // Optional search term
    searchText && filter(testSearch),
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
            <Stack vertical fill>
              <Stack.Item grow m={1}>
                <CameraConsoleContent
                  isMinimapShown={isMinimapShown}
                  setMinimapShown={setMinimapShown}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Stack vertical fill>
              <Stack.Item>
                <Stack fill>
                  <Stack.Item grow>
                    <div className="CameraConsole__toolbar">
                      <b>Camera: </b>
                      {(activeCamera && activeCamera.name) || '—'}
                    </div>
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
              <Stack.Item grow m={1}>
                <ByondUi
                  updateProp={isMinimapShown} // For size updates
                  className="CameraConsole__map"
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
  const { isMinimapShown, setMinimapShown } = props;

  const tabUi = (minimapShown: boolean) => {
    switch (minimapShown) {
      case false:
        return <CameraConsoleListContent />;
      case true:
        return <CameraMinimapContent />;
    }
  };

  const toggleMode = () => {
    setMinimapShown(!isMinimapShown);
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Button onClick={() => toggleMode()}>
          {isMinimapShown ? 'Switch to List' : 'Switch to Minimap'}
        </Button>
      </Stack.Item>
      {tabUi(isMinimapShown)}
    </Stack>
  );
};

export const CameraMinimapContent = (props, context) => {
  const { act, data, config } = useBackend<Data>(context);
  const { activeCamera } = data;
  const cameras = selectCameras(data.cameras);

  const [prevCameraName, nextCameraName] = prevNextCamera(
    cameras,
    activeCamera
  );

  const [zoom, setZoom] = useLocalState(context, 'zoom', 1);

  return (
    <Box height="100%" mb="0.5rem" overflow="hidden">
      <NanoMap onZoom={(v) => setZoom(v)}>
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
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const { activeCamera } = data;
  const cameras = selectCameras(data.cameras, searchText);
  return (
    <Stack className="CameraConsole__list" vertical fill>
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
