import { Box, Flex, Section } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { emojis } from './constants';

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

export const EmotesPanel = (props) => {
  return (
    <Section className="emojiPicker" title="Emoji Picker" scrollable>
      <Box as="p">Emoji will be copied to the clipboard</Box>
      <Flex className="emojiList" wrap="wrap" align="center" height="125px">
        {emojis.map((v) => {
          return (
            <Flex.Item
              key={v}
              as="i"
              className={classes(['em', `em-${v}`])}
              onClick={() => CopyToClipboard(`:${v}:`)}
            />
          );
        })}
      </Flex>
    </Section>
  );
};
