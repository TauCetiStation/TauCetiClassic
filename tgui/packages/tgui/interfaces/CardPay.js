import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section } from '../components';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export const CardPay = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    numbers,
    reset_numbers,
  } = data;
  const buttons = [];
  for (let row = 0; row < 3; row++) {
    for (let col = 1; col < 4; col++) {
      buttons.push(<Button
        mr={0.5}
        ml={0.5}
        mb={0.5}
        mt={0.5}
        pl={2.4}
        lineHeight={1.5}
        height={4}
        width={4}
        fontSize={2.57}
        content={row * 3 + col}
        onClick={() => act("pressnumber", { number: row * 3 + col })}
      />);
    }
    buttons.push(<br />);
  }
  return (
    <Window
      width={174}
      height={332}>
      <Window.Content>
        <Box
          fluid
          backgroundColor="#191919"
          textColor="#66AADD"
          textAlign="center"
          fontSize={2}
          mb={0.5}
        >
          {numbers}
        </Box>
        {buttons}
        <Button
          mr={0.5}
          ml={0.5}
          mb={0.5}
          mt={0.5}
          height={4}
          width={4}
          lineHeight={1.55}
          pl={2}
          fontSize={2.5}
          content={"X"}
          color={"red"}
          textColor={"darkred"}
          bold={1}
          onClick={() => act("clearnumbers")}
        />
        <Button
          mr={0.5}
          ml={0.5}
          mb={0.5}
          mt={0.5}
          lineHeight={1.55}
          pl={2.4}
          height={4}
          width={4}
          fontSize={2.5}
          content={0}
          onClick={() => act("pressnumber", { number: 0 })}
        />
        <Button
          mr={0.5}
          ml={0.5}
          mb={0.5}
          mt={0.5}
          lineHeight={1.55}
          pl={2}
          height={4}
          width={4}
          fontSize={2.5}
          content={"O"}
          color={"green"}
          textColor={"darkgreen"}
          bold={1}
          onClick={() => act("approveprice")}
        />
        <Button
          selected={reset_numbers ? 1 : 0}
          fluid
          textAlign="center"
          mr={0.5}
          ml={0.5}
          mb={0.5}
          mt={0.5}
          fontSize={1.75}
          content={"Сбрасывать?"}
          onClick={() => act("togglereset")}
        />
      </Window.Content>
    </Window>
  );
};

