import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useLayoutEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import { resolveAsset } from 'tgui/assets';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Slider,
  Stack,
  Tooltip,
} from 'tgui-core/components';

const MAP_MIN = 1;
const MAP_MAX = 255;
const NANOMAP_SIZE = 256; // nanomaps are sized to cover 256x256 turfs; HWO??
const MAP_SIZE = 255;
const MAP_MIDDLE = (MAP_MIN + MAP_MAX) / 2;
const MIN_ZOOM = 0.5;
const MAX_ZOOM = 6;
const ZOOM_STEP = 0.5;

function pauseEvent(
  e: React.MouseEvent | React.PointerEvent | React.WheelEvent,
) {
  if (e.stopPropagation) e.stopPropagation();
  if (e.preventDefault && e.cancelable) e.preventDefault();
  return false;
}

const transformZoom = (value: number): number => {
  // exponential mapping: value can be negative; returns multiplicative scale
  return Math.exp((value - 1) * 0.5);
};

export const MapContext = createContext<{
  scaleFactor: number;
  containerRef: React.RefObject<HTMLDivElement | null>;
  centerX: number;
  centerY: number;
  dragging: boolean;
}>({
  scaleFactor: 2,
  containerRef: { current: null },
  centerX: MAP_MIDDLE,
  centerY: MAP_MIDDLE,
  dragging: false,
});

export type NanoMapStaticPayload = {
  [zLevel: number]: {
    name: string;
    mapTexture?: string;
  };
};

type NanoMapProps = {
  nanomapPayload: NanoMapStaticPayload;
  // current zLevel to display; parent component is responsible for managing this state and providing a callback to change it
  zLevel: number;
  // list of zLevels available in the payload; used to render zLevel selector if more than 1 level is present
  availableZLevels?: number[];
  // callback to request zLevel change; parent component should update the zLevel prop in response
  onZLevel: (zLevel: number) => void;
  // zoom level; will change to this zoom level if updated
  zoom?: number;
  // initial zoom (scaling) level
  pixelsPerTurf?: number;
  // initial center of the map in turf coordinates (1-255); defaults to middle of the map; if either centerX or centerY is updated, the map will jump to origin location
  centerX?: number;
  centerY?: number;
  // optional callback that, if provided, will be called on user interactions that would change the view (dragging, zooming) to allow parent components to stop any automatic tracking of entities on the map
  stopTracking?: () => void;
  // whether to render controls above map (true) or below (false)
  controlsOnTop?: boolean;
  // elements to render on the map. NanoMapMarker to tie a marker to a specific location, or any absolute-positioned element that may use the MapContext to position itself relative to the map center and zoom
  children?: React.ReactNode;
};

