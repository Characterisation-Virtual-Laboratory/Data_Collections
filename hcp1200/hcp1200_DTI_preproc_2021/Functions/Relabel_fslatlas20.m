function Relabel_fslatlas20(INFILE,OUTFILE)

    % read in data
    fprintf(1,'Reading %s\n',INFILE);
    [hdr,data]=read_nifti(INFILE);
    fprintf(1,'Editing %s\n',INFILE);
    % change intensity values for left striatal regions
    data(find(data==1))=51;
    data(find(data==2))=52;
    data(find(data==3))=53;
    % change intensity values for right striatal regions
    data(find(data==4))=61;
    data(find(data==5))=62;
    data(find(data==6))=63;
    % change intensity values for left thalamic regions
    data(find(data==7))=54;
    data(find(data==8))=55;
    data(find(data==9))=56;
    data(find(data==10))=57;
    data(find(data==11))=58;
    data(find(data==12))=59;
    data(find(data==13))=60;
    % change intensity values for right thalamic regions
    data(find(data==14))=64;
    data(find(data==15))=65;
    data(find(data==16))=66;
    data(find(data==17))=67;
    data(find(data==18))=68;
    data(find(data==19))=69;
    data(find(data==20))=70;
    
    data = data - 50;
    data(find(data < 0)) = 0;
    
    write_nifti(hdr,data,OUTFILE)
