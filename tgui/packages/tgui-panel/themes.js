/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const THEMES = ['light', 'dark'];

const COLOR_DARK_BG = '#202020';
const COLOR_DARK_BG_DARKER = '#171717';
const COLOR_DARK_TEXT = '#a4bad6';

let setClientThemeTimer = null;

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
export const setClientTheme = name => {
  // Transmit once for fast updates and again in a little while in case we won
  // the race against statbrowser init.
  clearInterval(setClientThemeTimer);
  Byond.command(`.output statbrowser:set_theme ${name}`);
  setClientThemeTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_theme ${name}`);
  }, 1500);

  if (name === 'light') {
    return Byond.winset({
      // Main windows
      'rpanewindow.background-color': 'none',
      'rpanewindow.text-color': '#000000',
      'rpane.background-color': 'none',
      'rpane.text-color': '#000000',
      'browseroutput.background-color': 'none',
      'browseroutput.text-color': '#000000',
      'outputwindow.background-color': 'none',
      'outputwindow.text-color': '#000000',
      'mainwindow.background-color': 'none',
      'mainvsplit.background-color': 'none',
      // Buttons
      'rulesb.background-color': 'none',
      'rulesb.text-color': '#000000',
      'wikib.background-color': 'none',
      'wikib.text-color': '#000000',
      'forumb.background-color': 'none',
      'forumb.text-color': '#000000',
      'changelog.background-color': '#79ce19',
      'changelog.text-color': '#ffffff',
      'discord.background-color': '#7186f0',
      'discord.text-color': '#ffffff',
      'report-issue.background-color': '#df3e3e',
      'report-issue.text-color': '#ffffff',
      'textb.background-color': 'none',
      'textb.text-color': '#000000',
      'infob.background-color': 'none',
      'infob.text-color': '#000000',
      // Status and verb tabs
      'output.background-color': 'none',
      'output.text-color': '#000000',
      'infowindow.background-color': 'none',
      'infowindow.text-color': '#000000',
      'info.background-color': '#FFFFFF',
      'info.tab-background-color': 'none',
      'info.text-color': '#000000',
      'info.tab-text-color': '#000000',
      'info.prefix-color': '#000000',
      'info.suffix-color': '#000000',
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': 'none',
      'saybutton.text-color': '#000000',
      'mebutton.background-color': 'none',
      'mebutton.text-color': '#000000',
      'asset_cache_browser.background-color': 'none',
      'asset_cache_browser.text-color': '#000000',
      'tooltip.background-color': 'none',
      'tooltip.text-color': '#000000',
    });
  }
  if (name === 'dark') {
    Byond.winset({
      // Main windows
      'rpanewindow.background-color': COLOR_DARK_BG,
      'rpanewindow.text-color': COLOR_DARK_TEXT,
      'rpane.background-color': COLOR_DARK_BG,
      'rpane.text-color': COLOR_DARK_TEXT,
      'browseroutput.background-color': COLOR_DARK_BG,
      'browseroutput.text-color': COLOR_DARK_TEXT,
      'outputwindow.background-color': COLOR_DARK_BG,
      'outputwindow.text-color': COLOR_DARK_TEXT,
      'mainwindow.background-color': COLOR_DARK_BG,
      'mainvsplit.background-color': COLOR_DARK_BG,
      // Buttons
      'rulesb.background-color': '#494949',
      'rulesb.text-color': COLOR_DARK_TEXT,
      'wikib.background-color': '#494949',
      'wikib.text-color': COLOR_DARK_TEXT,
      'forumb.background-color': '#494949',
      'forumb.text-color': COLOR_DARK_TEXT,
      'changelog.background-color': '#2d5004',
      'changelog.text-color': COLOR_DARK_TEXT,
      'discord.background-color': '#212746',
      'discord.text-color': COLOR_DARK_TEXT,
      'report-issue.background-color': '#492020',
      'report-issue.text-color': COLOR_DARK_TEXT,
      'textb.background-color': '#494949',
      'textb.text-color': COLOR_DARK_TEXT,
      'infob.background-color': '#494949',
      'infob.text-color': COLOR_DARK_TEXT,
      // Status and verb tabs
      'output.background-color': COLOR_DARK_BG_DARKER,
      'output.text-color': COLOR_DARK_TEXT,
      'infowindow.background-color': COLOR_DARK_BG_DARKER,
      'infowindow.text-color': COLOR_DARK_TEXT,
      'info.background-color': COLOR_DARK_BG_DARKER,
      'info.tab-background-color': COLOR_DARK_BG,
      'info.text-color': COLOR_DARK_TEXT,
      'info.tab-text-color': COLOR_DARK_TEXT,
      'info.prefix-color': COLOR_DARK_TEXT,
      'info.suffix-color': COLOR_DARK_TEXT,
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': COLOR_DARK_BG,
      'saybutton.text-color': COLOR_DARK_TEXT,
      'mebutton.background-color': COLOR_DARK_BG,
      'mebutton.text-color': COLOR_DARK_TEXT,
      'asset_cache_browser.background-color': COLOR_DARK_BG,
      'asset_cache_browser.text-color': COLOR_DARK_TEXT,
      'tooltip.background-color': COLOR_DARK_BG,
      'tooltip.text-color': COLOR_DARK_TEXT,
    });
  }
};
