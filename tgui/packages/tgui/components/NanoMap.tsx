import { Component, RefObject, createRef } from 'inferno';
import { Box, Button, Dropdown, Flex, Icon, Tooltip, Stack } from '.';
import { LabeledList } from './LabeledList';
import { Slider } from './Slider';
import { resolveAsset } from '../assets';

const PIXELS_PER_TURF = 1;
const MAP_SIZE = 255 * PIXELS_PER_TURF;
/** At zoom = 1 */

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

const transformZoom = (value: number): number => {
  return Math.exp((value - 1) * 0.5);
};

const NanoMapMarker = (props, context) => {
  const {
    map: { zoom },
  } = context;
  const { x, y, icon, tooltip, color, children, ...rest } = props;
  // For some reason the X and Y are offset by 1
  const rx = (x - 2) * PIXELS_PER_TURF;
  const ry = y * PIXELS_PER_TURF;
  return (
    <div>
      <Tooltip content={tooltip}>
        <Box
          position="absolute"
          lineHeight="0"
          bottom={ry + 'px'}
          left={rx + 'px'}
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
  const markerSize = PIXELS_PER_TURF * 2;
  return (
    <NanoMapMarker {...rest}>
      <Icon
        name={icon}
        color={color}
        fontSize={`${markerSize}px`}
        style={{
          position: 'absolute',
        }}
      />
    </NanoMapMarker>
  );
};

const NanoMapZoomer = (props, context) => {
  return (
    <Box
      z-index={1000}
      position="relative"
      backgroundColor={'hsla(0, 0%, 0%, 0.33)'}>
      <Stack align="baseline">
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="Zoom">
              <Stack>
                <Stack.Item grow>
                  <Slider
                    minValue={0.5}
                    maxValue={6}
                    step={0.5}
                    stepPixelSize={10}
                    format={(v) => v.toFixed(1) + 'x'}
                    value={props.zoom}
                    onDrag={(e, v) => props.onZoom(v)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    float="right"
                    icon="sync"
                    tooltip="Reset View"
                    onClick={(e) => props.onReset()}
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        {props.availableZLevels.length > 1 && (
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Z-Level">
                <Dropdown
                  over
                  selected={props.zLevel}
                  options={props.availableZLevels}
                  onSelected={props.onZLevel}
                  width={'50px'}
                />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        )}
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
  onOffsetChange?: (offsetX: number, offsetY: number) => void;
};

export class NanoMap extends Component<Props, State> {
  static mapSize = MAP_SIZE;

  static Marker = NanoMapMarker;

  static Zoomer = NanoMapZoomer;

  static MarkerIcon = NanoMapMarkerIcon;

  ref?: RefObject<HTMLDivElement>;

  constructor(props: Props) {
    super(props);
    this.ref = createRef();
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
        this.props.onOffsetChange?.(this.state.offsetX, this.state.offsetY);
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
        state.offsetX += newOffsetX;
        state.offsetY += newOffsetY;
        state.originX = e.screenX;
        state.originY = e.screenY;
      } else {
        state.dragging = true;
      }
      return state;
    });
    pauseEvent(e);
  };

  handleZoom = (value: number) => {
    this.zoomToPoint(value);
  };

  handleReset = () => {
    this.setState(
      {
        offsetX: 0,
        offsetY: 0,
        zoom: 1,
      },
      () => {
        this.props.onOffsetChange?.(this.state.offsetX, this.state.offsetY);
        this.props.onZoom?.(this.state.zoom);
      }
    );
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

  zoomToPoint = (zoom: number, toX?: number, toY?: number) => {
    const newZoom = Math.min(6, Math.max(0.5, zoom));

    this.setState(
      (prevState) => {
        const state = { ...prevState };
        const x = (toX ?? MAP_SIZE / 2) - state.offsetX;
        const y = (toY ?? MAP_SIZE / 2) - state.offsetY;
        const exponentialOldZoom = transformZoom(state.zoom);
        const exponentialNewZoom = transformZoom(newZoom);
        state.offsetX += x - (x / exponentialOldZoom) * exponentialNewZoom;
        state.offsetY += y - (y / exponentialOldZoom) * exponentialNewZoom;
        state.zoom = newZoom;
        return state;
      },
      () => {
        this.props.onOffsetChange?.(this.state.offsetX, this.state.offsetY);
        this.props.onZoom?.(this.state.zoom);
      }
    );
  };

  handleScroll = (e: WheelEvent) => {
    let zoomChange = 0;
    if (e.deltaY > 0) {
      zoomChange = -0.5;
    } else if (e.deltaY < 0) {
      zoomChange = 0.5;
    }
    const boundingBox = this.ref.current.getBoundingClientRect();

    const mouseX = e.clientX - boundingBox.x;
    const mouseY = e.clientY - boundingBox.y;
    this.zoomToPoint(this.state.zoom + zoomChange, mouseX, mouseY);

    pauseEvent(e);
  };

  getMapName = () => {
    if (
      this.props.mineMapName &&
      this.props.mineLevels.includes(this.state.zLevel)
    ) {
      return `nanomap_${this.props.mineMapName}_1.png`;
    }
    return `nanomap_${this.props.stationMapName}_1.png`;
  };

  render() {
    const { dragging, offsetX, offsetY, zoom = 1 } = this.state;
    const { children } = this.props;

    const exponentialZoom = transformZoom(zoom);

    const mapUrl = resolveAsset(this.getMapName());
    const mapSize = MAP_SIZE + 'px';
    const mapStyle = {
      width: mapSize,
      height: mapSize,
      overflow: 'hidden',
      position: 'relative',
      'object-fit': 'cover',
      'image-rendering': 'pixelated',
      'background-image': 'url(' + mapUrl + ')',
      'background-size': 'cover',
      'background-repeat': 'no-repeat',
      'text-align': 'center',
      transform: `translate(${offsetX}px,${offsetY}px) scale(${exponentialZoom})`,
      'transform-origin': 'top left',
      transition: `${this.state.dragging ? '0s' : '0.075s'} linear`,
      cursor: dragging ? 'move' : 'auto',
    };

    const backgroundUrl = resolveAsset('nanomapBackground.png');

    const backgroundStyle = {
      overflow: 'hiddden',
      width: '100%',
      'z-index': 0,
      'background-image': `url(${backgroundUrl})`,
    };

    return (
      <div style={backgroundStyle} onWheel={this.handleScroll} ref={this.ref}>
        <Box
          style={mapStyle}
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
      </div>
    );
  }
}
