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
        className="CardPay_Button"
        content={<Box className="CardPay_Button_inside">{row * 3 + col}</Box>}
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
      height={315}>
      <Window.Content className="CardPay_Window">
        <Box
          className="CardPay_Monitor"
        >
          <SegmentDisplay display_cells_amount={8} display_height={40} display_text={getText()} />
        </Box>
        <Box width="158px" height="208px" position="absolute" left="58px" top="65px">
          {buttons}
          <Button
            className="CardPay_Button_Red"
            content={<Box className="CardPay_Button_Red_inside">{"X"}</Box>}
            onClick={() => act("clearnumbers")}
          />
          <Button
            className="CardPay_Button"
            content={<Box className="CardPay_Button_inside">{0}</Box>}
            onClick={() => act("pressnumber", { number: 0 })}
          />
          <Button
            className="CardPay_Button_Green"
            content={<Box className="CardPay_Button_Green_inside">{"O"}</Box>}
            onClick={() => act("approveprice")}
          />
        </Box>
        <Button
          selected={reset_numbers ? 1 : 0}
          position="absolute"
          top="65px"
          left="5px"
          height="74px"
          className="CardPay_Button"
          content={<Box className="CardPay_Button_inside" height="66px"><Icon name="retweet" position="relative" left="5px" top="10px" /></Box>}
          onClick={() => act("togglereset")}
        />
        <Button
          selected={mode === 'Mode_Account' ? 1 : 0}
          position="absolute"
          top="145px"
          left="5px"
          height="74px"
          className="CardPay_Button"
          content={<Box className="CardPay_Button_inside" height="66px"><Icon name="id-badge" position="relative" left="5px" top="10px" /></Box>}
          onClick={() => act("toggleenteraccount")}
        />
      </Window.Content>
    </Window>
  );
};
