import { Fragment } from 'inferno';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Box, Icon, ProgressBar } from '../components';
import { Window } from "../layouts";

export const VendomatConsole = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    vendomats,
  } = data;
  return (
    <Window
      width={450}
      height={390}>
      <Window.Content fitted={1}>
        {!!vendomats && (
          vendomats.map((vendslist, index) => (
            <Box className="VendomatConsole__Vendlist" key={index}>
              {vendslist.name}
              <br />
              {vendslist.listofvends.map((vendomat, id) => (
                <Box className="VendomatsConsole__VendomatBox" key={id}>
                  <Box className="VendomatsConsole__VendomatBox-TextBox">
                    {vendomat.area}
                  </Box>
                  <Box className="VendomatsConsole__VendomatBox-SubBox">
                    Load:
                    <br />
                    <ProgressBar value={vendomat.load/vendomat.max_load} className="VendomatsConsole__VendomatBox-ProgressBar" />
                  </Box>
                </Box>
              ))}
            </Box>
          ))
        )}
      </Window.Content>
    </Window>
  );
};
