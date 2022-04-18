function S = SpRegKL1(AtX, AtA, param)
% kernel sparse regression 
% 2012_10_03

J = size(AtA,2);

% param set
if ~isfield(param,'lam'), lam = 1E-3; else lam = param.lam; end
if ~isfield(param,'mu'), mu = 1; else mu = param.mu; end
if ~isfield(param,'tol'), tol = 1E-3; else tol = param.tol; end
if ~isfield(param,'maxit'), maxit = 1000; else maxit = param.maxit; end
if ~isfield(param, 'verb'), verb = 1; else verb = param.verb; end
if ~isfield(param, 'exact'), exact = 1; else exact = param.exact; end

if exact == 1,
    % inital
    s = zeros(size(AtX)); d = s;
    F = inv(AtA+mu*eye(J));
    S0 = F * AtX;
    % algorithm
    for iter = 1 : maxit,
        S = F * (AtX + mu*(s+d));
        s = soft(S-d, lam/mu);
        d = d - (S - s);
        if check_stop(iter, S, S0, tol),
            break;
        end
        print_state(iter, verb);
        S0 = S;
    end
else
    %
end

if verb == 1, 
    disp(strcat(['SpRegKL1 Iterations:', num2str(iter)])); 
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function z = soft(u, a)
z = sign(u) .* max(abs(u)-a, 0);
end

function stop = check_stop(iter, S, S0, tol)
stop = 0;
if iter > 1,
    dtol = sqrt(sum(sum((S-S0).^2)) / sum(sum(S0.^2)));
    if dtol < tol, stop = 1; end
end
end

function print_state(iter, verb)
if rem(iter,10)==0,
    if verb == 1, fprintf('.'); end
end
end

function val = fun_val(AtA, AtX, S, lam)
SSt = S * S';
val = 0.5 * sum(sum(AtA.*SSt)) - sum(sum(AtX.*S)) + lam * sum(sum(abs(S)));
end