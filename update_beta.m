function beta = update_beta( F, YPs, F0)

view_num = size(YPs, 3);
temp = zeros(1, view_num + 1);
for p=1:view_num
    temp(1,p) = trace(YPs(:,:,p) * YPs(:,:,p)' * F * F'); 
    beta(p) = temp(1,p)/norm(temp,2);
end

% temp(1,view_num + 1) = trace(F0 * F0' * F * F');
% beta(view_num+1) = temp(1,p+1)/norm(temp,2);
beta(view_num+1) = 0;

end

