function F = update_F( beta, YPs, F0, dimension)

view_num = size(YPs,3);
sample_num = size(YPs, 1);

temp = zeros(sample_num, sample_num);
for p=1:view_num
    temp = temp + beta(p) * YPs(:,:,p) * YPs(:,:,p)';
end
temp = temp + beta(view_num+1) * (F0 * F0');
tmp= (temp+temp')/2;
opt.disp = 0;
[F,~] = eigs(tmp,dimension,'LA',opt);
end
