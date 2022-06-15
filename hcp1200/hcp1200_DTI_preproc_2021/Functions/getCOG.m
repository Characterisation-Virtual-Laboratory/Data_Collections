%GETCOG Find center of gravity of each region and print to a text file.
%
% Remarks:
% If the true center of gravity is outside the region, the voxel
% inside the region that is closest to this point is used as the
% actual center of gravity.
%
% MNI coordinates are reported.
%
% Original by Andrew Zalesky, University of Melbourne.
% Modified by Simon Baker, Monash University.

function coornew = getCOG(FILEPATH,VOXDIM,flip,filename,HCP) % Simon 20150318

%Read in parcellation template
if HCP == 1
[hdr,data]=read_hcp(FILEPATH); % Simon 20150318
else
[hdr,data]=read(FILEPATH);
end
%Voxel dimension
mm=VOXDIM; % Simon 20150318

sform_mat=[hdr.hist.srow_x;hdr.hist.srow_y;hdr.hist.srow_z;[0,0,0,1]]; % Simon 20150318
sform_inv=inv(sform_mat); % Simon 20150318

origin=[sform_inv(1,4),sform_inv(2,4),sform_inv(3,4)]; % Simon 20150318

ind_aal=setdiff(unique(data(:)),0);

coor=zeros(length(ind_aal),3);
for i=1:length(ind_aal)
    [x,y,z]=ind2sub(size(data),find(ind_aal(i)==data));
    [~,ind_min]=min(sqrt((mean(x)-x).^2+(mean(y)-y).^2+(mean(z)-z).^2));
    coor(i,:)=[x(ind_min(1)),y(ind_min(1)),z(ind_min(1))];
end

%Map voxel coordinates to MNI coordinates
coor=(coor-repmat(origin,length(ind_aal),1))*mm;
%Uncomment below in order to swap left and right
if flip
coor(:,1) = coor(:,1)*-1;
end
x=coor(:,1); x=x+0;
y=coor(:,2); y=y-0;
z=coor(:,3); z=z+0;
coornew=horzcat(x,y,z);
%Write to a text file
%dlmwrite('COG.txt',coor,'delimiter',' ','precision','%.0f');
if ~isempty(filename)
dlmwrite(filename,coornew,'delimiter',' ','precision','%.0f');
end
end