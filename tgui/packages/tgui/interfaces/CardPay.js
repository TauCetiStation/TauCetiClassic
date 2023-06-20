import { useBackend } from '../backend';
import { Box, Button, Icon, Grid } from '../components';
import { Window } from '../layouts';

export const CardPay = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    numbers,
    reset_numbers,
    enter_account,
    pay_amount,
  } = data;
  const buttons = [];
  for (let row = 0; row < 3; row++) {
    for (let col = 1; col < 4; col++) {
      buttons.push(<Button
        pl={2.4}
        m={0.375}
        lineHeight={1.5}
        height={4}
        width={4}
        fontSize={2.57}
        content={row * 3 + col}
        onClick={() => act("pressnumber", { number: row * 3 + col })}
      />);
    }
  }
  return (
    <Window
      width={170}
      height={330}>
      <Window.Content>
        <Box
          fluid
          backgroundColor="#191919"
          textColor="#66AADD"
          textAlign="center"
          fontSize={2}
          m={0.375}
          mb={0.5}
        >
          {(enter_account || pay_amount > 0) ? "#"+(numbers ? numbers : "------") : (numbers ? numbers : "---")+"$"}
        </Box>
        {buttons}
        <Button
          height={4}
          width={4}
          lineHeight={1.55}
          pl={2}
          m={0.375}
          fontSize={2.5}
          content={"X"}
          color={"red"}
          textColor={"darkred"}
          bold={1}
          onClick={() => act("clearnumbers")}
        />
        <Button
          lineHeight={1.55}
          pl={2.4}
          m={0.375}
          height={4}
          width={4}
          fontSize={2.5}
          content={0}
          onClick={() => act("pressnumber", { number: 0 })}
        />
        <Button
          lineHeight={1.55}
          pl={2}
          m={0.375}
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
          textAlign="center"
          pl={4}
          m={0.3}
          width={6.25}
          fontSize={2}
          color={"grey"}
          content={<Icon name="retweet" />}
          onClick={() => act("togglereset")}
        />
        <Button
          selected={enter_account ? 1 : 0}
          textAlign="center"
          pl={4}
          m={0.3}
          width={6.25}
          fontSize={2}
          color={"grey"}
          content={<Icon name="id-badge" />}
          onClick={() => act("toggleenteraccount")}
        />
      </Window.Content>
    </Window>
  );
};

