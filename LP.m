
function L = LP(X)

v = length(X);
n = size(X{1},2);
    for i = 1 :v
        X{i} = X{i}';
        for  j = 1:n
             X{i}(j,:) = ( X{i}(j,:) - mean( X{i}(j,:) ) ) / std( X{i}(j,:) ) ;
        end
    end
    
    L = zeros(n,n,v);
    for idx = 1 : v
       A0 = constructW_PKN(X{idx}',10);
       A0 = A0-diag(diag(A0));
       A10 = (A0+A0')/2;
       D10 = diag(1./sqrt(sum(A10, 2)));
       L(:,:,idx) = D10*A10*D10;
    end
    
end