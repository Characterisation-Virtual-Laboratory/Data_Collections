function extract_ROIs(Parcellation, ROIs,Output,relabel)

[hdr,data] = read_nifti(Parcellation);

ind = ~ismember(data,ROIs);

data(ind) = 0;

if relabel
    u = nonzeros(unique(data));
    [~,s] = sort(u,'ascend');
    data = changem(data,s,u);
end

write_nifti(hdr,data,Output)

end