function [img, img_gt, rows, cols, bands] = load_data(n)
% 20121127
switch n
    case 1,
        load data\indian\Indian_gt.mat;
        img_gt = indian_pines_gt;
        load data\indian\Indian_pines_corrected.mat;
        img = indian_pines_corrected;
end

[img, rows, cols, bands] = reshape3d_2d(img);
img_gt = img_gt(:);
rdown = 0.001; rup = 0.999;
img = line_dat(img, rdown, rup);
end