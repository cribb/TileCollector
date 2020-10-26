function tc_liveview(obj, event, hImage)
% This callback function updates the displayed frame and the histogram.

% Display the current image frame.
set(hImage, 'CData', event.Data);

% disp('Inside callback.');

D = double(event.Data(:));
avgD = round(mean(D));
stdD = round(std(D));
maxD = num2str(max(D));
minD = num2str(min(D));


avgD = num2str(avgD, '%u');
stdD = num2str(stdD, '%u');
maxD = num2str(maxD, '%u');
minD = num2str(minD, '%u');


title([avgD, ' \pm ', stdD, ' [', minD ', ', maxD, ']']);

a = ancestor(hImage, 'axes');

cmin = min(double(hImage.CData(:)));
cmax = max(double(hImage.CData(:)));
set(a, 'CLim', [uint16(cmin) uint16(cmax)]);

return