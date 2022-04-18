function gamma = update_gamma( YPs, L, midclass_set)

view_num = size(L, 3);
layer_num = length(midclass_set);

gamma = cell(layer_num, 1);

for t=1:layer_num
    V = zeros(view_num,1);
    if t == 1
        tmpYPt = YPs{t};
        for p=1:view_num
            V(p) = trace(tmpYPt(:,:,p)*tmpYPt(:,:,p)'*L(:,:,p));
        end
    else
        tmpYPt = YPs{t};
        tmpYPt0 = YPs{t-1};
        for p=1:view_num
            V(p) = trace(tmpYPt0(:,:,p)*tmpYPt0(:,:,p)'*tmpYPt(:,:,p)*tmpYPt(:,:,p)');
        end
    end

    gamma{t} = V./norm(V,2);
end 

end

