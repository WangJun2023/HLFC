function [Train, Test] = set_train_test(train_idx, test_idx, img, img_gt)
% 20121127
Train.idx = train_idx; Test.idx = test_idx;
Train.dat = img(:, train_idx); Test.dat = img(:, test_idx);
Train.lab = img_gt(train_idx)'; Test.lab = img_gt(test_idx)';
end