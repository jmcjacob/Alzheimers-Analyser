function [ outSets ] = buildData( inpu )
    
    image = imread(inpu);
    red = image(:,:,1);
    green = image(:,:,2);
    blue = image(:,:,3);
    [n,m] = size(red);
    bw = false(n,m);

    for i = 1:n
        for j = 1:m
            if blue(i,j) >= 10 && blue(i,j) <= 80 && green(i,j) >= 10 && green(i,j) <= 80 && red(i,j) >= 40 && red(i,j) <= 110
                bw(i,j) = 1;
                bw(i,j) = 1;
                bw(i,j) = 1;
            end
        end
    end

    bw = imerode(bw,strel('disk', 1));
    element = strel('disk', 3);
    bw = imdilate(bw,element);
    bw = imerode(bw,element);
    
    labels = bwlabel(bw,8);
    boxs = regionprops(labels, 'BoundingBox');
    
    for i = 1:n
        
        bb_i=ceil(boxs(i).BoundingBox);
        idx_x=[bb_i(1)-2 bb_i(1)+bb_i(3)+2];
        idx_y=[bb_i(2)-2 bb_i(2)+bb_i(4)+2];
        if idx_x(1)<1, idx_x(1)=1; end
        if idx_y(1)<1, idx_y(1)=1; end
        if idx_x(2)>m, idx_x(2)=m; end
        if idx_y(2)>n, idx_y(2)=n; end
        
        R = image(idx_y(1):idx_y(2),idx_x(1):idx_x(2),1);
        G = image(idx_y(1):idx_y(2),idx_x(1):idx_x(2),2);
        B = image(idx_y(1):idx_y(2),idx_x(1):idx_x(2),3);
        feature = cat(3, R, G, B);
        
        imshow(feature);
        answer = input('input', 's');
        fileName = [inpu(1:end-4),'_' , num2str(i),'.png'];
        if (answer == '1')
            imwrite(feature, ['features/tangles/',fileName]);
        elseif (answer == '2')
            imwrite(feature, ['features/plaques',fileName]);
        else 
            imwrite(feature, ['features/miss',fileName]);
        end
    end
    
    outSets = [ imageSet(fullfile('features', 'tangles')), ...
                imageSet(fullfile('features', 'plaques')), ...
                imageSet(fullfile('features', 'miss')) ];

    minSetCount = min([outSets.Count]);        
    if (minSetCount > 0)
        outSets = partition(outSets, minSetCount, 'randomize');
    end
    
end

