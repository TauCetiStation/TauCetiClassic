import { Fragment } from 'inferno';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Box, Icon, ProgressBar, Collapsible } from '../components';
import { Window } from "../layouts";

export const VendingConsole = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    vending,
  } = data;
  return (
    <Window
      width={450}
      height={390}>
      <Window.Content fitted={1}>
        {!!vending && (
          vending.map((vendslist, index) => (
            <Collapsible className="VendingConsole__Vendlist" key={index} title={vendslist.name}>
              {vendslist.listofvends.map((vendomat, id) => (
                <Box className="VendingConsole__VendomatBox" key={id}>
                  <Box className="VendingConsole__VendomatBox-TextBox">
                    {vendomat.area}
                  </Box>
                  <Box className="VendingConsole__VendomatBox-SubBox">
                    Load:
                    <br />
                    <ProgressBar value={vendomat.load/vendomat.max_load} className="VendingConsole__VendomatBox-ProgressBar" />
                  </Box>
                </Box>
              ))}
            </Collapsible>
          ))
        )}
      </Window.Content>
    </Window>
  );
};
