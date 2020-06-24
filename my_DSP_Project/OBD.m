function [Fout] = OBD(F)
%   overtone-based denoise
Fout = F;
A = abs(F);
N = length(A);
L = ceil(N/2);
Mark = zeros(N, 1);
ave = sum(A) / N;
count = 5;	
Find = 0;
% if after 5 search, no suitable peak is found: exit and report exception
while ((isequal((Mark==1), zeros(size(Mark)))) && (count > 0))
	count = count - 1;
	p = searchPeak(A, Mark, [1, L]);	
    % circular-even -> only do the left hand side
	% now we find the highest peak
	range = [p-10, p+10];
	pf = searchPeak(A, Mark, 0.5*range);
    if A(pf) > sqrt(ave * A(p))
	% the peak is at the 1st overtone
		range = [pf-10, pf+10];
        if (3*p < L)	% see if we can search on
			p2 = searchPeak(A, Mark, 3*range);
            if A(p2) > sqrt(A(p) * ave)	% use amplitude at p to check
                i = 1;
                while (pf * i <= L)
                   Mark(searchPeak(A, Mark, i*range)) = 1;
                   i = i + 1;
                end 
				Find = 1;
				ff = pf;	% fundamental frequency
            else
				Mark(pf) = -1;
				Mark(p) = -1;
            end
        else	% if we can't, then guess we find it.
			Mark(pf) = 1;
			Mark(p) = 1;
			Find = 1;
			ff = pf;	
        end
    else
	% the peak is at the fundamental frequency
		p1 = searchPeak(A, Mark, 2*range);	% check if its 1st overtone exists
        if A(p1) > sqrt(ave * A(p))		% if so
            if 3*p <= L
				p2 = searchPeak(A, Mark, 3*range);
                if A(p2) > sqrt(A(p1) * ave)
                    i = 1;
                    while p * i <= L
                        Mark(searchPeak(A, Mark, i*range)) = 1;
                        i = i + 1;
                    end    
					Find = 1;
					ff = p;	
                else
                    Mark(p) = -1;
                end
            else						
				Mark(p) = 1;
				Mark(p1) = 1;
				Find = 1;
				ff = p;	
            end
        else 					% this is not funamental fequency
			Mark(p) = -1;
        end
    end
end

if (Find == 0)
    error("No legal fundamental frequency found.");
end
% Find all corresponding peaks on the rhs
% In matlab, due to the way matlab index (1 to length(A)),
% circular-even is "A[k] = A[length +2 - k]" 
for i = 2:L
    if Mark(i) == 1
		Mark(N + 2 - i) = 1;
    end
end
keep = zeros(N, 1);
%for all peaks P
for P = 1:N
    if Mark(P) == 1
        eps = findSpread(P, A, ff);
        for i = (P - eps):(P + eps)
            keep(i) = 1;
        end
    end
end
% finally, the denoise
% use savage approach: set others to 0
for i = 1:N
    if keep(i) ~= 1
		Fout(i) = 0;
    end
end
disp("Procedure complete.")
end

