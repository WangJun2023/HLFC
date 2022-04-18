function obj = cal_obj(F, YPs, L, midclass_set, beta, gamma, F0)

view_num = size(L,3);
layer_num = length(midclass_set);

obj = 0;

for t=1:layer_num
    if t==1
        tmp = 0;
        tmpYPt = YPs{t};
        tmpgammat = gamma{t};
        for p=1:view_num
            tmp = tmp + tmpgammat(p)*trace(L(:,:,p)*tmpYPt(:,:,p)*tmpYPt(:,:,p)');
        end
        obj = obj + tmp;
    else
        tmp = 0;
        tmpYPt = YPs{t};
        tmpYPt0 = YPs{t-1};
        tmpgammat = gamma{t};
        for p=1:view_num
            tmp = tmp + tmpgammat(p)*trace(tmpYPt0(:,:,p)*tmpYPt0(:,:,p)'*tmpYPt(:,:,p)*tmpYPt(:,:,p)');
        end
        obj = obj + tmp;
    end
end

temp = 0;
tmpYPt = YPs{layer_num};
for p = 1:view_num
    temp = temp + beta(p)*trace(F * F' * tmpYPt(:,:,p) * tmpYPt(:,:,p)');
end

obj = obj + temp + beta(view_num+1) * trace(F0 * F0' * F * F');

end

