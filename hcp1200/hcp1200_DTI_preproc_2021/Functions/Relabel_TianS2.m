function Relabel_TianS2(INFILE,OUTFILE)

    % read in data
    fprintf(1,'Reading %s\n',INFILE);
    [hdr,data]=read_nifti(INFILE);
    fprintf(1,'Editing %s\n',INFILE);
    % change intensity values for left striatal regions
	newdata = data;
	NewLabels = [17:32 1:16];
	for i = 1:32

    data(find(data==i))=NewLabels(i)+50;
	
	end
    
    data = data - 50;
    data(find(data < 0)) = 0;
    
    write_nifti(hdr,data,OUTFILE)
