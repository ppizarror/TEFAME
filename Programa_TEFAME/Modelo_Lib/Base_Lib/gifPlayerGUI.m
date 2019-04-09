function gifPlayerGUI(fname, delayTime)
if ~exist('delayTime', 'var')
    delayTime = 0;
end
%# read all GIF frames
info = imfinfo(fname, 'gif');
delay = max((info(1).DelayTime)/100, delayTime);
[img, map] = imread(fname, 'gif', 'frames', 'all');
[imgH, imgW, ~, numFrames] = size(img);

%# prepare GUI, and show first frame
hFig = figure('Menubar', 'none', 'Resize', 'off', ...
    'Units', 'pixels', 'Position', [300, 300, imgW, imgH]);
movegui(hFig, 'center');
hAx = axes('Parent', hFig, ...
    'Units', 'pixels', 'Position', [1, 1, imgW, imgH]);
hImg = imshow(img(:, :, :, 1), map, 'Parent', hAx);
pause(delay);

%# loop over frames continuously
counter = 1;
while ishandle(hImg)
    %# increment counter circularly
    counter = rem(counter, numFrames) + 1;
    
    %# update frame
    set(hImg, 'CData', img(:, :, :, counter));
    
    %# update colormap
    n = max(max(img(:, :, :, counter)));
    colormap(info(counter).ColorTable(1:n, :));
    
    %# pause for the specified delay
    pause(delay);
end
end