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
    
    for i = 1:count
        
        bb_i=ceil(boxs(i).BoundingBox);
        idx_x=[bb_i(1)-10 bb_i(1)+bb_i(3)+10];
        idx_y=[bb_i(2)-10 bb_i(2)+bb_i(4)+10];
        if idx_x(1)<1, idx_x(1)=1; end
        if idx_y(1)<1, idx_y(1)=1; end
        if idx_x(2)>m, idx_x(2)=m; end
        if idx_y(2)>n, idx_y(2)=n; end
        
        R = image(idx_y(1):idx_y(2),idx_x(1):idx_x(2),1);
        [n,m] = size(R);
        for j = 1:n
            for l = 1:m
                if ~(R(j,l) >= 40 && R(j,l) <= 100)
                    R(j,l) = 1;
                end
            end
        end
        G = image(idx_y(1):idx_y(2),idx_x(1):idx_x(2),2);
        for j = 1:n
            for l = 1:m
                if ~(G(j,l) >= 10 && G(j,l) <= 80)
                    G(j,l) = 1;
                end
            end
        end
        B = image(idx_y(1):idx_y(2),idx_x(1):idx_x(2),3);
        for j = 1:n
            for l = 1:m
                if ~(B(j,l) >= 10 && B(j,l) <= 80)
                    B(j,l) = 1;
                end
            end
        end
        feature = cat(3, R, G, B);
        [fn, fm] = size(feature);
        
        if (((fn*fm)/3) > 350)
            imshow(imresize(feature,2));
            answer = input('input', 's');
            fileName = [inputImage(1:end-4),'_' , num2str(i),'.png'];
            disp(fileName);
            if (answer == '1')
                imwrite(feature, ['features/tangle/',fileName]);
            elseif (answer == '2')
                imwrite(feature, ['features/plaque/',fileName]);
            end
        end
    end
    
    outSets = [ imageSet(fullfile('features', 'tangle')), ...
                imageSet(fullfile('features', 'plaque')) ];

    minSetCount = min([outSets.Count]);        
    if (minSetCount > 0)
        outSets = partition(outSets, minSetCount, 'randomize');
    end
    
end

