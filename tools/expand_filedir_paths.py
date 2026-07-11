// tgui/packages/tgui/drag.js

export const DRAG_ACTIONS = {
    GROSSLY: 'grossly',
    USUALLY: 'usually',
    SOFTLY: 'softly'
};

export const EROTIC_ACTIONS = {
    KISS: 'kiss',
    PET: 'pet',
    CARESS: 'caress'
};

const sounds = {
    [DRAG_ACTIONS.GROSSLY]: 'gross_sound.mp3',
    [DRAG_ACTIONS.USUALLY]: 'usual_sound.mp3',
    [DRAG_ACTIONS.SOFTLY]: 'soft_sound.mp3',
    [EROTIC_ACTIONS.KISS]: 'kiss_sound.mp3',
    [EROTIC_ACTIONS.PET]: 'pet_sound.mp3',
    [EROTIC_ACTIONS.CARESS]: 'caress_sound.mp3'
};

export const performAction = (action, card) => {
    console.log(`Performing ${action} action on card...`);
    const soundFile = sounds[action];
    if (soundFile) {
        // Play sound
        console.log(`Playing sound: ${soundFile}`);
    }
};