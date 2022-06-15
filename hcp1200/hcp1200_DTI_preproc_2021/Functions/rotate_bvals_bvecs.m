%Rotate bvecs and bvals to make them work with GenCog data

function rotate_bvals_bvecs
bvals = dlmread('bvals_RL.txt');
bvecs = dlmread('bvecs_RL_rotated.txt');
bvals = bvals';
bvecs = bvecs';
dlmwrite('bvals.txt',bvals,'delimiter','\t');
dlmwrite('bvecs.txt',bvecs,'delimiter','\t');
