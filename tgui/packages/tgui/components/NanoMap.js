import { Component, Inferno } from 'inferno';
import { Box, Button, Flex, Icon, Tooltip } from '.';
import { useBackend } from '../backend';
import { LabeledList } from './LabeledList';
import { Slider } from './Slider';
import { resolveAsset } from '../assets';

const MAP_SIZE = 510;
/** At zoom = 1 */
const PIXELS_PER_TURF = 2;

const pauseEvent = (e) => {
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

export class NanoMap extends Component {
  constructor(props) {
    super(props);

    // Auto center based on window size
    const Xcenter = window.innerWidth / 2 - 256;
    const Ycenter = window.innerHeight / 2 - 256;

    this.state = {
      offsetX: props.offsetX ?? 0,
      offsetY: props.offsetY ?? 0,
      dragging: false,
      originX: null,
      originY: null,
      zoom: props.zoom ?? 1,
    };

    // Dragging
    this.handleDragStart = (e) => {
      this.ref = e.target;
      this.setState({
        dragging: false,
        originX: e.screenX,
        originY: e.screenY,
      });
      document.addEventListener('mousemove', this.handleDragMove);
      document.addEventListener('mouseup', this.handleDragEnd);
      pauseEvent(e);
    };

    this.handleDragMove = (e) => {
      this.setState((prevState) => {
        const state = { ...prevState };
        const newOffsetX = e.screenX - state.originX;
        const newOffsetY = e.screenY - state.originY;
        if (prevState.dragging) {
          state.offsetX += newOffsetX / state.zoom;
          state.offsetY += newOffsetY / state.zoom;
          state.originX = e.screenX;
          state.originY = e.screenY;
        } else {
          state.dragging = true;
        }
        return state;
      });
      pauseEvent(e);
    };

    this.handleDragEnd = (e) => {
      this.setState({
        dragging: false,
        originX: null,
        originY: null,
      });
      document.removeEventListener('mousemove', this.handleDragMove);
      document.removeEventListener('mouseup', this.handleDragEnd);
      props.onOffsetChange?.(e, this.state);
      pauseEvent(e);
    };

    this.handleZoom = (_e, value) => {
      this.setState((state) => {
        const newZoom = Math.min(Math.max(value, 1), 8);
        state.zoom = newZoom;
        if (props.onZoom) {
          props.onZoom(state.zoom);
        }
        return state;
      });
    };

    this.handleReset = (e) => {
      this.setState((state) => {
        state.offsetX = 0;
        state.offsetY = 0;
        state.zoom = 1;
        this.handleZoom(e, 1);
        props.onOffsetChange?.(e, state);
      });
    };
  }

  getChildContext() {
    return {
      map: {
        zoom: this.state.zoom,
      },
    };
  }

  render() {
    const { config } = useBackend(this.context);
    const { dragging, offsetX, offsetY, zoom = 1 } = this.state;
    const { children } = this.props;

    const mapUrl = resolveAsset("nanomap_" + config.mapName + "_1.png");
    const mapSize = MAP_SIZE + 'px';
    const newStyle = {
      width: mapSize,
      height: mapSize,
      overflow: 'hidden',
      position: 'relative',
      'image-rendering': 'pixelated',
      'background-image': 'url(' + mapUrl + ')',
      'background-size': 'cover',
      'background-repeat': 'no-repeat',
      'text-align': 'center',
      transform: `scale(${zoom}) translate(${offsetX}px,${offsetY}px)`,
      cursor: dragging ? 'move' : 'auto',
    };

    return (
      <Box className="NanoMap__container" overflow="hidden">
        <Box
          style={newStyle}
          textAlign="center"
          onMouseDown={this.handleDragStart}
        >
          <Box>{children}</Box>
        </Box>
        <NanoMapZoomer zoom={zoom} onZoom={this.handleZoom} />
      </Box>
    );
  }
}

NanoMap.mapSize = MAP_SIZE;

const NanoMapMarker = (props, context) => {
  const {
    map: { zoom },
  } = context;
  const { x, y, icon, tooltip, color, children, ...rest } = props;
  // For some reason the X and Y are offset by 1
  const rx = (x - 1) * PIXELS_PER_TURF;
  const ry = (y - 1) * PIXELS_PER_TURF;
  return (
    <div>
      <Tooltip content={tooltip}>
        <Box
          position="absolute"
          className="NanoMap__marker"
          lineHeight="0"
          bottom={ry + 'px'}
          left={rx + 'px'}
          width={(PIXELS_PER_TURF / zoom) + 'px'}
          height={(PIXELS_PER_TURF / zoom) + 'px'}
          {...rest}
        >
          {children}
        </Box>
      </Tooltip>
    </div>
  );
};

NanoMap.Marker = NanoMapMarker;

const NanoMapMarkerIcon = (props, context) => {
  const {
    map: { zoom },
  } = context;
  const { icon, color, ...rest } = props;
  const markerSize = PIXELS_PER_TURF + 4;
  return (
    <NanoMapMarker {...rest}>
      <Icon
        name={icon}
        color={color}
        fontSize={`${markerSize}px`}
        style={{
          position: 'relative',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
        }}
      />
    </NanoMapMarker>
  );
};

NanoMap.MarkerIcon = NanoMapMarkerIcon;

const NanoMapZoomer = (props, context) => {
  return (
    <Box className="NanoMap__zoomer">
      <LabeledList>
        <LabeledList.Item label="Zoom" labelStyle={{ 'vertical-align': 'middle' }}>
          <Flex direction="row">
            <Slider
              minValue={1}
              maxValue={8}
              stepPixelSize={10}
              format={(v) => v + 'x'}
              value={props.zoom}
              onDrag={(e, v) => props.onZoom(e, v)}
            />
            <Button ml="0.5em" float="right" icon="sync" tooltip="Reset View" onClick={(e) => props.onReset?.(e)} />
          </Flex>
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};

NanoMap.Zoomer = NanoMapZoomer;
