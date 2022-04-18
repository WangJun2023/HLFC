function opt = class_eval(dat_lab, lab)
% modified 20120825
cls = unique(lab);
nClass = length(cls);
opt.ratio = zeros(1,nClass); opt.OA = 0; opt.num = zeros(nClass);
l = 1;
for k = cls
    idx = (lab == k);
    k_cls = sum(idx);
    k_crt = sum(dat_lab(idx) == k);
    opt.ratio(l) = k_crt / k_cls * 100;
    opt.OA = opt.OA + k_crt;
    j = 1;
    for i = cls
        opt.num(j,l) = sum(dat_lab(idx)==i);
        j = j + 1;
    end
    l = l + 1;
end
opt.OA = opt.OA / length(lab) * 100;

n = sum(opt.num(:));                     % Total number of samples
PA     = sum(diag(opt.num));

% Estimated Overall Cohen's Kappa (suboptimal implementation)
npj = sum(opt.num,1);
nip = sum(opt.num,2);
PE  = npj*nip;
if (n*PA-PE) == 0 && (n^2-PE) == 0
    % Solve indetermination
    opt.Kappa = 1;
else
    opt.Kappa  = (n*PA-PE)/(n^2-PE);
end
end