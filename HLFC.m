function [OA, MA, Kappa] = HLFC(Dataset,X1,classifier_type, dimension)

L = LP(X1);

view = size(L,3);
num = size(L, 1);

temp_F0 = zeros(num,num);
opt.disp = 0;

k = 5 : 5 : 50;

for p = 1 : view
    L(:,:,p) = (L(:,:,p)+L(:,:,p)')/2;
    temp_F0 = temp_F0 + (1/view)*L(:,:,p);
end

[F0,~] = eigs(temp_F0, dimension, 'la', opt);

firc = [3 : 1 : 10] * dimension;
secc = [2 : 1 : 10] * dimension;

count = 1;

OA = zeros(length(firc) * length(secc), 10);
MA = zeros(length(firc) * length(secc), 10);
Kappa = zeros(length(firc) * length(secc), 10);
STDOA = zeros(length(firc) * length(secc), 10);
STDMA = zeros(length(firc) * length(secc), 10);
STDKappa = zeros(length(firc) * length(secc), 10);
IE = Entrop(Dataset.X);

for ifi = 1 : length(firc)
    for ise = 1 : ifi
        [F,~, ~, ~, ~] = hierarchical(L, [firc(ifi),secc(ise)], F0, dimension);
        fprintf('计算第 %d 个组合\n',count);
        for i = 1 : length(k)
            [IDX_IE, ~, ~, ~] = kmeans(F, k(i),'maxiter',100,'replicates',50,'emptyaction','singleton');
            for num_IE = 1 : k(i)
                cluster_IE = find(IDX_IE == num_IE);
                [~,Y_IE] = max(IE(cluster_IE));
                I(num_IE) = cluster_IE(Y_IE);
            end
            [acc,Classify_map] = test_bs_accu(I, Dataset, classifier_type);
            OA(count,i) = acc.OA;
            MA(count,i) = acc.MA;
            Kappa(count,i) = acc.Kappa;
            STDOA(count,i) = acc.STDOA;
            STDMA(count,i) = acc.STDMA;
            STDKappa(count,i) = acc.STDKappa;
            clear I cluster_IE Y_IE
        end
        count = count + 1;
    end
end
OA = max(OA);
MA = max(MA);
Kappa = max(Kappa);

end

