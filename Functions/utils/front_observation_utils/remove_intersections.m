function S = remove_intersections(S)
%REMOVE_INTERSECTIONS   Reorder snake points to remove self-intersections.
% S = remove_intersection(S)
% Input: snake S represented by a N-by-2 matrix 
% Output: snake S represented by a N-by-2 matrix 

S1 = [S;S(1,:)];
n1 = size(S1,1);
n = n1-1;
for i = 1:n1-3
    for j = i+2:n1-1
        if ( is_crossing(S1(i,:), S1(i+1,:), S1(j,:), S1(j+1,:)) )
            f = i+1;
            t = j;
            if ( j-i > n/2 )
                f = j+1;
                t = i+n;
            end
            counter = 0;
            while ( f < t )
                idF = mod(f,n);
                if ( idF == 0 )
                    idF = n;
                end
                f = f + 1;
                
                idT = mod(t,n);
                if ( idT == 0 )
                    idT = n;
                end
                t = t - 1;
                tmp = S1(idF,:);
                S1(idF,:) = S1(idT,:);
                S1(idT,:) = tmp;
                counter = counter + 1;
                if counter == 1e5
                    t
                    f
                    break
                end
            end
            S1(end,:) = S1(1,:);
        end
    end
end

S = S1(1:end-1,:);

function is_cross = is_crossing(p1, p2, p3, p4)
% detects crossings between a two line segments: p1 to p2 and p3 to p4

is_cross = false;

p21 = p2-p1;
p34 = p3-p4;
p31 = p3-p1;

alpha = (p34(2)*p31(1)-p31(2)*p34(1))/(p34(2)*p21(1)-p21(2)*p34(1));
if alpha>0 && alpha<1
    beta = (p21(2)*p31(1)-p31(2)*p21(1))/(p21(2)*p34(1)-p34(2)*p21(1));
    if beta>0 && beta<1
        is_cross = true;
    end
end