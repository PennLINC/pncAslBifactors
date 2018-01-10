#Create lists of those missing an ASL nii.gz file on chead.

#!/bin/bash

cat /data/joy/BBL/projects/pncAslAcrossDisorder/subjectData/n1042_aslVox11andUp_scanids.csv | while IFS="," read -r a ;
do

if [ ! -f /data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/asl/voxelwiseMaps_cbf/${a}_asl_quant_ssT1Std.nii.gz ]; then

    echo $a >> /data/joy/BBL/projects/pncAslAcrossDisorder/subjectData/MissingASL.csv
   
fi

done