export function NanoMap(props: NanoMapProps) {
  const initialPixelsPerTurf = props.pixelsPerTurf ?? 2;

  const [centerX, setCenterX] = useState<number>(props.centerX ?? MAP_MIDDLE);
  const [centerY, setCenterY] = useState<number>(props.centerY ?? MAP_MIDDLE);
  const [dragging, setDragging] = useState<boolean>(false);
  const draggingRef = useRef<boolean>(false);
  const dragStartRef = useRef<{ x: number; y: number }>({ x: 0, y: 0 });
  const [zoom, setZoom] = useState<number>(props.zoom ?? 1);
  const containerRef = useRef<HTMLDivElement | null>(null);
  const [viewportSize, setViewportSize] = useState<{ w: number; h: number }>({
    w: 500,
    h: 500,
  });
  const mountedRef = useRef(false); // track mounted state to avoid updates before first render

  // props-driven controlled updates
  useEffect(() => {
    if (props.zoom !== undefined) {
      handleZoomChange(props.zoom, centerX, centerY);
    }
  }, [props.zoom]);

  useEffect(() => {
    if (props.centerX !== undefined && props.centerY !== undefined) {
      setCenterX(props.centerX);
      setCenterY(MAP_SIZE - props.centerY);
    }
  }, [props.centerX, props.centerY]);

  // measure container size
  useLayoutEffect(() => {
    function measure() {
      const rect = containerRef.current?.getBoundingClientRect();
      if (rect) setViewportSize({ w: rect.width, h: rect.height });
    }
    measure();
    const ro = new ResizeObserver(measure);
    if (containerRef.current) ro.observe(containerRef.current);
    return () => ro.disconnect();
  }, []);

  // mark mounted after first render to enable transitions
  useEffect(() => {
    mountedRef.current = true;
  }, []);

  const handleZoomChange = (
    newZoomPlain: number,
    zoomCenterTurfX: number,
    zoomCenterTurfY: number,
  ) => {
    const oldZoomPlain = zoom;
    const newZoomClamped = Math.max(MIN_ZOOM, Math.min(MAX_ZOOM, newZoomPlain));
    const oldZoomTransformed = transformZoom(oldZoomPlain);
    const newZoomTransformed = transformZoom(newZoomClamped);

    // Center update formula so the turf point (zoomCenterTurfX, zoomCenterTurfY) remains fixed relative to viewport:
    // newCenter = zoomCenter - (zoomCenter - oldCenter) * (s0 / s1)
    setCenterX(
      (oldCenterX) =>
        zoomCenterTurfX -
        (zoomCenterTurfX - oldCenterX) *
          (oldZoomTransformed / newZoomTransformed),
    );
    setCenterY(
      (oldCenterY) =>
        zoomCenterTurfY -
        (zoomCenterTurfY - oldCenterY) *
          (oldZoomTransformed / newZoomTransformed),
    );

    setZoom(newZoomClamped);
  };

  const renderScale = initialPixelsPerTurf * transformZoom(zoom);

  // Convert a screen/client point (clientX, clientY) to turf coords (MAP_MIN..MAP_MAX)
  const screenToTurf = (clientX: number, clientY: number) => {
    const rect = containerRef.current?.getBoundingClientRect();
    if (!rect) return { x: 0, y: 0 };

    // viewport center in pixels
    const vx = rect.left + rect.width / 2;
    const vy = rect.top + rect.height / 2;

    // pixel offset from viewport center to the client point
    const dx = clientX - vx;
    const dy = clientY - vy;

    // convert pixels -> turf using renderScale, accounting that centerX/centerY are at viewport center
    const turfX = centerX + dx / renderScale;
    const turfY = centerY + dy / renderScale;

    return { x: turfX, y: turfY };
  };

  const handleScroll = (e: React.WheelEvent) => {
    if (e.deltaY === 0) return;
    props.stopTracking?.();

    // adjust controller by a small step; wheel down (deltaY>0) -> zoom out
    const step = ZOOM_STEP;
    const next = zoom + (e.deltaY > 0 ? -step : step);

    const cursorTurf = screenToTurf(e.clientX, e.clientY);
    handleZoomChange(next, cursorTurf.x, cursorTurf.y);
    pauseEvent(e);
  };

  const handlePointerDown = (e: React.PointerEvent) => {
    // only start drag if clicking on the map itself
    if (!(e.target instanceof Element) || e.target.closest('[data-not-map]')) {
      return;
    }

    draggingRef.current = true;
    setDragging(true);
    dragStartRef.current = { x: e.clientX, y: e.clientY };
    pauseEvent(e);
    props.stopTracking?.();
    e.currentTarget.setPointerCapture(e.pointerId);
  };

  const handlePointerMove = (e: React.PointerEvent) => {
    if (!draggingRef.current) return;
    const deltaX = e.clientX - dragStartRef.current.x;
    const deltaY = e.clientY - dragStartRef.current.y;

    // move center by pixel delta converted to turf units (pixels / renderScale)
    setCenterX((prev) => prev - deltaX / renderScale); // minus because dragging moves map opposite to pointer
    setCenterY((prev) => prev - deltaY / renderScale);
    dragStartRef.current = { x: e.clientX, y: e.clientY };
  };

  const handlePointerUp = useCallback((e: React.PointerEvent) => {
    draggingRef.current = false;
    requestAnimationFrame(() => setDragging(false));
    (e.currentTarget as Element)?.releasePointerCapture(e.pointerId);
  }, []);

  const handlePointerCancel = (e) => {
    draggingRef.current = false;
    requestAnimationFrame(() => setDragging(false));
  };

  // clamp center to map bounds
  useEffect(() => {
    setCenterX((c) => Math.max(MAP_MIN, Math.min(MAP_MAX, c)));
    setCenterY((c) => Math.max(MAP_MIN, Math.min(MAP_MAX, c)));
  }, [centerX, centerY]); // run after changes

  // image / background setup
  const backgroundUrl = resolveAsset('nanomapBackground.png');
  const mapAssetUrl = (() => {
    const mapName = props.nanomapPayload[props.zLevel]?.mapTexture;
    if (mapName) {
      return resolveAsset(`nanomap_${mapName}_1.png`);
    }
    return undefined;
  })();

  // The map image size in pixels
  const mapPxSize = NANOMAP_SIZE * renderScale;

  // Compute translation so that centerX,centerY (in turf) is placed at viewport center
  const translateX = viewportSize.w / 2 - centerX * renderScale;
  const translateY = viewportSize.h / 2 - centerY * renderScale;

  const containerStyle: React.CSSProperties = {
    overflow: 'hidden',
    position: 'relative',
    width: '100%',
    height: '100%',
    backgroundImage: `url(${backgroundUrl})`,
    backgroundSize: `${mapPxSize}px ${mapPxSize}px`,
    backgroundPosition: `${translateX}px ${translateY}px`,
    imageRendering: 'crisp-edges',
    transition: dragging || !mountedRef.current ? 'none' : '0.2s ease-out',
  };

  const imgStyle: React.CSSProperties = {
    position: 'absolute',
    left: 0,
    top: 0,
    width: '100%',
    height: '100%',
    backgroundImage: `url(${mapAssetUrl})`,
    backgroundSize: `${mapPxSize}px ${mapPxSize}px`,
    backgroundPosition: `${translateX}px ${translateY}px`,
    backgroundRepeat: 'no-repeat',
    imageRendering: 'crisp-edges',
    userSelect: 'none',
    pointerEvents: 'none',
    transition: dragging || !mountedRef.current ? 'none' : '0.2s ease-out',
  };

  return (
    <MapContext.Provider
      value={{
        scaleFactor: renderScale,
        centerX,
        centerY,
        containerRef,
        dragging,
      }}
    >
      <div
        ref={containerRef}
        style={containerStyle}
        onWheel={handleScroll}
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
        onPointerUp={handlePointerUp}
        onPointerCancel={handlePointerCancel}
      >
        <div style={imgStyle} />

        <Box data-not-map>{props.children}</Box>

        <Box
          p={1}
          width="100%"
          position="absolute"
          bottom={props.controlsOnTop ? undefined : 0}
          top={props.controlsOnTop ? 0 : undefined}
          data-not-map
        >
          <NanoMapZoomer
            nanomapPayload={props.nanomapPayload}
            zLevel={props.zLevel}
            availableZLevels={props.availableZLevels}
            onZLevel={props.onZLevel}
            zoom={zoom}
            onZoom={(newZoom) => handleZoomChange(newZoom, centerX, centerY)}
            onReset={() => {
              setZoom(1);
              setCenterX(MAP_MIDDLE);
              setCenterY(MAP_MIDDLE);
            }}
            controlsOnTop={props.controlsOnTop}
          />
        </Box>
      </div>
    </MapContext.Provider>
  );
}

