import { classes } from 'common/react';
import { useDispatch, useSelector } from 'common/redux';
import { Flex, Section } from 'tgui/components';
import { selectEmotes } from './selectors';
import { emojis } from './constants';
import { Box } from '../../tgui/components';

const CopyToClipboard = (text) => {
  if (!navigator.clipboard) {
    const temp = document.createElement('input');
    temp.innerText = text;
    document.body.appendChild(temp);
    temp.select();
    document.execCommand('copy');
    temp.remove();
  } else {
    navigator.clipboard.writeText(text);
  }
};

export const EmotesPanel = (props, context) => {
  return (
    <Section className="emojiPicker" title="Emoji Picker" scrollable>
      <Box as="p">Emoji will be copied to the clipboard</Box> 
      <Flex className="emojiList" wrap="wrap" align="center" height="125px">
        {emojis.map((v) => {
          return (
            <Flex.Item key={v}
              as="i"
              className={classes([
                'em',
                'em-'+v,
              ])}
              onClick={() => CopyToClipboard(':'+v+':')}
            />
          ); })}
      </Flex>
    </Section>
  );
};
