function mosaic = tc_grabmosaic(ludl, cal, wellrc, fileout)
    % Need to know the calibum and the desired overlap factor [0,0.5] as
    % inputs in order to design the collection grid, ASSUMING the starting
    % position will be in the center of the sample "well."

    % Artemis, 4x objective, 1x multiplier, ~40% overlap = interval 0.5 mm
    Xlocs = [-3 : 0.5 : 3];
    Ylocs = [-3 : 0.5 : 3]';

    % Artemis, 10x objective, 1x multiplier, 10% overlap = interval 0.63 mm
    Xlocs = linspace(-3.15, 3.15, 11);
    Ylocs = transpose(linspace(-3.15, 3.15, 11));
    
    Xmat = repmat(Xlocs, size(Ylocs,1), 1);
    Ymat = repmat(Ylocs, 1, size(Xlocs,2));
    Xpos = Xmat(:);
    Ypos = Ymat(:);

    % Camera Setup
    CameraName = 'Grasshopper3';
    CameraFormat = '';
    ExposureTime = 8;
    Video = flir_config_video(CameraName, CameraFormat, ExposureTime);
    [cam, src] = flir_camera_open(Video);
    vidRes = vid.VideoResolution;
    imageRes = fliplr(vidRes);
    
    
    % Set up camera preview
    f = figure;%('Visible', 'off');
    pImage = imshow(uint16(zeros(imageRes)));
    axis image
    setappdata(pImage, 'UpdatePreviewWindowFcn', @tc_liveview)
    p = preview(cam, pImage);
    set(p, 'CDataMapping', 'scaled');


    % ----------------
    % Controlling the Hardware and running the experiment
    %
    
    % Move to prescribed well and to its center
    nunc_space_move(ludl, cal, wellrc, [0,0], '96well');
    
    N = numel(Xpos);
    PrescribedXY = [Xpos Ypos];

    % (1) Move stage to beginning position.
    logentry(['Microscope is collecting mosaic...']);


    pause(2);
    logentry('Starting collection...');

    Image = cell(N, 1);
    ArrivedXY = zeros(N,2);


    for k = 1:N
        x = Xpos(k);
        y = Ypos(k);

        figure(f); 
        drawnow;

        logentry([' Moving to position X: ' num2str(x) ', Y: ' num2str(y) '. ']);
        nunc_space_move(ludl, cal, wellrc, [x,y], '96well');
        stout = stage_get_pos_Ludl(ludl);
        ArrivedXY(k,:) = stout.Pos;
        logentry(['Arrived at position X: ' num2str(ArrivedXY(k,1)), ', Y: ' num2str(ArrivedXY(k,2)) '. ']);

        Image{k,1} = p.CData;

    %     imwrite(im{k,1}, outfile);
    %     logentry(['Frame grabbed to ' outfile '.']);

    %     focus_score(k,1) = fmeasure(im{k,1}, 'GDER');
    end

    close(f);

    mosaic = table(PrescribedXY, ArrivedXY, Image);
    save(fileout, 'mosaic','-v7.3', '-nocompression');
    logentry('Done!');

return



    
    