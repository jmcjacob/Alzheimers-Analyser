function [ outSets ] = buildData( inputImage )
    
    image = imread(inputImage);
    red = image(:,:,1);
    green = image(:,:,2);
    blue = image(:,:,3);
    [n,m] = size(red);
    bw = false(n,m);

    for i = 1:n
        for j = 1:m
            if blue(i,j) >= 10 && blue(i,j) <= 80 && green(i,j) >= 10 && green(i,j) <= 80 && red(i,j) >= 40 && red(i,j) <= 110
                bw(i,j) = 1;
            end
        end
    end

    bw = imerode(bw,strel('disk', 1));
    element = strel('disk', 3);
    bw = imdilate(bw,element);
    bw = imerode(bw,element);
    
    [labels, count] = bwlabel(bw,8);
    boxs = regionprops(labels, 'BoundingBox');
    
    disp (count);
    
    for k = 1:count
        
        bb_i=ceil(boxs(k).BoundingBox);
        idx_x=[bb_i(1)-2 bb_i(1)+bb_i(3)+2];
        idx_y=[bb_i(2)-2 bb_i(2)+bb_i(4)+2];
        if idx_x(1)<1, idx_x(1)=1; end
        if idx_y(1)<1, idx_y(1)=1; end
        if idx_x(2)>m, idx_x(2)=m; end
        if idx_y(2)>n, idx_y(2)=n; end
        
        R = image(idx_y(1):idx_y(2),idx_x(1):idx_x(2),1);
        G = image(idx_y(1):idx_y(2),idx_x(1):idx_x(2),2);
        B = image(idx_y(1):idx_y(2),idx_x(1):idx_x(2),3);
        [fn, fm] = size(R);
        
        for i = 1:fn
            for j = 1:fm
                if ~(B(i,j) >= 10 && B(i,j) <= 80 && G(i,j) >= 10 && G(i,j) <= 80 && R(i,j) >= 40 && R(i,j) <= 110)
                    R(i,j) = 0;
                    G(i,j) = 0;
                    B(i,j) = 0;
                end
            end
        end
        feature = cat(3, R, G, B);
        
        if (((fn*fm)) > 350)
            imshow(imresize(feature,2));
            feature = imresize(feature, [100 100]);
            feature = im2single(feature);
            answer = input('input', 's');
            fileName = [inputImage(1:end-4),'_' , num2str(k),'.png'];
            if (answer == '1')
                imwrite(feature, ['features/tangle/',fileName]);
            elseif (answer == '2')
                imwrite(feature, ['features/plaque/',fileName]);
            end
        end
    end
    
    outSets = [ imageSet(fullfile('features', 'tangle')), ...
                imageSet(fullfile('features', 'plaque'))];

    minSetCount = min([outSets.Count]);        
    if (minSetCount > 0)
        outSets = partition(outSets, minSetCount, 'randomize');
    end
    
end