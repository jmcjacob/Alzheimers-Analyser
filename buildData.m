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
    
    [labels, count] = bwlabel(bw,8);
    
    for l = 1:count
        feature = false(n,m);
        for i = 1:n
            for j = 1:m
                if labels(i,j) == l
                    feature(i,j) = 1;
                end
            end
        end
        imshow(feature);
        answer = input('input', 's');
        fileName = [inpu(1:end-4),'_' , num2str(l),'.png'];
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

