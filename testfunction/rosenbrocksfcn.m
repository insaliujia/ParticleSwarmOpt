function f = rosenbrocksfcn(x)
% This is a test function named Rosenbrock function for testing PSO
x = reshape(x,1,[]) ;
if size(x,2) >= 2
    f = 0;
    for i = 1:size(x,2)-1
        f = f + (1-x(i))^2 + 100*(x(i+1) - x(i)^2)^2 ;
    end
else
    error('Rosenbrock''s function requires at least two inputs')
end
end