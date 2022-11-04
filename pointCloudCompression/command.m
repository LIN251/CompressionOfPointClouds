Compression
pointCloudCompression('/Users/linz/Documents/MATLAB/multimediaretrieval-master/Datasets/Princeton/db/17/m1740/m1740.off', './pt1740.ptcld' , [100 100 100])
plotPtCld('./pt1740.ptcld', [100 100 100], [-0.6752 -0.5973 -0.4328])
5k points
5:30 mins

pointCloudCompression('/Users/linz/Documents/MATLAB/multimediaretrieval-master/Datasets/Princeton/db/17/m1740/m1740.off', './pt1741.ptcld' , [1 1 1])
plotPtCld('./pt1741.ptcld', [1 1 1], [0.3433 0.4904 0.8010])
3k points
2:30


Without Compression
cnvPrincetonShapeToPtCld('/Users/linz/Documents/MATLAB/multimediaretrieval-master/Datasets/Princeton/db/17/m1740/m1740.off', './pt17400.ptcld')
plotPtCld('./pt17400.ptcld', [100 100 100], [-0.6752 -0.5973 -0.4328])
16k points