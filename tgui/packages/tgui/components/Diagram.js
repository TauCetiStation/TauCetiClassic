import { Box, Tooltip } from '../components';

export const Diagram = (props) => {
  const { display_array = [], format, ...rest } = props;
  const sum = display_array.reduce((acc, item) => {
    return acc + item[1];
  }, 0);
  const amount = display_array.reduce((acc, item) => {
    return acc + 1;
  }, 0);
  const processed_array = display_array
    .sort((a, b) => b[1] - a[1])
    .reduce((newarr, item) => {
      newarr.push({
        name: item[0],
        value: format ? format(item[1]) : item[1],
        percent: Math.round((item[1] / (sum ? sum : 1)) * 100),
      });
      return newarr;
    }, []);

  return (
    <Box className="Diagram_Body" {...rest}>
      {processed_array.map((item, index) => (
        <Box
          key={index}
          width={`${item.percent}%`}
          height="100%"
          backgroundColor={`hsl(${Math.round((360 / (amount ? amount : 1)) * index)}, 70%, 50%)`}>
          <Tooltip position="top" content={`${item.name}: ${item.value}`}>
            <div style={{ width: '100%', height: '100%' }} />
          </Tooltip>
        </Box>
      ))}
    </Box>
  );
};
