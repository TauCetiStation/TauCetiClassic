const initialState = {
  visible: false,
};

export const emotesReducer = (state = initialState, action) => {
  const { type } = action;
  if (type === 'emotes/toggle') {
    return {
      ...state,
      visible: !state.visible,
    };
  }
  return state;
};
  