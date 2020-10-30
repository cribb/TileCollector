function [Mosaic, TiledImage] = tc_manualmosaic(ludl, calibum, XLim, YLim, OverlapFactor, FileOut)
% TC_MANUALMOSAIC collects a set of mosaic images and outputs them.
%
% [Mosaic, TiledImage] = tc_manualmosaic(ludl, calibum, XLim, YLim, OverlapFactor, FileOut)
% 
% Inputs
%    - ludl: Handle to Ludl (run "ludl = stage_open_Ludl('COM3', 'BioPrecision2-LE2_Ludl5000')"
%    - calibum: length scale in [um] for 1 pixel, e.g. 0.150 [um/pixel]
%    - XLim: 2-element vector denoting X-Limits in [mm], e.g. [-2 2] moves
%      two mm to the left and collects through 2 mm to the right.
%    - YLim: 2-element vector denoting Y-Limits in [mm], e.g. [-2 2] moves
%      two mm up and collects through 2 mm down.
%    - OverlapFactor: Defines the effective frame size. An OverlapFactor of
%      "0.1" means that 10% of each image in X and Y will overlap with the
%      next-most image to the right and below.
%    - FileOut: filename for the outputted MosaicTable
%
% Outputs
%    - MosaicTable: same as the saved MosaicTable in the output file.
%    - TiledImage: rudimentary assembled tiled mosaic image-matrix with no
%      attempt to stitch the images together via cross-correlation.


% Need to know the calibum and the desired overlap factor [0,0.5] as
% inputs in order to design the collection grid, ASSUMING the starting
% position will be in the center of the sample "well."

    % The stage is already setup as an argument, so start by storing ints
    % "original" position.
    ludl = stage_get_pos_Ludl(ludl);
    OrigPosition = ludl.Pos;


    % Camera Setup
    CameraName = 'Flea3';
    CameraFormat = 'F7_Mono8_1280x1024_Mode0';
    ExposureTime = 10;
    Video = flir_config_video(CameraName, CameraFormat, ExposureTime);
    [cam, src] = flir_camera_open(Video);    
    
    % Video resolution in pixels in typical order (# pixels along X then Y)
    vidRes = cam.VideoResolution;
    
    % Image resolution in size of an image's matrix (Nrows X Mcols)
    imageSize = fliplr(vidRes);
    
    % XLim and YLim come in [mm] units. Make sure they are ordered by size.
    XLim = sort(XLim(:));
    YLim = sort(YLim(:));
    
    % Size of the mosaic for X and Y in [mm]
    XYdiff = abs(diff( [XLim, YLim] ));
    
    % Image size in [mm]
    imageSize_mm = vidRes .* calibum .* 1e-3;
    
    % The effective frame size will diminish as the overlap factor
    % increases and reduces the offset/stepsize as the mosaic is collected.
    EffVidSize_mm = imageSize_mm * (1 - OverlapFactor);
    ExactNxy = XYdiff ./ EffVidSize_mm;
    
    % Setting everything up as a matrix of indices because it makes the
    % math easier to follow through to the end.
    Nxy = ceil(ExactNxy);
    N(1,:) = 1:Nxy(1);
    M(:,1) = 1:Nxy(2);
    Nmat = repmat(N, Nxy(2), 1);
    Mmat = repmat(M, 1, Nxy(1));
    logentry(['Collecting ' num2str(Nxy(2)) ' rows x ' num2str(Nxy(1)) ' columns.']);
    
    % Calculating our overage amount
    OverageXY = Nxy - ExactNxy;    
    
    Xmat = (Nmat - 1) .* EffVidSize_mm(1) + XLim(1) - OverageXY(1)/2;
    Ymat = (Mmat - 1) .* EffVidSize_mm(2) + YLim(1) - OverageXY(2)/2;
    Ymat = flipud(Ymat);
    
    % Tranpose the matrices because we want to transit across X first, i.e.
    % a typicsl raster scan pattern, and then linearize the matrices to get 
    % the list of coordinates to visit in order.
    Xcoords_mm = transpose(Xmat);
    Ycoords_mm = transpose(Ymat);
    Xcoords_mm = Xcoords_mm(:);
    Ycoords_mm = Ycoords_mm(:);
    
    % Get everything switched over to Ludl stage ticks
    Xcoords_ticks = mm2tick(ludl, Xcoords_mm);
    Ycoords_ticks = mm2tick(ludl, Ycoords_mm);
    
    % Xpos and Ypos are the destination coordinates for the ludl stage in ticks
    Xpos = OrigPosition(1) + int64(Xcoords_ticks);
    Ypos = OrigPosition(2) + int64(Ycoords_ticks);
    
    
    % ----------------
    % Controlling the Hardware and running the experiment
    %
    
    % Set up camera preview
    f = figure;%('Visible', 'off');
    pImage = imshow(uint16(zeros(imageSize)));
    axis image
    setappdata(pImage, 'UpdatePreviewWindowFcn', @tc_liveview)
    p = preview(cam, pImage);
    set(p, 'CDataMapping', 'scaled');  
    
    Nframes = numel(Xpos);
    PrescribedXY = [Xpos Ypos];

    % (1) Move stage to beginning position.
    logentry(['Microscope is collecting mosaic...']);

    pause(2);
    logentry('Starting collection...');

    Image = cell(Nframes, 1);
    ArrivedXY = zeros(Nframes,2);


    for k = 1:Nframes
        x = Xpos(k);
        y = Ypos(k);

        figure(f); 
        drawnow;

%         logentry([' Moving to position X: ' num2str(x) ', Y: ' num2str(y) '. ']);
        stage_move_Ludl(ludl, [x,y]);
        stout = stage_get_pos_Ludl(ludl);
        ArrivedXY(k,:) = stout.Pos;
%         logentry(['Arrived at position X: ' num2str(ArrivedXY(k,1)), ', Y: ' num2str(ArrivedXY(k,2)) '. ']);

        Image{k,1} = p.CData;

    %     imwrite(im{k,1}, outfile);
    %     logentry(['Frame grabbed to ' outfile '.']);

    %     focus_score(k,1) = fmeasure(im{k,1}, 'GDER');
    end

    close(f);
    ludl = stage_move_Ludl(ludl, OrigPosition);
    
    Mosaic.MosaicTable = table(PrescribedXY, ArrivedXY, Image);
    Mosaic.MosaicSizeRC = fliplr(Nxy);
    Mosaic.LengthScale = calibum;
    Mosaic.OverlapFactor = OverlapFactor;
    Mosaic.XLim = XLim;
    Mosaic.YLim = YLim;
    
    save(FileOut, '-STRUCT', 'Mosaic');
    
    % Plot the assembled mosaic into a new figure
    tc_show_mosaic(m);
    
    logentry('Done!');

return



    
    