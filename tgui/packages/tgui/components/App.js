import { Component } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button } from '../components';

import { Filesystem } from './progs/Filesystem.js';
import { NTDocs } from './progs/NTDocs.js';
import { NTPict } from './progs/NTPict.js';

export class App extends Component {
  components = {
    Filesystem: Filesystem,
    NTDocs: NTDocs,
    NTPict: NTPict
  };

  render() {
    const { act, data } = useBackend(this.props.context);
    const {
      program,
      folder_name
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
            content={
              <Box className="AppWindow__Button-Content">
                X
              </Box>
            }
            onClick={() => act('close_file')}
          />
        </Box>
        <AppName context={this.props.context} />
      </Box>
    )
  }
}

export default App;