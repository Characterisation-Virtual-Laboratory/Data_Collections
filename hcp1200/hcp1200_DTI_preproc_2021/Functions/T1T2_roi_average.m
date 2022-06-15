function T1T2_roi_average(Parcellation,T1_image,T2_image,Output)

[~,parc_data] = read_nifti(Parcellation);

[~,T1_data] = read_nifti(T1_image);

[~,T2_data] = read_nifti(T2_image);

dataA = double(parc_data);

dataB = double(T1_data);

dataC = double(T2_data);

n = max(max(max(dataA)));

ROI_vec = dataA(dataA > 0);
ROI_ind = find(dataA > 0);
T1_vec = dataB(ROI_ind);
T2_vec = dataC(ROI_ind);
T1_zscored = zscore(T1_vec);
T2_zscored = zscore(T2_vec);

for i = 1:n
    ind = dataA == i;
    ind2 = ROI_vec == i;
    MeanT1_ROI(i) = mean(dataB(ind));
    MeanT1z_ROI(i) = mean(T1_zscored(ind2));
    MeanT2_ROI(i) = mean(dataC(ind));
    MeanT2z_ROI(i) = mean(T2_zscored(ind2));
end
clear vec vec2
save(sprintf('%s.mat',Output),'MeanT1_ROI','MeanT2_ROI','MeanT2z_ROI','MeanT1z_ROI')

end
