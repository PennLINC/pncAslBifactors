###COMMAND LINE ARGUMENTS-- NOTE THAT YOU MUST CALL THIS FROM THE FOLDER WHERE ZSTAT IS LOCATED-- DO NOT NEED FULL PATHS
zstat=$1 #assume do NOT specify full path
clthr=$2 #cluster threshold-- i.e., 3.5, 3.09, 2.58, 2.33   
clsz=$3 #mimum cluster size (from 3dClustSim) to look up on easythresh table  

mask=/data/joy/BBL/projects/pncAslAcrossDisorder/images/n1601_PcaslCoverageMask_GM.nii.gz
#get naming and make inverse image
statName=$(basename $zstat | cut -d. -f1)

fslmaths $zstat -mul -1 ${statName}Neg


##Run easythresh
mkdir easythresh_$clthr'_'$clsz
cd easythresh_$clthr'_'$clsz

easythresh ../$zstat $mask $clthr 1 ../$zstat ${statName}_${clthr}_1 -
easythresh ../${statName}Neg $mask $clthr 1 ../$zstat ${statName}Neg_${clthr}_1 

##find clusters


#positive image first
while read line; do
	clusterNum=$(echo $line | cut -d' ' -f1)
	clusterSize=$(echo $line | cut -d' ' -f2)
	if [ "$clusterSize" -lt "$clsz" ]; then
		clusterThresh=$(($clusterNum + 1))
                echo "minimum cluster size reached, cluster number $clusterThresh"
		break
	fi
	echo $clusterNum $clusterSize
done < cluster_${statName}_${clthr}_1.txt


#now negative image
while read line; do
        clusterNum=$(echo $line | cut -d' ' -f1)
        clusterSize=$(echo $line | cut -d' ' -f2)
        if [ "$clusterSize" -lt "$clsz" ]; then
                clusterThreshNeg=$(($clusterNum + 1))
                echo "minimum cluster size reached, cluster number $clusterThreshNeg"
                break
        fi
        echo $clusterNum $clusterSize
done < cluster_${statName}Neg_${clthr}_1.txt

#threshold and make rendered image

fslmaths cluster_mask_${statName}_${clthr}_1 -thr  $clusterThresh -bin tmpPosMask
fslmaths cluster_mask_${statName}Neg_${clthr}_1 -thr  $clusterThreshNeg -bin tmpNegMask
fslmaths tmpPosMask -add tmpNegMask -bin tmpMask
fslmaths ../${statName} -mas tmpMask ${statName}_${clthr}_clsz${clsz}

#upsample rendered image to MNI 1mm
#echo "projecting to MNI 1mm"
#flirt -in ${statName}_${clthr}_clsz${clsz} -ref /import/monstrum/Users/sattertt/MNI/MNI152_T1_1mm_brain.nii.gz -out ${statName}_${clthr}_clsz${clsz}_1mm -applyxfm -init /import/monstrum/Users/sattertt/MNI/MNI_2mm_to_1mm.mat



rm -f tmp*Mask*.nii.gz

