function [maxI] = searchPeak(A, Mark, range)
max = 0;		% value
maxI = -1;		% index
for i = floor(range(1)):ceil(range(2))
    if (Mark(i) ~= -1  && A(i) > max)
		max = A(i);
		maxI = i;
    end
end
end

