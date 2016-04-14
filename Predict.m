function [  ] = Predict( inputImage, class )
% PREDICT Classifies the plaques and tangles within an image with a trained
% classifier.
% Input: Image file, trained classifier

%% Reads the image and sets up for processing.
    image = imread(inputImage);                                             % Reads in the image.
    red = image(:,:,1);                                                     % Splits the image into colour channels.
    green = image(:,:,2);
    blue = image(:,:,3);
    [n,m] = size(red);                                                      % Gets size of the image.
    bw = false(n,m);                                                        % Creates a bianry image based on size.

%% Colour Slices the image imto a binary image.
    for i = 1:n
        for j = 1:m
            if blue(i,j) >= 10 && blue(i,j) <= 110 && green(i,j) >= 10 ...
               && green(i,j) <= 110 && red(i,j) >= 40 && red(i,j) <= 160
                bw(i,j) = 1;                                                % Adds pixel to binay image
            end
        end
    end

%% Removes noise from within the binary image.
    bw = imerode(bw,strel('disk', 1));                                      % Erodes the image removing small specs.        
    element = strel('disk', 3);
    bw = imclose(bw,element);                                               % Performs an morphological close on the image.
    
%% Labels each of the features remaing with in the image.
    [labels, count] = bwlabel(bw,8);                                        % Labels each feature within the image.
    boxs = regionprops(labels, 'BoundingBox');                              % Creates a bounding boxes for each label.
    tCenters = cell(1,1);                                                   % Sets up an array for the centers of the features.
    pCenters = cell(1,1);
    
%% Cycles through each lable.
    for k = 1:count
        %% Returns the coodinates of the boudning boxes.
        bb_i=ceil(boxs(k).BoundingBox);                                     % Returns coodinate data for the boundy box.
        idx_x=[bb_i(1)-2 bb_i(1)+bb_i(3)+2];                                % Adds small amounts of padding.
        idx_y=[bb_i(2)-2 bb_i(2)+bb_i(4)+2];
        if idx_x(1)<1, idx_x(1)=1; end                                      % Checks that the coordinates fit on the image.
        if idx_y(1)<1, idx_y(1)=1; end
        if idx_x(2)>m, idx_x(2)=m; end
        if idx_y(2)>n, idx_y(2)=n; end
        
        %% Extracts the feature from the original image with the bounding boxes coordinates.
        R = image(idx_y(1):idx_y(2),idx_x(1):idx_x(2),1);                   % Extracts featue from origianl image.
        G = image(idx_y(1):idx_y(2),idx_x(1):idx_x(2),2);
        B = image(idx_y(1):idx_y(2),idx_x(1):idx_x(2),3);
        [fn,fm] = size(R);                                                  % Returns size of the feature
        
        %% Filters out small features.
        if ((fn*fm) < 1500)
            continue                                                        % Exits the loop.
        end
        
        %% Colour Slicing for feature
        for i = 1:fn
            for j = 1:fm
                if ~(B(i,j) >= 10 && B(i,j) <= 110 && G(i,j) >= 10 ...
                    && G(i,j) <= 110 && R(i,j) >= 40 && R(i,j) <= 160)
                    R(i,j) = 255;                                           % Sets background of image to white.
                    G(i,j) = 255;
                    B(i,j) = 255;
                end
            end
        end
        
        %% Predicts the classification of the image.
        feature = cat(3, R, G, B);                                          % Combines colour channles into one image.
        feature = imresize(feature, [100 100]);                             % Normalises iamge size.
        [label, score] = predict(class, feature);                           % Predicts the classification of the feature.

        %% Adds centers of the plaques and tangles to centers array
        if strcmp(class.Labels(label), 'tangle')
            im=labels==k;
            point = regionprops(im, 'centroid');                            % Gets the center of the tangle.
            center = cat(1, point.Centroid);                                % Formats coordinate of the center.
            tCenters = [tCenters, center];                                  % Adds the center to the tangle array.
        elseif strcmp(class.Labels(label), 'plaque')
            im=labels==k;
            point = regionprops(im, 'centroid');                            % Gets the center of the plaque.
            center = cat(1, point.Centroid);                                % Formats coordinate of the center.
            pCenters = [pCenters, center];                                  % Adds the center to the tangle array.
        end
    end

%% Gets the number of centers and displays image.
    ts = size(tCenters);                                                    % Returns the number of predicted tangles.
    ps = size(pCenters);                                                    % Returns the number of predicted plaques.
    imshow(image);                                                          % Displays the image.
    hold on;

%% Plots each of the plaques and tangles.
    if (ts(2) > 1)
        for i = 2:ts(2)
            center = tCenters{:,i};                                         % Returns the center of the tangle.
            plot(round(center(1)), round(center(2)), 'g+');                 % Plots the center with a green cross.
        end
    end
    if (ps(2) > 1)
        for i = 2:ps(2)
            center = pCenters{:,i};                                         % Returns the center of the plaque.
            plot(round(center(1)), round(center(2)), 'y+');                 % Plots the center with a yellow cross.
        end
    end
    hold off;
    
%% Displays the count of plaques and tangles.
    disp('Plaques: ' + ps(2)-1 + '\nTangles: ' + ts(2)-1);
end

