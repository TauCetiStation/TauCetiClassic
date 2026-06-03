/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { COLORS } from './constants';

/**
 * Darkmode preference, originally by Kmc2000.
 *
 * This lets you switch client themes by using winset.
 *
 * If you change ANYTHING in interface/skin.dmf you need to change it here.
 *
 * There's no way round it. We're essentially changing the skin by hand.
 * It's painful but it works, and is the way Lummox suggested.
 */
export function setClientTheme(name): void {
  const themeColor = COLORS[name.toUpperCase()];
  if (!themeColor) return;

  Byond.winset({
    // Main windows
    'infobuttons.background-color': themeColor.BG_BASE,
    'infobuttons.text-color': themeColor.TEXT,
    'rpane.background-color': themeColor.BG_BASE,
    'browseroutput.background-color': themeColor.BG_BASE,
    'browseroutput.text-color': themeColor.TEXT,
    'output.background-color': themeColor.BG_BASE,
    'output.text-color': themeColor.TEXT,
    'mainwindow.background-color': themeColor.BG_BASE,
    'mainvsplit.background-color': themeColor.BG_BASE,
    // Top buttons
    'textb.background-color': themeColor.BUTTON,
    'textb.text-color': themeColor.TEXT,
    'infob.background-color': themeColor.BUTTON,
    'infob.text-color': themeColor.TEXT,
    'wikib.background-color': themeColor.BUTTON,
    'wikib.text-color': themeColor.TEXT,
    'forumb.background-color': themeColor.BUTTON,
    'forumb.text-color': themeColor.TEXT,
    'rulesb.background-color': themeColor.BUTTON,
    'rulesb.text-color': themeColor.TEXT,
    'changelog.background-color': themeColor.BUTTON,
    'changelog.text-color': themeColor.TEXT,
    // Statbrowser
    'infowindow.background-color': themeColor.BG_BASE,
    'infowindow.text-color': themeColor.TEXT,
    'statbrowser.background-color': themeColor.BG_BASE,
    'statbrowser.text-color': themeColor.TEXT,
    'statbrowser.tab-background-color': themeColor.BG_BASE,
    'statbrowser.tab-text-color': themeColor.TEXT,
    'statbrowser.prefix-color': themeColor.TEXT,
    'statbrowser.suffix-color': themeColor.TEXT,
    'info.background-color': themeColor.BG_BASE,
    'info.text-color': themeColor.TEXT,
    // Say, me Buttons etc.
    'saybutton.background-color': themeColor.BG_BASE,
    'saybutton.text-color': themeColor.TEXT,
    'mebutton.background-color': themeColor.BG_BASE,
    'mebutton.text-color': themeColor.TEXT,
    'asset_cache_browser.background-color': themeColor.BG_BASE,
    'asset_cache_browser.text-color': themeColor.TEXT,
    'tooltip.background-color': themeColor.BG_BASE,
    'tooltip.text-color': themeColor.TEXT,
    // uncomment these when someone decides to get rid of shitty color changes
    // on tab press
    // 'input.background-color': themeColor.BG_SECOND,
    // 'input.text-color': themeColor.TEXT,
  });
}
