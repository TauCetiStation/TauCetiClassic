/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { loadChat } from './actions';
import { MAX_PERSISTED_MESSAGES, MAX_VISIBLE_MESSAGES } from './constants';
import { createMainPage } from './model';
import { chatReducer, initialState } from './reducer';
import { chatRenderer } from './renderer';

describe('chatReducer', () => {
  test('ignores corrupted or incomplete stored chat-state payloads on loadChat', () => {
    expect(chatReducer(initialState, loadChat(null))).toBe(initialState);
    expect(
      chatReducer(
        initialState,
        loadChat({ version: 5, pages: [], pageById: {} })
      )
    ).toBe(initialState);
    expect(
      chatReducer(
        initialState,
        loadChat({
          version: 5,
          currentPageId: 'missing-page',
          pages: ['missing-page'],
          pageById: {},
        })
      )
    ).toBe(initialState);
  });

  test('loads valid stored chat-state and resets unreadCount', () => {
    const mainPage = createMainPage();
    mainPage.unreadCount = 12;
    const loadedState = chatReducer(
      initialState,
      loadChat({
        version: 5,
        currentPageId: mainPage.id,
        scrollTracking: false,
        pages: [mainPage.id],
        pageById: {
          [mainPage.id]: mainPage,
        },
      })
    );
    expect(loadedState.currentPageId).toBe(mainPage.id);
    expect(loadedState.scrollTracking).toBe(false);
    expect(loadedState.pageById[mainPage.id].unreadCount).toBe(0);
  });
});

describe('chatRenderer', () => {
  test('resolves scrollable Layout__content parent and prunes excess messages when scrollTracking is active', () => {
    document.body.innerHTML = '';
    const scrollParent = document.createElement('div');
    scrollParent.className = 'Layout__content Layout__content--scrollable';
    Object.defineProperty(scrollParent, 'scrollHeight', {
      value: 1000,
      configurable: true,
    });
    Object.defineProperty(scrollParent, 'offsetHeight', {
      value: 400,
      configurable: true,
    });
    scrollParent.scrollTop = 600;

    const chatRoot = document.createElement('div');
    chatRoot.className = 'Chat';
    scrollParent.appendChild(chatRoot);
    document.body.appendChild(scrollParent);

    const page = createMainPage();
    chatRenderer.messages = [];
    chatRenderer.visibleMessages = [];
    chatRenderer.queue = [];
    chatRenderer.rootNode = null;
    chatRenderer.loaded = false;

    chatRenderer.changePage(page);
    chatRenderer.onStateLoaded();
    chatRenderer.mount(chatRoot);

    expect(chatRenderer.scrollNode).toBe(scrollParent);

    chatRenderer.handleScroll();
    expect(chatRenderer.scrollTracking).toBe(true);

    const totalMessages = MAX_VISIBLE_MESSAGES + 25;
    const batch = [];
    for (let i = 0; i < totalMessages; i++) {
      batch.push({
        type: 'localchat',
        text: `message-${i}`,
      });
    }
    chatRenderer.processBatch(batch, { notifyListeners: false });
    expect(chatRenderer.visibleMessages.length).toBe(totalMessages);

    chatRenderer.pruneMessages();
    expect(chatRenderer.visibleMessages.length).toBe(MAX_VISIBLE_MESSAGES);
    expect(chatRenderer.messages.length).toBe(MAX_PERSISTED_MESSAGES);
    expect(chatRoot.childNodes.length).toBe(MAX_VISIBLE_MESSAGES);
  });
});
