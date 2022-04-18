function [train_X,train_labels,test_X,test_labels,test_SL] = randdivide(Dataset)
ground_truth = Dataset.ground_truth;
A = Dataset.A;
train_ratio = Dataset.train_ratio;
num_classes = max(max(ground_truth));
pixel_pos = cell(1, num_classes);
[M, N, ~] = size(A);
for i = 1:M
    for j = 1:N
        if ground_truth(i, j) ~= 0
            pixel_pos{ground_truth(i, j)} = [pixel_pos{ground_truth(i, j)}; [i j]];
        end
    end
end

train_X = [];
test_X = [];
train_labels = [];
test_labels = [];
test_pos = [];
row_rank = cell(num_classes, 1);
for i = 1:num_classes
    pos_mat = pixel_pos{i};
    row_rank{i} = randperm(size(pos_mat, 1));
    pos_mat = pos_mat(row_rank{i}, :);
    
    [m1, ~] = size(pos_mat);
    for j = 1 : floor(m1 * train_ratio)
        temp = A(pos_mat(j, 1), pos_mat(j, 2), :);
        train_X = [train_X temp(:)];
        train_labels = [train_labels;i];
    end
end

for i =  1: num_classes
    pos_mat = pixel_pos{i};
    pos_mat = pos_mat(row_rank{i}, :);
    [m1, ~] = size(pos_mat);
    for j = floor(m1 * train_ratio) + 1 : m1
        temp = A(pos_mat(j, 1), pos_mat(j, 2), :);
        test_X = [test_X temp(:)];
        test_labels = [test_labels;i];
        test_pos = [test_pos; (pos_mat(j, 2)-1) * M + pos_mat(j, 1)];
    end
end

train_X = train_X';
test_X = test_X';
test_SL(1,:) = test_pos;
test_SL(2,:) = test_labels;
train_labels = double(train_labels);
test_labels = double(test_labels);
end

