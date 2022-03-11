import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, ByondUi, Input, Section, Box, Tabs, Icon, Flex } from '../components';
import { NanoMap } from '../components/NanoMap';
import { Window } from '../layouts';

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
export const prevNextCamera = (cameras, activeCamera) => {
  if (!activeCamera) {
    return [];
  }
  const index = cameras.findIndex(camera => (
    camera.name === activeCamera.name
  ));
  return [
    cameras[index - 1]?.name,
    cameras[index + 1]?.name,
  ];
};

/**
 * Camera selector.
 *
 * Filters cameras, applies search terms and sorts the alphabetically.
 */
export const selectCameras = (cameras, searchText = '') => {
  const testSearch = createSearch(searchText, camera => camera.name);
  return flow([
    // Null camera filter
    filter(camera => camera?.name),
    // Optional search term
    searchText && filter(testSearch),
    // Slightly expensive, but way better than sorting in BYOND
    sortBy(camera => camera.name),
  ])(cameras);
};

export const CameraConsole = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = index => {
    switch (index) {
      case 0:
        return (
          <>
            <CameraConsoleMapContent />
            <div className="CameraConsole__new__right">
              <CameraByondUi />
            </div>
          </>
        );
      case 1:
        return (
          <>
            <CameraConsoleOldContent />.
            <div className="CameraConsole__right">
              <CameraByondUi />
            </div>
          </>
        );
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window
      resizable>
      <Window.Content>
        <Box fillPositionedParent>
          <Tabs>
            <Tabs.Tab
              key="Map"
              selected={0 === tabIndex}
              onClick={() => setTabIndex(0)}>
              <Icon name="map-marked-alt" /> Map
            </Tabs.Tab>
            <Tabs.Tab
              key="List"
              selected={1 === tabIndex}
              onClick={() => setTabIndex(1)}>
              <Icon name="table" /> List
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

export const CameraConsoleMapContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { activeCamera, stationImage } = data;
  const cameras = selectCameras(data.cameras);
  const [zoom, setZoom] = useLocalState(context, 'zoom', 2);
  return (
    <Box overflow="hidden">
      <Box resizable>
        <NanoMap onZoom={v => setZoom(v)} map={stationImage} zoom={zoom} >
          {cameras.filter(cam => cam.z === 2).map(cm => (
            <NanoMap.NanoButton
              activeCamera={activeCamera}
              context={context}
              zoom={zoom}
              icon="circle"
              tooltip={cm.name}
              name={cm.name}
              x={cm.x}
              y={cm.y}
              key={cm.name}
              color={"blue"}
            />
          ))}
        </NanoMap>
      </Box>
    </Box>
  );
};

export const CameraConsoleOldContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { activeCamera } = data;
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const cameras = selectCameras(data.cameras, searchText);
  return (
    <Box>
      <div className="CameraConsole__left">
        <Window.Content scrollable>
          <Flex
            direction={"column"}
            height="100%">
            <Flex.Item>
              <Input
                fluid
                mb={1}
                placeholder="Search for a camera"
                onInput={(e, value) => setSearchText(value)} />
            </Flex.Item>
            <Flex.Item
              height="100%">
              <Section>
                {cameras.map(camera => (
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
                      activeCamera
                      && camera.name === activeCamera.name
                      && 'Button--selected',
                    ])}
                    onClick={() => act('switch_camera', {
                      name: camera.name,
                    })}>
                    {camera.name}
                  </div>
                ))}
              </Section>
            </Flex.Item>
          </Flex>
        </Window.Content>
      </div>
    </Box>
  );
};


export const CameraByondUi = (props, context) => {
  const { act, data } = useBackend(context);
  const { mapRef, activeCamera, mapStyle } = data;
  const cameras = selectCameras(data.cameras, context.searchText);
  const [
    prevCameraName,
    nextCameraName,
  ] = prevNextCamera(cameras, activeCamera);
  return (
    <>
      <div className="CameraConsole__toolbar">
        <b>Camera: </b>
        {activeCamera
          && activeCamera.name
          || '—'}
      </div>
      <div className="CameraConsole__toolbarRight">
        <Button
          icon="chevron-left"
          disabled={!prevCameraName}
          onClick={() => act('switch_camera', {
            name: prevCameraName,
          })} />
        <Button
          icon="chevron-right"
          disabled={!nextCameraName}
          onClick={() => act('switch_camera', {
            name: nextCameraName,
          })} />
      </div>
      <ByondUi resizable
        className="CameraConsole__map"
        params={{
          id: mapRef,
          type: 'map',
          style: mapStyle,
        }} />
    </>
  );
};
