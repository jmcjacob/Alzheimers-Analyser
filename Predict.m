function [  ] = Predict( inputImage, class )

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
    boxs = regionprops(labels, 'BoundingBox');
    tCenters = cell(1,1);
    pCenters = cell(1,1);
    
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
        [fn,fm] = size(R);
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
        
        [label, score] = predict(class, feature);
        if strcmp(class.Labels(label), 'tangle')
            im=labels==k;
            point = regionprops(im, 'centroid');
            center = cat(1, point.Centroid); 
            tCenters = [tCenters, center];
        elseif strcmp(class.Labels(label), 'plaque')
            im=labels==k;
            point = regionprops(im, 'centroid');
            center = cat(1, point.Centroid);
            pCenters = [pCenters, center];
        end
    end
    
    ts = size(tCenters);
    ps = size(pCenters);
    imshow(image);
    hold on;
    
    if (ts(2) > 1)
        for i = 1:size(tCenters)
            center = tCenters{i+1};
            plot(round(center(:,1)), round(center(:,2)), 'g+');
        end
    end
    if (ps(2) > 1)
        for i = 1:size(pCenters)
            center = pCenters{i+1};
            plot(round(center(:,1)), round(center(:,2)), 'b+');
        end
    end
    hold off;
    
end

