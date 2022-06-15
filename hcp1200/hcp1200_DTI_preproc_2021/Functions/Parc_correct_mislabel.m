function Parc_correct_mislabel(Parcellation,Ribbon,LeftHemiROIs,RightHemiROIs,Output,SubCorROIs,RmvNoNei)

% The aim of this script is to correct for mislabelled left and right
% voxels in HCP parcellations

% This issue is caused by Freesurfer not properly identifying the cortical
% surface which causes problems when mapping a parcellation onto a subject.
% The major problem is that some voxels in the right hemisphere get
% labelled as being on the left and vice-versa. As a result ROIs can cross
% hemispheres and can also be highly distorted and irregular in shape.

% This script uses the ribbon.nii.gz file HCP provide for each subject as
% this image provides a clear seperation between left and right cortical
% grey matter (GM) (however there are still likely to be some issues with
% this seperation). It extracts masks for the left and right cortical GM 
% and applies them to the parcellation. Then for each hemisphere the script
% looks for voxels which have been labelled as being in the opposite
% hemisphere. For such voxels, the script then checks that voxels immediate
% neighbours (i.e. the 26 surrounding voxels). If a plurality of the
% surrounding voxels are all from the same ROI then the voxel is assigned
% to that ROI. If no clear plurality is achieved (either by there being a
% tie or the voxels neighbours are all unassigned to a ROI) then algorithm
% will finish labelling the rest of the mislabelled voxels and then come 
% back to those which were unassigned and check if they can now be assigned. 
% If the voxel still cannot be assigned the algorithm will look at the voxels
% neighbours to see if a plurality can be achieved. The algorithm will then
% increase the number of neighbours being examined until eventially a
% plurality can be achieved and the voxel can be assigned

% Written by Stuart Oldham, Monash University 26/07/2017


% If your image includes subcortical ROIs and you don't want these to
% affect calculations provide the intensitives of said ROIs (recommended)
if nargin < 6
    SubCorROIs = [];
end

if nargin < 7
	RmvNoNei = 0;
end

% Read in data

fprintf('Reading in %s\n',Parcellation)

[~,data_mask] = read_nifti(Ribbon);
[hdr2,data] = read_nifti(Parcellation);

% Create masks from the ribbon. Left cortex is labelled as 3 and right is
% labelled as 42 in HCP data
Left_mask = single(data_mask == 3);
Right_mask = single(data_mask == 42);

% Making sure all data is the same data type

data_single = single(data);

% Extracting the cortical voxels which should belong to the left and right
% hemisphere

Right_only = Right_mask.*data_single;
Left_only = Left_mask.*data_single;

% If subcortical ROIs are present remove
if ~isempty(SubCorROIs)
	SubCorIndex = find(ismember(data_single,SubCorROIs));
	SubCorVals = data_single(SubCorIndex);
	Left_only(SubCorIndex) = 0;
	Right_only(SubCorIndex) = 0;
end

% Finding both the coordinates and index of mislabelled voxels

[MisL_x, MisL_y, MisL_z] = ind2sub(size(Left_only),find(ismember(Left_only,RightHemiROIs)));
MisL_vec = find(ismember(Left_only,RightHemiROIs));

[MisR_x, MisR_y, MisR_z] = ind2sub(size(Right_only),find(ismember(Right_only,LeftHemiROIs)));
MisR_vec = find(ismember(Right_only,LeftHemiROIs));

% Create an image of left and right hemispheres where the correction will
% be applied

Left_corrected = Left_only;
Right_corrected = Right_only;

% For the mislabelled voxels in each hemisphere, set there value to zero

Left_corrected(MisL_vec) = 0;
Right_corrected(MisR_vec) = 0;

% Create a vector for each hemisphere which will be used to store the new
% intensity of each voxel

L_replace = zeros(length(MisL_x),1);
R_replace = zeros(length(MisR_x),1);

% Creates an index of voxels that still need reassignment (i.e. have a
% value of 0)
ind = find(L_replace == 0);

% In order to check if the algorithm is actually updating the corrections,
% the number of remaining voxels to be assigned is recorded. If the number
% does not update after an iteration, the search radius is increased.
n = length(ind);

% Records the number of voxels in total which have to be reassigned
initial = n;

% Creates a variable which records the number of voxels that have been
% fixed
fixed = 0;

% Create a variable to record the number of iterations of the algorithm
iter = 0;

