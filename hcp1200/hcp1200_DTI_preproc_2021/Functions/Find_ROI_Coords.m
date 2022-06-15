load 50_participants.txt
y = 0
for i = X50_participants'
    y = y + 1;
    x = sprintf('aparc+aseg_%d.nii', i); 
    a = getCOG(x,.7);
    a(:,1) = a(:,1)*-1;
    ROI_coords{y,1} = a;
end
    