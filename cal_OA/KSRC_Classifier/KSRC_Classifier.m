function [OA,MA,Kappa,test_SL,pred] = KSRC_Classifier(Dataset,band_set, Train, Test)

NewData.ground_truth = Dataset.ground_truth;
NewData.A = Dataset.A(:,:,band_set);

sz = size(NewData.A);
rows = sz(1);
cols = sz(2);
img = reshape(NewData.A, [prod(sz(1:2)) sz(3)]);
img = img';
% img_gt = NewData.ground_truth(:);

train_ratio = Dataset.train_ratio;
[GroundT(:,1), ~, GroundT(:,2)] = find(Dataset.ground_truth(:));
GroundT = sortrows(GroundT,2);
no_train = round(size(GroundT,1) * train_ratio);
GroundT=GroundT';
no_classes = max(max(Dataset.ground_truth));
indexes=train_test_random_new(GroundT(2,:),fix(no_train/no_classes),no_train);
train_SL = GroundT(:,indexes);
test_SL = GroundT;
test_SL(:,indexes) = [];
Train.idx = train_SL(1,:);
Train.lab = train_SL(2,:);
Test.idx = test_SL(1,:);
Test.lab = test_SL(2,:);


% parameters
mu = 1e-3; lam = 1e-4; wind = 5; 
sig = sqrt(0.5 ./ 40); sig0 = sqrt(0.5 ./ 0.7);
        
p.mu = mu; p.lam = lam;     

alg = 1;

if alg == 1
    % MF kernel
    [Ktrain, Ktest] = ker_mm(img, rows, cols, Train.idx, Test.idx, wind, sig, [80 80], 1);
else
    % NF kernel
    [Ktrain, Ktest] = ker_lwm(img, rows, cols, Train.idx, Test.idx, wind, sig, sig0, [80 80], 1);
end

AtX = Ktest; AtA = Ktrain;
S = SpRegKL1(AtX, AtA, p);
pred = class_ker_pred(AtX, AtA, S, Test.lab, Train.lab);
test = Test.lab;

test = test';
pred = pred';
test_size = size(test, 1);
cmat = confusionmat(test, pred);
OA = length(find(pred == test)) / length(test);
sum_accu = 0;
for i = 1 : no_classes
    sum_accu = sum_accu + cmat(i, i) / sum(cmat(i, :), 2);
end
MA = sum_accu / no_classes;
Pe = 0;
for i = 1 : no_classes
    Pe = Pe + cmat(i, :) * cmat(:, i);
end
Pe = Pe / (test_size*test_size);
Kappa = (OA - Pe) / (1 - Pe);

end