% Sets the inital search radius (think of this as the number of levels of
% neighbours being examined e.g. r = 1 only the voxels immediate neighbours
% are examined, r = 2 the voxels neighbours neighbours, r = 3 the voxels
% neighbours neighbours neighbours etc. Also can just imagine a box which
% increases in size around the voxel
r = 1;

while 1

for i = 1:length(ind)

    % Get coordinates of voxel
    x = MisL_x(ind(i)); y = MisL_y(ind(i)); z = MisL_z(ind(i));

    % Identify voxels neighbours
    B = Left_corrected(x-r:x+r,y-r:y+r,z-r:z+r);

    %Find the nonzero neighbours and turn this into a vector
    A = nonzeros(B);

    if ~isempty(A)

        % Count the number of surrounding voxels with the same intensity
        U = unique(A);
        H = histc(A,U);
        M = U(H==max(H));

        % If a clear plurality is achieved, assign the voxel to that
        % intensity
        if length(M) == 1
            L_replace(ind(i)) = M;
            fixed = fixed + 1;
        end
   
    end

clear A B U H M

end

    % In the image apply the intensities
    Left_corrected(MisL_vec) = L_replace;

    % Find the voxels which still need updating
    ind = find(L_replace == 0);
    
    % Increase iteration nuber by 1
    iter = iter + 1;


    % If an iteration finishes but no further voxels have been updates,
    % increase search radius and continue
    if n == length(ind)
        r = r + 1;
        warning('Unable to update mislabelled voxels any further in left hemisphere\n Updating search radius to %d',r)
        % If an iteration finishes and some voxels have been updated but
        % there are still some remaining, continue
    elseif ~isempty(ind)
        n = length(ind);
        fprintf('Completed iteration %d. Fixed %d/%d voxels\n',iter,fixed,initial)
        % If there are no more voxels left to update stop iterating and
        % exit
    elseif isempty(ind)
        fprintf('Completed iteration %d. Fixed %d/%d voxels\n',iter,fixed,initial)
        fprintf('Successfully assigned all mislabelled voxels in left hemisphere!\n')
        break
    end

end


% The same above but for the other hemisphere
ind = find(R_replace == 0);
n = length(ind);
initial = n;
fixed = 0;
iter = 0;
r = 1;
while 1

for i = 1:length(ind)

x = MisR_x(ind(i)); y = MisR_y(ind(i)); z = MisR_z(ind(i));

B = Right_corrected(x-r:x+r,y-r:y+r,z-r:z+r);

A = nonzeros(B);

if ~isempty(A)

U = unique(A);
H = histc(A,U);
M = U(H==max(H));

if length(M) == 1
        R_replace(ind(i)) = M;
        fixed = fixed + 1;
end
   
end

clear A B U H M

end

Right_corrected(MisR_vec) = R_replace;

ind = find(R_replace == 0);
iter = iter + 1;


if n == length(ind)
    r = r + 1;
    warning('Unable to update mislabelled voxels any further in right hemisphere\n Updating search radius to %d',r)
elseif ~isempty(ind)
    n = length(ind);
fprintf('Completed iteration %d. Fixed %d/%d voxels\n',iter,fixed,initial)
elseif isempty(ind)
    fprintf('Completed iteration %d. Fixed %d/%d voxels\n',iter,fixed,initial)
    fprintf('Successfully assigned all mislabelled voxels in right hemisphere!\n')
    break
end

end

% Combine the corrected hemispheres

Combined_corrected = Left_corrected+Right_corrected;

% If a voxel has is not immediately connected to a voxel with the same
% label, set it to zero
if RmvNoNei
    [x, y, z] = ind2sub(size(Combined_corrected),find(Combined_corrected > 0));
    tenth_percent_val = round(length(z)/10);
    val_reached = 1;
    replaced = 0;
    for i = 1:length(x)
        B = Combined_corrected(x(i)-1:x(i)+1,y(i)-1:y(i)+1,z(i)-1:z(i)+1);
        B(2,2,2) = 0;
        A = nonzeros(B);
        if ~ismember(Combined_corrected(x(i),y(i),z(i)),A)
            Combined_corrected(x(i),y(i),z(i)) = 0;
            replaced = replaced + 1;
        end
        if i > tenth_percent_val
            fprintf('%d%% of voxels checked for no friends\n',10*val_reached)
            val_reached = val_reached + 1;
            tenth_percent_val = tenth_percent_val+round(length(z)/10);
        end
    end

fprintf('%d voxels had no neighbours with the same ROI and were replaced with a value of zero\n',replaced)
end

% Insert subcortical ROIs (if present) back into image
if ~isempty(SubCorROIs)
    Combined_corrected(SubCorIndex) = SubCorVals;
end

% Save the output

write_nifti(hdr2,Combined_corrected,Output)
