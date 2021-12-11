import { classes } from 'common/react';
import { useDispatch, useSelector } from 'common/redux';
import { Flex } from 'tgui/components';
import { selectEmotes } from './selectors';
import { emojis } from './constants';
import { Box } from '../../tgui/components';

export const EmotesPanel = (props, context) => {
  const emotes = useSelector(context, selectEmotes);
  const dispatch = useDispatch(context);
  return (
    <Flex align="center">
      {emojis.map((v) => {
        return (
          <Flex.Item key={v}>
            <Box
              className={classes([
                'emojis32x32',
                'peka',
              ])}
              style={{
                'transform': 'scale(2) translate(0px, 10%)',
                'vertical-align': 'middle',
              }} />
          </Flex.Item>
        ); })}
    </Flex>
  );
};
