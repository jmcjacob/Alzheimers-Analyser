function [ outSets ] = buildData( inputImage )
% BUILDDATA adds the features from the images into a image set.
% Input: Image file
% Output: Set of Image Features

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
               && green(i,j) <= 110 && red(i,j) >= 40 && red(i,j) <= 170
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
    
%% Displays instructions for building image set.
    disp('Enter 1 for tangle, 2 for plaque and other for noise');
    
%% Makes Directories for features.
    warning off MATLAB:MKDIR:DirectoryExists                                % Turns off unnessary warnings.
    s = mkdir('features');                                                  % Creates folders for use in the system.
    s = mkdir('features', 'tangle');
    s = mkdir('features', 'plaque');
    s = mkdir('features', 'noise');
    
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
        [fn, fm] = size(R);                                                 % Returns size of the feature
        feature = cat(3, R, G, B);                                          % Combines colour channles into one image.
        
        %% Filters out small features.
        if (((fn*fm)) > 1500)                                              
            %% Displays image to the user.
            imshow(imresize(feature,2));                                    % Displays a scaled up image.
            answer = input('Input: ', 's');                                 % Asked user for label.
            fileName = [inputImage(1:end-4),'_' , num2str(k),'.png'];       % Creates file name for image
            
            %% Colour Slicing for feature
            for i = 1:fn
                for j = 1:fm
                    if ~(B(i,j) >= 10 && B(i,j) <= 110 && G(i,j) >= 10 ...
                        && G(i,j) <= 110 && R(i,j) >= 40 && R(i,j) <= 160)
                        R(i,j) = 255;                                       % Sets background of image to white.
                        G(i,j) = 255;
                        B(i,j) = 255;
                    end
                end
            end
            
            %% Gets feature ready to be saved.
            feature = cat(3, R, G, B);                                      % Combines colour channles into one image.
            feature = imresize(feature, [100 100]);                         % Normalises iamge size.
            feature = im2single(feature);                                   % Converts image to Single.
            
            %% Saves Image on hard drive.
            if (answer == '1')                                              % Saves image as tangle with assigned filename.
                imwrite(feature, ['features/tangle/',fileName]);
            elseif (answer == '2')                                          % Saves image as plaque with assigned filename.
                imwrite(feature, ['features/plaque/',fileName]);            
            else                                                            % Saves image as tangle with assigned filename.
                imwrite(feature, ['features/noise/',fileName]);             
            end
        end
    end
    
%% Builds the output set from the folders on the hard drive.
    outSets = [ imageSet(fullfile('features', 'tangle')), ...
                imageSet(fullfile('features', 'plaque')), ...
                imageSet(fullfile('features', 'noise'))];

%% Normalises the number of images in the image set.
    minSetCount = min([outSets.Count]);                                     % Finds the minimum image set count.
    if (minSetCount > 0)
        outSets = partition(outSets, minSetCount, 'randomize');             % Partitions the image set based on minimum set.
    end
end