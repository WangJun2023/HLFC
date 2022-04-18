function [Ktrain, Ktest] = ker_mm(img, rows, cols, trainidx, testidx, wind, sig, blo, mx)
% mean kernel
% 2012-12-14

train_size = length(trainidx);
train_idx = zeros(train_size, 1); train_idx(1:end) = trainidx;
idx = union(trainidx, testidx);
test_size = length(idx);
test_idx = zeros(test_size, 1); test_idx(1:end) = idx;
img_idx = zeros(rows*cols,1); img_idx(idx) = 1 : test_size;
trainidx = img_idx(trainidx); testidx = img_idx(testidx);

% return value
K = zeros(train_size, test_size);

train_pos(:,1) = mod(train_idx-1,rows) + 1; train_pos(:,2) = (train_idx-train_pos(:,1)) / rows + 1;
test_pos(:,1) = mod(test_idx-1,rows) + 1; test_pos(:,2) = (test_idx-test_pos(:,1)) / rows + 1;
nWind = (2*wind + 1)^2;
w_train_size = zeros(train_size, 1); w_test_size = zeros(test_size, 1);
row_blo = ceil(rows./blo); col_blo = ceil(cols./blo);
block = row_blo .* col_blo;
r1_block = mod((1:block(1))-1,row_blo(1)) + 1; c1_block = ((1:block(1))-r1_block) / row_blo(1) + 1;
r2_block = mod((1:block(2))-1,row_blo(2)) + 1; c2_block = ((1:block(2))-r2_block) / row_blo(2) + 1;

% location of the pixels in the window
[ijw_train, ijw_test] = compute_location;

%==========================================================================
fprintf('%3d',0);
for bi = 1 : block(1), % out block
	fprintf('\b\b\b%3d', bi);
    [train_rc, con] = block_by_block(bi, blo(1), r1_block, c1_block, rows, cols, train_pos);
    if con == 1, continue; end
    if sum(train_rc) == 0, continue; end
    [~, b_train_size, b_w_train, b_train_widx, b_w_train_size] = set_block_train; 
    b_trainw = img(:,b_train_widx);
    for bj = 1 : block(2), % inner block
        %disp([num2str(bi) ', ' num2str(bj) ', ' num2str(block(1)) ',' num2str(block(2))]);
        [test_rc, con] = block_by_block(bj, blo(2), r2_block, c2_block, rows, cols, test_pos);
        if con == 1, continue; end
        if sum(test_rc) == 0, continue; end
        [~, b_test_size, b_w_test, b_test_widx, b_w_test_size] = set_block_test;
        b_testw = img(:,b_test_widx);
        %disp([b_train_wsize b_test_wsize b_train_size b_test_size]);
        % mean kernel
        b_Kbuf = kernelmatrix(b_trainw, b_testw, sig);
        b_K = compute_kernel;
        % normalize
        b_K = b_K .* (1/nWind^2);
        K(train_rc, test_rc) = b_K;
    end
