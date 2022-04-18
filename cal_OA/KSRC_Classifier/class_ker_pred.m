function [pred, dist, sci] = class_ker_pred(AtX, AtA, coef, test_lab, dict_lab)
% ||Px - PA_i * s^i||
% modified 20120825
cls = unique(dict_lab);
nClass = length(cls); nTest = length(test_lab);
pred = zeros(1,nTest); dist = zeros(nClass,nTest);
sci = zeros(1,nTest);
for i = 1 : nTest
    err = zeros(1,nClass); isci = zeros(1,nClass);
    j = 1;
    for k = cls
        kDict = (dict_lab == k);
        % xt * AtA * x - 2 * xt * AtX
        err(j) = coef(kDict,i)' * AtA(kDict, kDict) * coef(kDict,i) - 2*coef(kDict,i)'*AtX(kDict,i);
        isci(j) = sum(abs(coef(kDict,i)));
        j = j + 1;
    end
    sci(i) = (nClass*max(isci)/sum(abs(coef(:,i))) - 1) / (nClass - 1);
    [ ~, b] = min(err); pred(i) = cls(b);
    dist(:,i) = err;
end
end