function [img rows cols bands] = reshape3d_2d(dat)
[rows cols bands] = size(dat);
img = zeros(bands, rows*cols);
for i = 1 : bands
    x = dat(:,:,i);
    x = reshape(x,1,rows*cols);
    img(i,:) = x;
end
end