/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { FONTS_DISABLED } from './constants';
import { setClientTheme } from './themes';
import type { SettingsState } from './types';

let statFontSizeTimer: NodeJS.Timeout;
let statFontFamilyTimer: NodeJS.Timeout;
let overrideFontFamily: string | undefined;
let overrideFontSize: string;

/** Updates the global CSS rule to override the font family and size. */
function updateGlobalOverrideRule(): void {
  let fontFamily: string | null = null;

  if (overrideFontFamily !== undefined) {
    fontFamily = overrideFontFamily;
  }

  document.documentElement.style.setProperty('font-family', fontFamily);
  document.body.style.setProperty('font-family', fontFamily);
  document.body.style.setProperty('font-size', overrideFontSize);
}

function setGlobalFontSize(
  fontSize: number,
  statFontSize: number,
  statLinked: boolean,
  statFontSizeDefault: boolean,
): void {
  overrideFontSize = `${fontSize}px`;

  const statFontSizePt = statLinked
    ? Math.trunc((fontSize / 4) * 3)
    : statFontSizeDefault
      ? ''
      : statFontSize;
  // Used solution from theme.ts
  clearInterval(statFontSizeTimer);
  Byond.winset(null, {
    'statbrowser.font-size': statFontSizePt,
    'statbrowser.tab-font-size': statFontSizePt,
  });
  statFontSizeTimer = setTimeout(() => {
    Byond.winset(null, {
      'statbrowser.font-size': statFontSizePt,
      'statbrowser.tab-font-size': statFontSizePt,
    });
  }, 1500);
}

function setGlobalFontFamily(
  fontFamily: string,
  statFontFamily: string,
  statLinked: boolean,
): void {
  overrideFontFamily = fontFamily === FONTS_DISABLED ? undefined : fontFamily;

  const statFontFamilyOverride = statLinked
    ? overrideFontFamily
    : statFontFamily;
  // Used solution from theme.ts
  clearInterval(statFontFamilyTimer);
  Byond.winset(null, {
    'statbrowser.font-family': statFontFamilyOverride,
    'statbrowser.tab-font-family': statFontFamilyOverride,
  });
  statFontFamilyTimer = setTimeout(() => {
    Byond.winset(null, {
      'statbrowser.font-family': statFontFamilyOverride,
      'statbrowser.tab-font-family': statFontFamilyOverride,
    });
  }, 1500);
}

export function generalSettingsHandler(update: SettingsState): void {
  // Set client theme
  const theme = update?.theme;
  if (theme) {
    setClientTheme(theme);
  }

  // Update global UI font size
  setGlobalFontSize(
    update.fontSize,
    update.statFontSize,
    update.statLinked,
    update.statFontSizeDefault,
  );
  setGlobalFontFamily(
    update.fontFamily,
    update.statFontFamily,
    update.statLinked,
  );
  updateGlobalOverrideRule();
}
