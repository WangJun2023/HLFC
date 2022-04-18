function K = RBF(X, X2, sigma, block)
% RBF kernel
% 2012_09_20
n1 = size(X,2);  n2 = size(X2,2);
if (n1 < block) && (n2 < block),
    K = ker_rbf(X, X2, sigma);
else
    K = zeros(n1, n2);
    n1_block = ceil(n1/block); n2_block = ceil(n2/block);
    for i = 1 : n1_block
        n1_idx = (i-1)*block+1 : min(i*block, n1);
        for j = 1 : n2_block
            n2_idx = (j-1)*block+1 : min(j*block, n2);
            K(n1_idx, n2_idx) = ker_rbf(X(:,n1_idx), X2(:,n2_idx), sigma);
        end
    end
end
end

function K = ker_rbf(X, X2, sigma)
% RBF kernel
n1sq = sum(X.^2); n1 = size(X,2);
n2sq = sum(X2.^2); n2 = size(X2,2);
D = (ones(n2,1)*n1sq)' + ones(n1,1)*n2sq - 2 * X' * X2;
K = exp(-D/(2*sigma^2));
end