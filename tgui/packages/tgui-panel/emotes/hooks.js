import { useDispatch, useSelector } from 'common/redux';
import { selectEmotes } from './selectors';

export const useEmotes = context => {
  const state = useSelector(context, selectEmotes);
  const dispatch = useDispatch(context);
  return {
    ...state,
    toggle: () => dispatch({ type: 'emotes/toggle' }),
  };
};