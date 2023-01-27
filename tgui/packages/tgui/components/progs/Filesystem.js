import { useBackend } from '../../backend';
import { Box, Icon, Button } from '../../components';

export const Filesystem = (props) => {
  const { act, data } = useBackend(props.context);
  const {
    folder_files,
    folder_name,
  } = data;
  return (
    <div>
      <Box className="Filesystem__Header">
        <Box className="Filesystem__Header-Name">
          Имя
        </Box>
        <Box className="Filesystem__Header-Name">
          Тип
        </Box>
      </Box>
      {!!folder_files && (
        folder_files.map((file, index) => (
          <Button key={index}
            className="Filesystem__File"
            content={
              <>
                <Icon name={file.file_icon} className="Filesystem__File-Icon" />
                <Box className="Filesystem__File-Name">
                  {file.name}
                </Box>
                <Box className="Filesystem__File-Type">
                  {file.filetype}
                </Box>
              </>
            }
            onClick={() => act('open_file', { file_id: file.file_id })}
          />
        ))
      )}
    </div>
  );
};