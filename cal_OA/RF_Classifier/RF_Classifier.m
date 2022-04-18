function [OA,MA,Kappa,test_SL,predict_label] = RF_Classifier(Dataset, band_set)

[train_X,train_labels,test_X,test_labels,test_SL] = randdivide(Dataset);
test_size = size(test_labels, 1);
C = max(test_labels);
bs_train_X = train_X(:, band_set);
bs_test_X = test_X(:, band_set);


nTree = 20;
B = TreeBagger(nTree,bs_train_X,train_labels');
predict_label = predict(B,bs_test_X);
predict_label = str2double(predict_label);
cmat = confusionmat(test_labels, predict_label);
OA = length(find(predict_label == test_labels)) / length(test_labels);
sum_accu = 0;
for i = 1 : C
    sum_accu = sum_accu + cmat(i, i) / sum(cmat(i, :), 2);
end
MA = sum_accu / C;
Pe = 0;
for i = 1 : C
    Pe = Pe + cmat(i, :) * cmat(:, i);
end
Pe = Pe / (test_size*test_size);
Kappa = (OA - Pe) / (1 - Pe);

end

