import { Component } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Icon } from '../components';

import { Filesystem } from './progs/Filesystem.js';
import { NTDocs } from './progs/NTDocs.js';
import { NTPict } from './progs/NTPict.js';

export class App extends Component {
  components = {
    Filesystem: Filesystem,
    NTDocs: NTDocs,
    NTPict: NTPict,
  };

  render() {
    const { act, data } = useBackend(this.props.context);
    const {
      program,
      folder_name,
    } = data;
    const AppName = this.components[program];
    return (
      <Box className="AppWindow">
        <Box className="AppWindow__Bar">
          <div className="AppWindow__Bar_Name">
            {program}
          </div>
          <Button
            className="AppWindow__Button"
            icon="times"
            onClick={() => act('close_file')}
          />
          <Button
            className="AppWindow__Button"
            icon="window-minimize"
            onClick={() => act('minimize_file')}
          />
        </Box>
        <Box className="AppWindow__Content">
          <AppName context={this.props.context} />
        </Box>
      </Box>
    );
  }
}

export default App;