end
fprintf('\n');
%--------------------------------------------------------------------------
Ktrain = K(:,trainidx); Ktest = K(:,testidx);
%==========================================================================
    function [ijw_train, ijw_test] = compute_location
        ijw_train = zeros(nWind, train_size);
        i = train_pos(:,1); j = train_pos(:,2);
        iw_begin = max(i-wind, 1); iw_end = min(i+wind, rows);
        jw_begin = max(j-wind, 1); jw_end = min(j+wind, cols);
        for n = 1 : train_size,
            iw = iw_begin(n) : iw_end(n); jw = jw_begin(n) : jw_end(n);
            iw_size = length(iw); jw_size = length(jw);
            iw = repmat(iw', 1, jw_size); jw = repmat(jw, iw_size, 1);
            ijw = iw + (jw - 1) * rows;
            ijw_train(1:iw_size*jw_size, n) = ijw(:);
            w_train_size(n) = iw_size*jw_size;
        end
        ijw_test = zeros(nWind, test_size);
        i = test_pos(:,1); j = test_pos(:,2);
        iw_begin = max(i-wind, 1); iw_end = min(i+wind, rows);
        jw_begin = max(j-wind, 1); jw_end = min(j+wind, cols);
        for n = 1 : test_size,
            iw = iw_begin(n) : iw_end(n); jw = jw_begin(n) : jw_end(n);
            iw_size = length(iw); jw_size = length(jw);
            iw = repmat(iw', 1, jw_size); jw = repmat(jw, iw_size, 1);
            ijw = iw + (jw - 1) * rows;
            ijw_test(1:iw_size*jw_size, n) = ijw(:);
            w_test_size(n) = iw_size*jw_size;
        end
    end
    function [b_train_idx, b_train_size, b_w_train, b_train_widx, b_w_train_size] = set_block_train
        % set definition of block
        b_train_idx = train_idx(train_rc); b_train_size = length(b_train_idx);
        b_ijw_train = ijw_train(:,train_rc); b_w_train_size = w_train_size(train_rc);
        b_train_widx = unique(b_ijw_train); b_train_widx = b_train_widx(b_train_widx>0);
        b_train_wsize = length(b_train_widx);
        % new location of the pixels in the window
        img_idx = zeros(rows*cols,1); img_idx(b_train_widx) = 1 : b_train_wsize;
        b_w_train = b_ijw_train; b_w_train(b_w_train>0) = img_idx(b_w_train(b_w_train>0));
    end
    function [b_test_idx, b_test_size, b_w_test, b_test_widx, b_w_test_size] = set_block_test
        % set definition of block
        b_test_idx = test_idx(test_rc); b_test_size = length(b_test_idx);
        b_ijw_test = ijw_test(:,test_rc); b_w_test_size = w_test_size(test_rc);
        b_test_widx = unique(b_ijw_test); b_test_widx = b_test_widx(b_test_widx>0);
        b_test_wsize = length(b_test_widx);
        % new location of the pixels in the window
        img_idx = zeros(rows*cols,1); img_idx(b_test_widx) = 1 : b_test_wsize;
        b_w_test = b_ijw_test; b_w_test(b_w_test>0) = img_idx(b_w_test(b_w_test>0));
    end
    function b_K = compute_kernel
        if mx == 1,
            b_K = mex_pk_mm(b_Kbuf, ...
                b_w_train, b_w_train_size, ...
                b_w_test, b_w_test_size, ...
                1);
        else
            b_K = zeros(b_train_size, b_test_size);
            for n = 1 : b_train_size,
                x1 = b_w_train(1:b_w_train_size(n), n);
                K1 = b_Kbuf(x1,:);
                for m = 1 : b_test_size,
                    x2 = b_w_test(1:b_w_test_size(m), m);
                    K2 = K1(:, x2);
                    b_K(n,m) = sum(sum(K2));
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function K = kernelmatrix(X, X2, sig)
% RBF
n1sq = sum(X.^2); n1 = size(X,2);
n2sq = sum(X2.^2); n2 = size(X2,2);
D = n1sq'*ones(1,n2) + ones(n1,1)*n2sq - 2 * X' * X2;
K = exp(-1 / (2*sig^2) * D);
end

function [train_rc, con] = block_by_block(b, blo, r_block, c_block, rows, cols, train_pos)
con = 0;
br = r_block(b); bc = c_block(b);
br_begin = 1 + (br-1) * blo; br_end = min(rows, br*blo); if br_begin > br_end, con = 1; end
bc_begin = 1 + (bc-1) * blo; bc_end = min(cols, bc*blo); if bc_begin > bc_end, con = 1; end
train_rc = (train_pos(:,1) >= br_begin) & (train_pos(:,1) <= br_end) & (train_pos(:,2) >= bc_begin) & (train_pos(:,2) <= bc_end);
end