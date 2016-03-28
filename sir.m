

function [absc,rk] = sir(r);

% r = imrotate(r,90);   %  comment when you have to reduce rows
% the same code can be used to inset or enlarge on both the direction by
% using teh same image but with rotation of 90 degrees.
k = 1;                 %  number of addition of removal
rcd = 2;                %  rc = 1 for reducing otherwise enlarging

figure; imshow(r);

% dedcider if, to redcue or enlarge depending on value of RCD
if rcd == 1;          % reduce 
    rk = double(r);
    for i = 1:k; 
        energy=energyRGB(r);
        [optSeamMask,M] = findseam(energy);
        [absc,rk] = reimMH(r, optSeamMask,rk);
        r = uint8(absc);    
    end
else                  % enlarge
    energy=energyRGB(r);
    [optSeamMask,M] = findseam(energy);
    [absc,rk] = enimMH(r, optSeamMask,k);
end

rk = uint8(rk);        
absc = uint8(absc);
figure; imshow(absc);
figure; imshow(rk);


function [optSeamMask,M] = findseam(energy) % to find the lowesr energ seam
%energy = energyRGB(r);

M = double(energy);
M = padarray(M,[0,1] ,realmax('double'),'both');  % to avoid handling border elements


sz = size(M);
for i = 2 : sz(1)
        for j = 2 : (sz(2) - 1)
            neighbors = [M(i - 1, j - 1) M(i - 1, j) M(i - 1, j + 1)];
            M(i, j) = M(i, j) + min(neighbors);
        end
    end

    [val, indJ] = min(M(sz(1), :));     % find the min element in the last raw
    seamEnergy = 0;
    seamEnergy = double(seamEnergy);
    val = double(val);
    seamEnergy = val;
    %optSeam = zeros(sz(1), 1, 'int32');
    
optSeamMask = zeros(size(energy));

%find seam mask from the above matrix M with lowest energy   
for i = sz(1):-1:2;
    optSeamMask(i,indJ-1) = 1;
    neighbour = [M(i-1,indJ-1) M(i-1,indJ) M(i-1,indJ+1)];
    [val1,indIncr] = min(neighbour);
    val1 = double(val1);
    seamEnergy = seamEnergy + val1;
    %disp(['val1',num2str(val1)]); disp(['SE',num2str(seamEnergy)]);
    seamsum(i)=val1;
    
    indJ = indJ + (indIncr -2);
end
    optSeamMask (1, indJ - 1) = 1; % -1 because of padding on 1 element from left
    optSeamMask = ~optSeamMask;
end

function [imre,rk] = reimMH(r, optSeamMask,rk) % to remove the seam from the findseam
    imre = zeros(size(r, 1), size(r, 2) -1, size(r, 3)); % the actual new image size
    r1 = zeros(size(rk, 1), size(rk, 2) , size(rk, 3)); % the image with seam shown as red
    
    for i = 1 : size(optSeamMask, 1)
        for j = find(optSeamMask(i, :) ~= 1);
        imre(i, :, 1) = [r(i, 1:j-1, 1), r(i, j+1:end, 1)];
        %imre(i, :, 2) = [r(i, 1:j-1, 2), r(i, j+1:end, 2)]; % for the black and white image
        %imre(i, :, 3) = [r(i, 1:j-1, 3), r(i, j+1:end, 3)];
        r1(i,:,1) = [rk(i,1:j-1,1),255,rk(i,j+1:end,1)];
        %r1(i,:,2) = [rk(i,1:j-1,2),0,rk(i,j+1:end,2)];
        %r1(i,:,3) = [rk(i,1:j-1,3),0,rk(i,j+1:end,3)];
        
        end
    end
   rk = r1; 
end

function [imre,rk] = enimMH(r, optSeamMask,k)
       r = double(r);
       rk = double(r);
while k > 0; % to enlarge more than one seam we have to create multiple seams
    imre = zeros(size(r, 1), size(r, 2) + 1, size(r, 3));
    r1 = zeros(size(r, 1), size(r, 2) + 1, size(r, 3));
    for i = 1 : size(optSeamMask, 1)
        for j = find(optSeamMask(i, :) ~= 1);
        if j == size(optSeamMask, 2)
            imre(i, :, 1) = [r(i, 1:j, 1), r(i, j, 1), r(i, j+1:end, 1)];
            %imre(i, :, 2) = [r(i, 1:j, 2), r(i, j, 2), r(i, j+1:end, 2)];
            %imre(i, :, 3) = [r(i, 1:j, 3), r(i, j, 3), r(i, j+1:end, 3)];
            r1(i,:,1) = [rk(i,1:j-1,1),255,255,rk(i,j+1:end,1)];
            %r1(i,:,2) = [rk(i,1:j-1,2),0,0,rk(i,j+1:end,2)];
            %r1(i,:,3) = [rk(i,1:j-1,3),0,0,rk(i,j+1:end,3)];
        else
            imre(i, :, 1) = [r(i, 1:j, 1), round(r(i, j, 1)./2+ r(i, j+1, 1)./2), r(i, j+1:end, 1)];
            %imre(i, :, 2) = [r(i, 1:j, 2), round(r(i, j, 2)./2+ r(i, j+1, 2)./2), r(i, j+1:end, 2)];
            %imre(i, :, 3) = [r(i, 1:j, 3), round(r(i, j, 3)./2+ r(i, j+1, 3)./2), r(i, j+1:end, 3)];
            r1(i,:,1) = [rk(i,1:j-1,1),255,255,rk(i,j+1:end,1)];
            %r1(i,:,2) = [rk(i,1:j-1,2),0,0,rk(i,j+1:end,2)];
            %r1(i,:,3) = [rk(i,1:j-1,3),0,0,rk(i,j+1:end,3)];
        end
        end
    end
    r = imre;
    rk = r1;
    energy=energyRGB(rk);
    [optSeamMask,M] = findseam(energy);
    k=k-1;
    r = uint8(r);
end
r = imre; % to get the size correct for the next 
end  


end