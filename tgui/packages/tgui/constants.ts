/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

type Gas = {
  id: string;
  path: string;
  name: string;
  label: string;
  color: string;
};

// UI states, which are mirrored from the BYOND code.
export const UI_INTERACTIVE = 2;
export const UI_UPDATE = 1;
export const UI_DISABLED = 0;
export const UI_CLOSE = -1;

// All game related colors are stored here
export const COLORS = {
  // Department colors
  department: {
    captain: '#c06616',
    security: '#e74c3c',
    medbay: '#3498db',
    science: '#9b59b6',
    engineering: '#f1c40f',
    cargo: '#f39c12',
    centcom: '#00c100',
    other: '#c38312',
  },
  // Damage type colors
  damageType: {
    oxy: '#3498db',
    toxin: '#2ecc71',
    burn: '#e67e22',
    brute: '#e74c3c',
  },
  // reagent / chemistry related colours
  reagent: {
    acidicbuffer: '#fbc314',
    basicbuffer: '#3853a4',
  },
} as const;

// Colors defined in CSS
export const CSS_COLORS = [
  'average',
  'bad',
  'black',
  'blue',
  'brown',
  'good',
  'green',
  'grey',
  'label',
  'olive',
  'orange',
  'pink',
  'purple',
  'red',
  'teal',
  'transparent',
  'violet',
  'white',
  'yellow',
] as const;

export enum Direction {
  NONE = 0,
  NORTH = 1,
  SOUTH = 2,
  EAST = 4,
  WEST = 8,
  NORTHEAST = NORTH | EAST,
  NORTHWEST = NORTH | WEST,
  SOUTHEAST = SOUTH | EAST,
  SOUTHWEST = SOUTH | WEST,
  VERTICAL = NORTH | SOUTH,
  HORIZONTAL = EAST | WEST,
  ALL = NORTH | SOUTH | EAST | WEST,
}

export type CssColor = (typeof CSS_COLORS)[number];

/* IF YOU CHANGE THIS KEEP IT IN SYNC WITH CHAT CSS */
export const RADIO_CHANNELS = [
  {
    name: 'Syndicate',
    freq: 1213,
    color: '#8f4a4b',
  },
  {
    name: 'Red Team',
    freq: 1215,
    color: '#ff4444',
  },
  {
    name: 'Blue Team',
    freq: 1217,
    color: '#3434fd',
  },
  {
    name: 'Green Team',
    freq: 1219,
    color: '#34fd34',
  },
  {
    name: 'Yellow Team',
    freq: 1221,
    color: '#fdfd34',
  },
  {
    name: 'CentCom',
    freq: 1337,
    color: '#2681a5',
  },
  {
    name: 'Supply',
    freq: 1347,
    color: '#b88646',
  },
  {
    name: 'Service',
    freq: 1349,
    color: '#6ca729',
  },
  {
    name: 'Science',
    freq: 1351,
    color: '#c68cfa',
  },
  {
    name: 'Command',
    freq: 1353,
    color: '#fcdf03',
  },
  {
    name: 'Medical',
    freq: 1355,
    color: '#57b8f0',
  },
  {
    name: 'Engineering',
    freq: 1357,
    color: '#f37746',
  },
  {
    name: 'Security',
    freq: 1359,
    color: '#dd3535',
  },
  {
    name: 'AI Private',
    freq: 1447,
    color: '#d65d95',
  },
  {
    name: 'Common',
    freq: 1459,
    color: '#1ecc43',
  },
] as const;

const GASES = [
  {
    id: 'oxygen',
    path: '/datum/xgm_gas/oxygen',
    name: 'Oxygen',
    label: 'O₂',
    color: 'blue',
  },
  {
    id: 'nitrogen',
    path: '/datum/xgm_gas/nitrogen',
    name: 'Nitrogen',
    label: 'N₂',
    color: 'yellow',
  },
  {
    id: 'carbon_dioxide',
    path: '/datum/xgm_gas/carbon_dioxide',
    name: 'Carbon Dioxide',
    label: 'CO₂',
    color: 'grey',
  },
  {
    id: 'phoron',
    path: '/datum/xgm_gas/phoron',
    name: 'Phoron',
    label: 'Phoron',
    color: 'pink',
  },
  {
    id: 'watervapor',
    path: '/datum/xgm_gas/vapor',
    name: 'Water Vapor',
    label: 'H₂O',
    color: 'lightsteelblue',
  },
  {
    id: 'sleeping_agent',
    path: '/datum/xgm_gas/sleeping_agent',
    name: 'Nitrous Oxide',
    label: 'N₂O',
    color: 'bisque',
  },
  {
    id: 'hydrogen',
    path: '/datum/xgm_gas/hydrogen',
    name: 'Hydrogen',
    label: 'H₂',
    color: 'white',
  },
  {
    id: 'deuterium',
    path: '/datum/xgm_gas/hydrogen/deuterium',
    name: 'Deuterium',
    label: 'Deuterium',
    color: 'lightblue',
  },
  {
    id: 'tritium',
    path: '/datum/xgm_gas/hydrogen/tritium',
    name: 'Tritium',
    label: 'Tritium',
    color: 'limegreen',
  },
  {
    id: 'helium',
    path: '/datum/xgm_gas/helium',
    name: 'Helium',
    label: 'He',
    color: 'aliceblue',
  },
  {
    id: 'fractol',
    path: '/datum/xgm_gas/fractol',
    name: 'Fractol',
    label: 'Fractol',
    color: 'mediumslateblue',
  },
] as const;

// Returns gas label based on gasId
export const getGasLabel = (gasId: string, fallbackValue?: string) => {
  if (!gasId) return fallbackValue || 'None';

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].id === gasSearchString) {
      return GASES[idx].label;
    }
  }

  return fallbackValue || 'None';
};

// Returns gas color based on gasId
export const getGasColor = (gasId: string) => {
  if (!gasId) return 'black';

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].id === gasSearchString) {
      return GASES[idx].color;
    }
  }

  return 'black';
};

// Returns gas object based on gasId
export const getGasFromId = (gasId: string): Gas | undefined => {
  if (!gasId) return;

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].id === gasSearchString) {
      return GASES[idx];
    }
  }
};

// Returns gas object based on gasPath
export const getGasFromPath = (gasPath: string): Gas | undefined => {
  if (!gasPath) return;

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].path === gasPath) {
      return GASES[idx];
    }
  }
};
