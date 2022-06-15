function ConfigureParc(INFILE,PARCS,OUTFILE)

[hdr,data]=read(INFILE);

HEMIPARC = PARCS/2;

LhMaxOldPARC = 1000+HEMIPARC;
RhMaxOldPARC = 2000+HEMIPARC;

LH_OLD_VALS = 1001:LhMaxOldPARC;
RH_OLD_VALS = 2001:RhMaxOldPARC;

LHMaxNewParc = HEMIPARC;
RHMaxNewParc = PARCS;

LH_NEW_VALS = 1:LHMaxNewParc;
RH_NEW_VALS = LHMaxNewParc+1:RHMaxNewParc;

IND = ismember(data, [LH_OLD_VALS RH_OLD_VALS]);

data(~IND) = 0;

data_relabelled = changem(data,[LH_NEW_VALS RH_NEW_VALS],[LH_OLD_VALS RH_OLD_VALS]);

write(hdr,data_relabelled,OUTFILE);