import { Component, InfernoNode, RefObject, createRef } from 'inferno';
import { Box, Button, Dropdown, Flex, Icon, Tooltip, Stack } from '.';
import { LabeledList } from './LabeledList';
import { Slider } from './Slider';
import { resolveAsset } from '../assets';
import { BoxProps } from './Box';

const MAP_SIZE = 255;
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

interface NanoMapMarkerProps extends BoxProps {
  x: number;
  y: number;
  tooltip: InfernoNode;
  children?: InfernoNode;
}

export const NanoMapMarker = (props: NanoMapMarkerProps, context: any) => {
  const {
    map: { pixelsPerTurf },
  } = context;
  const { x, y, tooltip, children, ...rest } = props;
  // For some reason the X and Y are offset by 1
  const rx = (x - 2) * pixelsPerTurf;
  const ry = y * pixelsPerTurf;
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

interface NanoMapMarkerIconProps extends NanoMapMarkerProps {
  icon: string;
}

export const NanoMapMarkerIcon = (
  props: NanoMapMarkerIconProps,
  context: any
) => {
  const {
    map: { pixelsPerTurf },
  } = context;
  const { icon, color, ...rest } = props;
  const markerSize = pixelsPerTurf * 2;
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

type NanoMapZoomerProps = {
  zoom: number;
  onZoom: (number: number) => void;
  onReset: () => void;
  controlsOnTop: boolean;
  zLevel: number;
  onZLevel: (number: number) => void;
  availableZLevels: number[];
  levelNames: string[];
};

export const NanoMapZoomer = (props: NanoMapZoomerProps, context: any) => {
  const buildDropdown = (): InfernoNode => {
    const levelName = (zLevel: number): string =>
      props.levelNames[zLevel] ?? `UNKNOWN ${props.zLevel}`;

    const map: string[] = props.availableZLevels.reduce(
      (map: string[], zLevel: number) => {
        map[zLevel] = levelName(zLevel);
        return map;
      },
      []
    );
    return (
      <Dropdown
        over={!props.controlsOnTop}
        selected={levelName(props.zLevel)}
        options={map.filter((s: string) => s)}
        onSelected={(val: string) => {
          const index = map.indexOf(val);
          if (index) {
            props.onZLevel(index);
          }
        }}
      />
    );
  };

  return (
    <Box
      z-index={1000}
      style={{ 'z-index': 1000 }}
      position="relative"
      p={0.5}
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
                    stepPixelSize={25}
                    format={(v: number) => v.toFixed(1) + 'x'}
                    value={props.zoom}
                    onDrag={(_: MouseEvent, v: number) => props.onZoom(v)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    float="right"
                    icon="sync"
                    tooltip="Reset View"
                    onClick={(_: MouseEvent) => props.onReset()}
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        {props.availableZLevels.length > 1 && (
          <Stack.Item>{buildDropdown()}</Stack.Item>
        )}
      </Stack>
    </Box>
  );
};

type State = {
  centerX: number;
  centerY: number;
  dragging: boolean;
  originX?: number;
  originY?: number;
  zoom: number;
  zLevel: number;
};

export type NanoMapTrackData = {
  trackX: number;
  trackY: number;
  trackZ: number;
  stopTracking: () => void;
};

export type NanoMapStaticPayload = {
  stationMapName: string;
  mineMapName?: string;
  mineZLevels: number[];
  levelNames: string[];
};

type Props = {
  nanomapPayload: NanoMapStaticPayload;
  availableZLevels: number[];
  zLevel: number;
  setZLevel: (zLevel: number) => void;
  onZoom?: (zoom: number) => void;
  onCenterChange?: (centerX: number, centerY: number) => void;
  controlsOnTop?: boolean;
  pixelsPerTurf?: number;
  trackData?: NanoMapTrackData;
};

export class NanoMap extends Component<Props, State> {
  static mapSize = MAP_SIZE;

  static defaultProps = { pixelsPerTurf: 1, controlsOnTop: false };

  ref?: RefObject<HTMLDivElement>;

  constructor(props: Props) {
    super(props);
    this.ref = createRef();
    this.state = {
      centerX: MAP_SIZE / 2,
      centerY: MAP_SIZE / 2,
      dragging: false,
      originX: null,
      originY: null,
      zoom: 1,
      zLevel: props.zLevel,
    };
  }

  handleDragStart = (e: MouseEvent) => {
    this.props.trackData?.stopTracking();
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
        this.props.onCenterChange?.(this.state.centerX, this.state.centerY);
      }
    );
    document.removeEventListener('mousemove', this.handleDragMove);
    document.removeEventListener('mouseup', this.handleDragEnd);
    pauseEvent(e);
  };

  componentDidUpdate(
    prevProps: Readonly<{ children?: InfernoNode } & Props>,
    prevState: Readonly<State>,
    snapshot: any
  ): void {
    const { trackData } = this.props;
    if (prevProps.trackData !== trackData) {
      if (trackData) {
        if (!prevProps.trackData) {
          this.zoomToPoint(4);
        }
        this.setState(
          (prevState) => {
            const state = { ...prevState };
            const zoom = transformZoom(state.zoom);
            // God forgive me, my math is terribly wrong but somehow gives right result....
            const halfSize = MAP_SIZE / 2;
            state.centerX = halfSize - (trackData.trackX - halfSize) * zoom;
            state.centerY = halfSize + (trackData.trackY - halfSize) * zoom;
            return state;
          },
          () => {
            this.props.onCenterChange?.(this.state.centerX, this.state.centerY);
          }
        );

        if (trackData.trackZ !== this.state.zLevel) {
          if (this.props.availableZLevels.indexOf(trackData.trackZ) !== -1) {
            this.handleZLevel(trackData.trackZ, false);
          } else {
            if (this.props.availableZLevels.length) {
              this.handleZLevel(this.props.availableZLevels[0]);
            } else {
              // No Z level to switch to...
              this.props.trackData?.stopTracking();
            }
          }
        }
      }
    } else if (
      this.props.availableZLevels.length &&
      this.props.availableZLevels.indexOf(this.state.zLevel) === -1
    ) {
      this.handleZLevel(this.props.availableZLevels[0]);
    }
  }

  handleDragMove = (e: MouseEvent) => {
    this.setState((prevState) => {
      const state = { ...prevState };
      const pixelsPerTurf = this.props.pixelsPerTurf;
      const newOffsetX = e.screenX - state.originX;
      const newOffsetY = e.screenY - state.originY;
      if (prevState.dragging) {
        state.centerX += newOffsetX / pixelsPerTurf;
        state.centerY += newOffsetY / pixelsPerTurf;
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
        centerX: MAP_SIZE / 2,
        centerY: MAP_SIZE / 2,
        zoom: 1,
      },
      () => {
        this.props.onCenterChange?.(this.state.centerX, this.state.centerY);
        this.props.onZoom?.(this.state.zoom);
      }
    );
  };

  getChildContext() {
    return {
      map: {
        zoom: this.state.zoom,
        zoomConverted: transformZoom(this.state.zoom),
        pixelsPerTurf: this.props.pixelsPerTurf,
      },
    };
  }

  handleZLevel = (value: number, stopTracking: boolean = true) => {
    if (stopTracking) {
      this.props.trackData?.stopTracking();
    }

    this.setState({ zLevel: value }, () => {
      this.props.setZLevel(value);
    });
  };

  zoomToPoint = (
    // Works incorrectly cos doesnt count center pos but works for now
    zoom: number,
    toX: number = MAP_SIZE / 2,
    toY: number = MAP_SIZE / 2
  ) => {
    const newZoom = Math.min(6, Math.max(0.5, zoom));

    this.setState(
      (prevState) => {
        const state = { ...prevState };
        const x = toX - state.centerX;
        const y = toY - state.centerY;
        const exponentialOldZoom = transformZoom(state.zoom);
        const exponentialNewZoom = transformZoom(newZoom);
        state.centerX += x - (x / exponentialOldZoom) * exponentialNewZoom;
        state.centerY += y - (y / exponentialOldZoom) * exponentialNewZoom;
        state.zoom = newZoom;
        return state;
      },
      () => {
        this.props.onCenterChange?.(this.state.centerX, this.state.centerY);
        this.props.onZoom?.(this.state.zoom);
      }
    );
  };

  handleScroll = (e: WheelEvent) => {
    this.props.trackData?.stopTracking();
    let zoomChange = 0;
    if (e.deltaY > 0) {
      zoomChange = -0.5;
    } else if (e.deltaY < 0) {
      zoomChange = 0.5;
    }
    const boundingBox = this.ref.current.getBoundingClientRect();

    const pixelsPerTurf = this.props.pixelsPerTurf;

    const mouseX = (e.clientX - boundingBox.x) / pixelsPerTurf;
    const mouseY = (e.clientY - boundingBox.y) / pixelsPerTurf;

    this.zoomToPoint(this.state.zoom + zoomChange, mouseX, mouseY);

    pauseEvent(e);
  };

  getMapImageName = () => {
    if (
      this.props.nanomapPayload.mineMapName &&
      this.props.nanomapPayload.mineZLevels.includes(this.state.zLevel)
    ) {
      return `nanomap_${this.props.nanomapPayload.mineMapName}_1.png`;
    }
    return `nanomap_${this.props.nanomapPayload.stationMapName}_1.png`;
  };

  render() {
    const { dragging, centerX, centerY, zoom = 1 } = this.state;
    const { children } = this.props;

    const exponentialZoom = transformZoom(zoom);

    const mapUrl = resolveAsset(this.getMapImageName());
    const pixelsPerTurf = this.props.pixelsPerTurf;
    const mapSize = MAP_SIZE * this.props.pixelsPerTurf + 'px';
    const mapStyle = {
      width: mapSize,
      height: mapSize,
      overflow: 'hidden',
      position: 'relative',
      'z-index': 0,
      'object-fit': 'cover',
      'image-rendering': 'pixelated',
      'background-image': 'url(' + mapUrl + ')',
      'background-size': 'cover',
      'background-repeat': 'no-repeat',
      'text-align': 'center',
      transform: `translate(${(centerX - MAP_SIZE / 2) * pixelsPerTurf}px,${(centerY - MAP_SIZE / 2) * pixelsPerTurf}px) scale(${exponentialZoom})`,
      'transform-origin': 'center',
      transition: `${this.state.dragging ? '0s' : '0.075s'} linear`,
    };

    const backgroundUrl = resolveAsset('nanomapBackground.png');

    const backgroundStyle = {
      overflow: 'hiddden',
      position: 'relative',
      width: '100%',
      height: '100%',
      'background-image': `url(${backgroundUrl})`,
      cursor: dragging ? 'move' : 'auto',
    };

    const zoomer = (
      <NanoMapZoomer
        zoom={zoom}
        onZoom={this.handleZoom}
        zLevel={this.state.zLevel}
        availableZLevels={this.props.availableZLevels}
        levelNames={this.props.nanomapPayload.levelNames}
        onZLevel={this.handleZLevel}
        onReset={this.handleReset}
        controlsOnTop={this.props.controlsOnTop}
      />
    );

    return (
      <Box style={backgroundStyle} onWheel={this.handleScroll}>
        {this.props.controlsOnTop && zoomer}
        <div ref={this.ref} onMouseDown={this.handleDragStart}>
          <Box style={mapStyle} textAlign="center">
            <Box>{children}</Box>
          </Box>
        </div>
        {!this.props.controlsOnTop && zoomer}
      </Box>
    );
  }
}
