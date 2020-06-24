function [eps] = findSpread(p, A, ff)
% find the range of spread of a peak
%ave = sum(A) / length(A);
ave = geomean(A);
totalA = sum(A(ceil(p-0.5*ff) : ceil(p+0.5*ff)) - ave);
% area under curve with average deducted
eps = 0;		% epsilon
AP = 0;
while AP < 0.94 * totalA
	AP = sum(A(p-eps : p+eps) - ave);
    eps = eps + 1;
end    
end

