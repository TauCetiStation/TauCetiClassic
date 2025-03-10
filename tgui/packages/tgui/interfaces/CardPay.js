import { useBackend } from '../backend';
import { Box, Button, Icon, Grid } from '../components';
import { Window } from '../layouts';

import { SegmentDisplay } from '../components/SegmentDisplay';

export const CardPay = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    numbers,
    reset_numbers,
    mode,
  } = data;
  const buttons = [];
  for (let row = 0; row < 3; row++) {
    for (let col = 1; col < 4; col++) {
      buttons.push(<Button
        className="cardpay_button cardpay_button--normal"
        content={<Box className="cardpay_button-inside cardpay_button-inside--normal">{row * 3 + col}</Box>}
        onClick={() => act("pressnumber", { number: row * 3 + col })}
      />);
    }
  }

  const getText = () => {
    let result_text = "";
    let numtext = numbers.toString();
    switch (mode) {
      case 'Mode_EnterPin':
        result_text += "PIN:" + (numbers ? numtext: "-");
        for (let excess = 1; excess <= 4 - numtext.length; excess++) {
          result_text += "-";
        }
        break;
      case 'Mode_Account':
        result_text += "N°" + (numbers ? numtext : "-");
        for (let excess = 1; excess <= 6 - numtext.length; excess++) {
          result_text += "-";
        }
        break;
      case 'Mode_Pay':
        result_text += "N°" + (numbers ? numtext : "-");
        for (let excess = 1; excess <= 6 - numtext.length; excess++) {
          result_text += "-";
        }
        break;
      case 'Mode_Idle':
        for (let excess = 1; excess <= 3 - numtext.length; excess++) {
          result_text += "-";
        }
        result_text += (numbers ? numtext : "-") + "$";
        break;
    }
    return result_text;
  };

  return (
    <Window theme=""
      width={220}
      height={340}
      titleClassName="cardpay_window-titlebar">
      <Window.Content className="cardpay_window-contents">
        <Box
          className="cardpay_monitor"
        >
          <SegmentDisplay display_cells_amount={8} display_height={40} display_text={getText()} />
        </Box>
        <Box width="158px" height="208px" position="absolute" left="32px" top="95px">
          {buttons}
          <Button
            className="cardpay_button cardpay_button--red"
            content={<Box className="cardpay_button-inside cardpay_button-inside--red">{"X"}</Box>}
            onClick={() => act("clearnumbers")}
          />
          <Button
            className="cardpay_button cardpay_button--normal"
            content={<Box className="cardpay_button-inside cardpay_button-inside--normal">{0}</Box>}
            onClick={() => act("pressnumber", { number: 0 })}
          />
          <Button
            className="cardpay_button cardpay_button--green"
            content={<Box className="cardpay_button-inside cardpay_button-inside--green">{"O"}</Box>}
            onClick={() => act("approveprice")}
          />
        </Box>
        <Box position="absolute" top="62px" left="25px" textColor="#333344" fontSize={0.85} bold={1}>
          сброс
          <Button
            position="absolute"
            top="15px"
            left="10px"
            className="cardpay_resethole"
            onClick={() => act("toggleenteraccount")}
          />
        </Box>
        <Button
          selected={reset_numbers ? 1 : 0}
          position="absolute"
          top="60px"
          left="140px"
          className="cardpay_switch"
          content={<Box className="cardpay_switch-inside">|||</Box>}
          onClick={() => act("togglereset")}
        />
      </Window.Content>
    </Window>
  );
};
