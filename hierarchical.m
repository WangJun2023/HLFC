function [F, YPs, beta, gamma, obj] =  hierarchical(L, midclass_set, F0, dimension)

view_num = size(L, 3);
sample_num = size(L, 1);
layer_num = length(midclass_set);

YPs = cell(layer_num, 1);
gamma = cell(layer_num, 1);

for t = 1 : layer_num
    tmp = zeros(sample_num, midclass_set(t), view_num);
    opt.disp = 0;
    for p = 1 : view_num
        L(:,:,p)= (L(:,:,p) + L(:,:,p)')/2;
        [tmp(:,:,p),~] = eigs(L(:,:,p),midclass_set(t),'LA',opt);
    end
    YPs{t} = tmp;
    gamma{t}= ones(view_num,1)/view_num;
end
beta = ones(view_num + 1,1)/(view_num+1);
beta(view_num+1) = 0;
t = 0;
flag = 1;
while flag
    %% update F
    F = update_F(beta, YPs{layer_num}, F0, dimension);
    
    %% update YPs
    if rem(t, 2) == 0
        YPs = update_YP_nor(F, YPs, L, beta, gamma, midclass_set);
    else
        YPs = update_YP_rev(F, YPs, L, beta, gamma, midclass_set);
    end
    
    %% update beta
    beta = update_beta(F, YPs{layer_num}, F0);
    
    %% update gamma
    gamma = update_gamma(YPs, L, midclass_set);
    
    t = t+1;
    obj(t) = cal_obj(F, YPs, L, midclass_set, beta, gamma, F0);
    if (t>2) && (abs((obj(t)-obj(t-1))/(obj(t-1)))<1e-5 || t>100)
        flag =0;
    end
end

F = F./ repmat(sqrt(sum(F.^2, 2)), 1,dimension);
end

