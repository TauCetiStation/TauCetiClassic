import { useBackend } from '../../backend';
import { Box, Icon, Button } from '../../components';

export const NTDocs = (props) => {
  const { act, data } = useBackend(props.context);
  const {
    file_name,
    file_content,
    all_docs,
  } = data;
  return (
    <div>
      <Box className="NTDocs__UpperMenu">
        <Button className="NTDocs__Button" icon="plus" content={<Box className="NTDocs__Button-Content">New</Box>} onClick={() => act('program', { program_action: 'new_file' })} />
        <Button className="NTDocs__Button" icon="pen" content={<Box className="NTDocs__Button-Content">Rename</Box>} onClick={() => act()} />
        <Button className="NTDocs__Button" icon="print" content={<Box className="NTDocs__Button-Content">Print</Box>} onClick={() => act('print')} />
        <Box className="NTDocs__Buttons_Placeholder" />
        <Button className="NTDocs__Button" icon="paper-plane" content={<Box className="NTDocs__Button-Content">Send</Box>} onClick={() => act('send_file')} />
        <Box className="NTDocs__PaperHeader">
          { !!file_name && ({ file_name }.ntd) }
        </Box>
      </Box>
      <Box className="NTDocs__LeftMenu">
        {all_docs.map((doc, index) => (
          <Button key={index}
            className="NTDocs__FileList"
            content={
              <>
                <Icon name={"file-word"} className="Computer__File-Icon" />
                <Box className="NTDocs__FileList-Name">
                  {doc.name}
                </Box>
              </>
            }
            onClick={() => act('open_file', { file_id: doc.file_id })}
          />
        ))}
      </Box>
      <Box className="NTDocs__PaperView">
        {!!file_content && (
          <Box className="NTDocs__Paper">
            {file_content.info}
          </Box>
        )}
      </Box>
    </div>
  );
};