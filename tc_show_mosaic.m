function tc_show_mosaic(Mosaic)

        
    imR = reshape(Mosaic.ImageTiles, Mosaic.SizeRC);
    TiledImage = imtile(imR, 'GridSize', Mosaic.SizeRC);

    %     imXax = linspace(min(Xmat(:)),max(Xmat(:))+imageSize_mm(1),size(T,2));    
    %     imYax = linspace(min(Ymat(:)),max(Ymat(:))+imageSize_mm(2),size(T,1));

    imXax = [0:size(TiledImage,2)-1] .* Mosaic.LengthScale/1e3;
    imYax = [0:size(TiledImage,1)-1] .* Mosaic.LengthScale/1e3;
    
    figure; 
    imagesc(imXax, imYax, TiledImage);  %#ok<NBRAK>
    axis image;
    xlabel('[mm]'); 
    ylabel('[mm]'); 
    colormap(gray);

    
return