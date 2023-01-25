import { useBackend } from '../../backend';

export const NTPict = (props) => {
  const { act, data } = useBackend(props.context);
  const {
    file_name,
    file_content
  } = data;
  return (
    <div>
      {file_name}
      {file_content}
    </div>
  );
};