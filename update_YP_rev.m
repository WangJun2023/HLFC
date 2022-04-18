function YPs = update_YP_rev( F, YPs, L, beta, gamma, midclass_set )

base_kernel_num = size(L,3);
sample_num = size(F, 1);
layer_num = length(midclass_set);

if layer_num==1
    
    tmpYP = zeros(sample_num, midclass_set(1), base_kernel_num);
    tmpgamma = gamma{1};
    for p=1:base_kernel_num
        tmp = tmpgamma(p)*L(:,:,p) + beta(p)*(F*F');
        tmp= (tmp+tmp')/2;
        opt.disp = 0;
        [Yptmp,~] = eigs(tmp,midclass_set(layer_num),'LA',opt);
        tmpYP(:,:,p) = Yptmp;
    end
    YPs{1} = tmpYP;
    
else
    
    for t=layer_num:-1:1
        tmpYPt = zeros(sample_num, midclass_set(t), base_kernel_num);
        if t==1
            tmpYPt1 = YPs{t+1};
            tmpgammat = gamma{t};
            tmpgammat1 = gamma{t+1};
            for p = 1:base_kernel_num
                tmp = tmpgammat(p)*L(:,:,p) + tmpgammat1(p)*tmpYPt1(:,:,p)*tmpYPt1(:,:,p)';
                tmp= (tmp+tmp')/2;
                opt.disp = 0;
                [Yptmp,~] = eigs(tmp,midclass_set(t),'LA',opt);
                tmpYPt(:,:,p) = Yptmp;
            end
        elseif t==layer_num
            tmpYPt0 = YPs{t-1};
            tmpgammat = gamma{t};
            for p = 1:base_kernel_num
                tmp = tmpgammat(p)*tmpYPt0(:,:,p)*tmpYPt0(:,:,p)' + beta(p)*(F*F');
                tmp= (tmp+tmp')/2;
                opt.disp = 0;
                [Yptmp,~] = eigs(tmp,midclass_set(t),'LA',opt);
                tmpYPt(:,:,p) = Yptmp;
            end
        else
            tmpYPt0 = YPs{t-1};
            tmpYPt1 = YPs{t+1};
            tmpgammat = gamma{t};
            tmpgammat1 = gamma{t+1};
            for p = 1:base_kernel_num
                tmp = tmpgammat(p)*tmpYPt0(:,:,p)*tmpYPt0(:,:,p)' + tmpgammat1(p)*tmpYPt1(:,:,p)*tmpYPt1(:,:,p)';
                tmp= (tmp+tmp')/2;
                opt.disp = 0;
                [Yptmp,~] = eigs(tmp,midclass_set(t),'LA',opt);
                tmpYPt(:,:,p) = Yptmp;
            end
        end
        YPs{t} = tmpYPt;
    end

end






end

