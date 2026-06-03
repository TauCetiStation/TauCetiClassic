// This is the elements from the skin.dmf that we need to adjust the fontsize of
const ELEMENTS_TO_ADJUST = [
  'infobuttons.textb',
  'infobuttons.infob',
  'infobuttons.wikib',
  'infobuttons.forumb',
  'infobuttons.rulesb',
  'infobuttons.changelog',
  'infobuttons.discord',
  'infobuttons.report-issue',
  'inputwindow.input',
  'inputbuttons.mebutton',
  'inputbuttons.saybutton',
];

export const DEFAULT_BUTTON_FONT_SIZE = 4;

export async function setDisplayScaling() {
  if (window.devicePixelRatio === 1) {
    return;
  }

  const newSizes: { [element: string]: number } = {};

  for (const element of ELEMENTS_TO_ADJUST) {
    newSizes[`${element}.font-size`] =
      DEFAULT_BUTTON_FONT_SIZE * window.devicePixelRatio;
  }

  Byond.winset(null, newSizes);
}

const PANE_SPLITTERS = {
  rpanewindow: 2,
  input_buttons_child: 90,
  output_input_child: 98,
};

export function setEditPaneSplitters(editing: boolean) {
  const toSet: { [element: string]: any } = {};

  for (const pane of Object.keys(PANE_SPLITTERS)) {
    toSet[`${pane}.show-splitter`] = editing;
  }

  Byond.winset(null, toSet);
}

export function resetPaneSplitters() {
  const toSet: { [element: string]: any } = {};

  for (const default_obj of Object.entries(PANE_SPLITTERS)) {
    toSet[`${default_obj[0]}.splitter`] = default_obj[1];
  }

  Byond.winset(null, toSet);
}
