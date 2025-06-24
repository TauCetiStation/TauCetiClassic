import { Component, Inferno } from 'inferno';
import { Box, Button, Dropdown, Flex, Icon, Tooltip, Stack } from '.';
import { useBackend } from '../backend';
import { LabeledList } from './LabeledList';
import { Slider } from './Slider';
import { resolveAsset } from '../assets';
import { stat } from 'fs';

const MAP_SIZE = 510;
/** At zoom = 1 */
const PIXELS_PER_TURF = 2;

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
          width={PIXELS_PER_TURF / zoom + 'px'}
          height={PIXELS_PER_TURF / zoom + 'px'}
          {...rest}>
          {children}
        </Box>
      </Tooltip>
    </div>
  );
};

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

const NanoMapZoomer = (props, context) => {
  return (
    <Box className="NanoMap__zoomer">
      <Stack>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="Zoom">
              <Stack>
                <Stack.Item grow>
                  <Slider
                    minValue={1}
                    maxValue={8}
                    step={0.5}
                    stepPixelSize={10}
                    format={(v) => v + 'x'}
                    value={props.zoom}
                    onDrag={(e, v) => props.onZoom(e, v)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    ml="0.5em"
                    float="right"
                    icon="sync"
                    tooltip="Reset View"
                    onClick={(e) => props.onReset?.(e)}
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Z-Level">
              <Dropdown
                selected={props.zLevel}
                options={props.availableZLevels}
                onSelected={props.onZLevel}
              />
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

type State = {
  offsetX: number;
  offsetY: number;
  dragging: boolean;
  originX?: number;
  originY?: number;
  zoom: number;
  zLevel: number;
};

type Props = {
  stationMapName: string;
  mineMapName?: string;
  mineLevels: number[];
  availableZLevels: number[];
  zLevel: number;
  setZLevel: (zLevel: number) => void;
  onZoom?: (zoom: number) => void;
  onOffsetChange?: (event: MouseEvent, state: State) => void;
};

export class NanoMap extends Component<Props, State> {
  static mapSize = MAP_SIZE;

  static Marker = NanoMapMarker;

  static Zoomer = NanoMapZoomer;

  static MarkerIcon = NanoMapMarkerIcon;

  ref: EventTarget;

  constructor(props: Props) {
    super(props);

    this.state = {
      offsetX: 0,
      offsetY: 0,
      dragging: false,
      originX: null,
      originY: null,
      zoom: 1,
      zLevel: props.zLevel,
    };
  }

  handleDragStart = (e: MouseEvent) => {
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

  handleDragEnd = (e: MouseEvent) => {
    this.setState(
      {
        dragging: false,
        originX: null,
        originY: null,
      },
      () => {
        this.props.onOffsetChange?.(e, this.state);
      }
    );
    document.removeEventListener('mousemove', this.handleDragMove);
    document.removeEventListener('mouseup', this.handleDragEnd);
    pauseEvent(e);
  };

  handleDragMove = (e: MouseEvent) => {
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

  handleZoom = (_e: MouseEvent, value: number) => {
    const newZoom = Math.min(Math.max(value, 1), 8);
    this.setState({ zoom: newZoom });
    this.props.onZoom?.(newZoom);
  };

  handleReset = (e: MouseEvent) => {
    this.setState(
      {
        offsetX: 0,
        offsetY: 0,
        zoom: 1,
        zLevel: this.props.availableZLevels.at(0),
      },
      () => {
        this.props.onOffsetChange?.(e, this.state);
      }
    );
    this.handleZoom(e, 1);
  };

  getChildContext() {
    return {
      map: {
        zoom: this.state.zoom,
      },
    };
  }

  handleZLevel = (value: number) => {
    this.setState({ zLevel: value }, () => {
      this.props.setZLevel(value);
    });
  };

  getMapName = () => {
    if (
      this.props.mineMapName &&
      this.props.mineLevels.includes(this.state.zLevel)
    ) {
      return `nanomap_${this.props.mineMapName}_${this.state.zLevel}.png`;
    }
    return `nanomap_${this.props.stationMapName}_1.png`;
  };

  render() {
    const { dragging, offsetX, offsetY, zoom = 1 } = this.state;
    const { children } = this.props;

    const mapUrl = resolveAsset(this.getMapName());
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
          onMouseDown={this.handleDragStart}>
          <Box>{children}</Box>
        </Box>
        <NanoMapZoomer
          zoom={zoom}
          onZoom={this.handleZoom}
          zLevel={this.state.zLevel}
          availableZLevels={this.props.availableZLevels}
          onZLevel={this.handleZLevel}
          onReset={this.handleReset}
        />
      </Box>
    );
  }
}
