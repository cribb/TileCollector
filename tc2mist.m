function tc2mist(tc_datafile, outfileprefix)
% TC2MIST converts saved TileCollector dataset to MIST-friendly imagefiles
%
% tc2mist(tc_datafile, outfileprefix)
%
% Inputs:
%    'tc_datafile' is the matlab structure/file saved by TileCollector
%    outfileprefix is a string containing the prefix for the output files
%

    s = load(tc_datafile);
    images = s.ImageTiles;
    [R,C] = meshgrid(1:s.SizeRC(1),1:s.SizeRC(2));
    for k = 1:numel(images)
        im = images{k}; 
        imwrite(im, [outfileprefix, ...
                     '_R', num2str(R(k),'%03i'), ...
                     '_C', num2str(C(k),'%03i'), '.tif']);
    end

    outs = 0;

return
