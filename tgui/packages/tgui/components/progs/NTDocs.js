import { useBackend } from '../../backend';
import { Box, Icon, Button } from '../../components';

export const NTDocs = (props) => {
  const { act, data } = useBackend(props.context);
  const {
    file_name,
    file_content
  } = data;
  return (
    <div>
      <Box className="NTDocs__UpperMenu">
      </Box>
      <Box className="NTDocs__LeftMenu"/>
      <Box className="NTDocs__PaperView">
      <Box className="NTDocs__Paper">
        <Box className="NTDocs__PaperHeader">
          {file_name}.ntd
        </Box>
        {!!file_content && (file_content.info)}
      </Box>
      </Box>
      
    </div>
  );
};