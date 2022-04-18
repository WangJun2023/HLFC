function [OA,MA,Kappa,test_SL,predict_labels] = SVM_Classifier(Dataset, band_set)

[train_X,train_labels,test_X,test_labels,test_SL] = randdivide(Dataset);
test_size = size(test_labels, 1);
C = max(test_labels);
bs_train_X = train_X(:, band_set);
bs_test_X = test_X(:, band_set);


model = svmtrain(train_labels, bs_train_X, Dataset.svm_para);
[predict_labels, corrected_num, ~] = svmpredict(test_labels, bs_test_X, model, '-q');
OA = corrected_num(1) / 100;
cmat = confusionmat(test_labels, predict_labels);
sum_accu = 0;
for i = 1 : C
    sum_accu = sum_accu + cmat(i, i) / sum(cmat(i, :), 2);
end
MA = sum_accu / C;
Pe = 0;
for i = 1 : C
    Pe = Pe + cmat(i, :) * cmat(:, i);
end
Pe = Pe / (test_size * test_size);
Kappa = (OA - Pe) / (1 - Pe);
end