type NanoMapZoomerProps = {
  nanomapPayload: NanoMapStaticPayload;
  zLevel: number;
  availableZLevels?: number[];
  onZLevel: (zLevel: number) => void;
  zoom: number;
  onZoom: (newZoom: number) => void;
  onReset: () => void;
  controlsOnTop?: boolean;
};

function NanoMapZoomer(props: NanoMapZoomerProps) {
  const levelName = (zLevel: number): string =>
    props.nanomapPayload[zLevel]?.name ?? `UNKNOWN ${props.zLevel}`;

  const levelNames = useMemo(
    () => props.availableZLevels?.map(levelName) ?? [levelName(props.zLevel)],
    [props.availableZLevels],
  );

  return (
    <Stack>
      <Stack.Item grow>
        <Slider
          minValue={MIN_ZOOM}
          maxValue={MAX_ZOOM}
          value={props.zoom}
          step={ZOOM_STEP}
          format={(v: number) => `${v.toFixed(1)}x`}
          onChange={(_, newZoom) => props.onZoom(newZoom)}
          tickWhileDragging
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="sync"
          tooltip="Reset View"
          onClick={() => props.onReset()}
        />
      </Stack.Item>

      {levelNames.length > 1 && (
        <Stack.Item>
          <Dropdown
            over={!props.controlsOnTop}
            selected={levelName(props.zLevel)}
            options={levelNames}
            onSelected={(val: string) => {
              const index = levelNames.indexOf(val);
              if (index !== -1) {
                props.onZLevel(index);
              }
            }}
          />
        </Stack.Item>
      )}
    </Stack>
  );
}

type BoxProps = React.ComponentProps<typeof Box>;

type NanoMapMarkerProps = {
  x: number;
  y: number;
  tooltip?: React.ReactNode;
  children?: React.ReactNode;
} & BoxProps;

function NanoMapMarker(props: NanoMapMarkerProps) {
  const { scaleFactor, centerX, centerY, containerRef, dragging } =
    useContext(MapContext);
  const { x, y, tooltip, children, ...rest } = props;
  if (!containerRef.current) return null;
  const rect = containerRef.current?.getBoundingClientRect();
  const rx = rect.width / 2 + (x - 1.75 - (centerX - 1)) * scaleFactor;
  const ry =
    rect.height / 2 + (NANOMAP_SIZE - (y + 0.25) - (centerY - 1)) * scaleFactor;
  return (
    <Tooltip content={tooltip}>
      <Box
        position="absolute"
        top={`${ry}px`}
        left={`${rx}px`}
        lineHeight={0}
        height={0}
        width={0}
        style={{
          transform: `scale(${scaleFactor})`,
          transformOrigin: 'center',
          transition: dragging ? 'none' : '0.2s ease-out',
        }}
        {...rest}
      >
        <div
          style={{
            whiteSpace: 'nowrap',
            width: 'max-content',
            height: 'max-content',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            transform: 'translate(-50%, -50%)',
          }}
        >
          {children}
        </div>
      </Box>
    </Tooltip>
  );
}

NanoMap.Marker = NanoMapMarker;

type NanoMapMarkerIconProps = {
  icon: string;
  color?: string;
} & NanoMapMarkerProps;

function NanoMapMarkerIcon(props: NanoMapMarkerIconProps) {
  const { icon, color, ...rest } = props;
  return (
    <NanoMapMarker {...rest}>
      <Icon name={icon} color={color} fontSize={`2px`} />
    </NanoMapMarker>
  );
}

NanoMap.MarkerIcon = NanoMapMarkerIcon;
