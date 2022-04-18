function [trainidx, testidx] = load_train_test(dat, type, i, j)
switch dat,
    case 1,
        if type == 1,
            load(['data\indian\train_test\Indian_n' num2str(i) '_' num2str(j) '.mat']);
        end
        if type == 2,
        end
end
trainidx = train_idx; testidx = test_idx;
end