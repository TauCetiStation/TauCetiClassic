import { useBackend } from '../backend';
import { Box, Button, Icon, Grid } from '../components';
import { Window } from '../layouts';

import { SegmentDisplay } from '../components/SegmentDisplay';

export const Telephone = (props, context) => {
  const { act, data } = useBackend(context);
  const { numbers, phone_frequency, recording, call_timer, istalking } = data;
  const buttons = [];
  for (let row = 0; row < 3; row++) {
    for (let col = 1; col < 4; col++) {
      buttons.push(
        <Button
          className="cardpay_button cardpay_button--black"
          content={
            <Box className="cardpay_button-inside cardpay_button-inside--black">
              {row * 3 + col}
            </Box>
          }
          onClick={() => act('pressnumber', { number: row * 3 + col })}
        />
      );
    }
  }

  const getText = () => {
    let result_text = '';
    if (call_timer) {
      result_text = 'Вызов';
      if (recording) {
        let timer_text = Math.round(call_timer / 10).toString();
        result_text = timer_text + ' сек';
      }
    } else if (istalking) {
      result_text = 'Разговор';
    } else {
      let numtext = numbers.toString();
      result_text = 'N°' + (numbers ? numtext : '0');
    }
    return result_text;
  };

  return (
    <Window
      theme=""
      width={340}
      height={340}
      titleClassName="cardpay_window-titlebar">
      <Window.Content className="cardpay_window-contents--black">
        <Box className="telephone_monitor">
          <SegmentDisplay
            display_cells_amount={8}
            display_height={40}
            display_text={getText()}
          />
        </Box>
        <Box
          className="telephone_label"
          position="absolute"
          left="210px"
          top="95px">
          <ul>
            <li>{phone_frequency} - Мой</li>
            <li>1X - Инж.</li>
            <li>2Х - Мед.</li>
            <li>3Х - СБ</li>
            <li>4Х - НИОКР</li>
            <li>5Х - Ком.</li>
            <li>6Х - Снаб.</li>
          </ul>
        </Box>

        <Box
          width="158px"
          height="208px"
          position="absolute"
          left="32px"
          top="95px">
          {buttons}
          <Button
            className="cardpay_button cardpay_button--red"
            content={
              <Box className="cardpay_button-inside cardpay_button-inside--red">
                {'X'}
              </Box>
            }
            onClick={() => act('clearnumbers')}
          />
          <Button
            className="cardpay_button cardpay_button--black"
            content={
              <Box className="cardpay_button-inside cardpay_button-inside--black">
                {0}
              </Box>
            }
            onClick={() => act('pressnumber', { number: 0 })}
          />
          <Button
            className="cardpay_button cardpay_button--green"
            content={
              <Box className="cardpay_button-inside cardpay_button-inside--green">
                {'O'}
              </Box>
            }
            onClick={() => act('approveprice')}
          />
        </Box>
        <Box
          position="absolute"
          top="15px"
          left="240px"
          textColor="#333344"
          fontSize={0.85}
          bold={1}>
          рингтон
          <Button
            position="absolute"
            top="15px"
            left="15px"
            className="cardpay_resethole"
            onClick={() => act('change_ringtone')}
          />
        </Box>
        <Button
          position="absolute"
          left="240px"
          top="250px"
          className="cardpay_button cardpay_button--black"
          content={
            <Box className="cardpay_button-inside cardpay_button-inside--black">
              {'>'}
            </Box>
          }
          onClick={() => act('listen_records')}
        />
      </Window.Content>
    </Window>
  );
};
