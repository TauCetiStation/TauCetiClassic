// tgui/packages/tgui/store.js

import { createStore } from 'redux';

const initialState = {
    elvenState: 'peaceful',
    chestsToRob: []
};

function tguiReducer(state = initialState, action) {
    switch (action.type) {
        case 'ELF_ROB_CHEST':
            return {
                ...state,
                chestsToRob: state.chestsToRob.filter(chest => chest !== action.payload)
            };
        default:
            return state;
    }
}

const store = createStore(tguiReducer);

export { store };

// Add this function to tgui/packages/tgui/drag.js
function canRobChest(x, y) {
    if (store.getState().elvenState === 'war') {
        // Logic to check if the player is near a chest and can rob it
        return true;
    }
    return false;
}

// Add this function to tgui/packages/tgui/focus.js
function handleChestRobbery(x, y) {
    if (canRobChest(x, y)) {
        store.dispatch({ type: 'ELF_ROB_CHEST', payload: { x, y } });
    }
}