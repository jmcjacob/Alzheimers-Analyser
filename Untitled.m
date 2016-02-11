function [  ] = Untitled( input, thresh )

image = imread(input);
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
disp(count);
features = cell(1, count);
centers = cell(1, 0);

i = imread('SIFTtemplate.png');
single = im2single(i);
[F2,D2] = vl_sift(single);

for l = 1:count
    feature = false(n,m);
    for i = 1:n
        for j = 1:m
            if labels(i,j) == l
                feature(i,j) = 1;
            end
        end
    end
    features{l} = feature;
    [F,D] = vl_sift(im2single(feature));
    [matches] = vl_ubcmatch(D, D2, thresh);
    if (~isempty(matches))
        disp(l);
        center = regionprops(feature, 'centroid');
        centers = [centers {center}];
    end
end

figure();
imshow(image); hold on
[s1,s2] = size(centers);
for i = 1:s2
    center = centers{i};
    centeroid = cat(1, center.Centroid);
    plot(centeroid(:,1), centeroid(:,2), 'g+');
end
hold off

end