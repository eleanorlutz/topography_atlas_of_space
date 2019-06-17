#!/bin/bash
# This script takes an input of Plate Carree DEM TIFF files and
# reprojects each one into a series of different maps. 
# Each TIFF will be reprojected into a North pole and South pole orthographic projection.
# In addition, each TIFF will be reprojected at the longitude specified latitude and 
# also at the opposite side of the map

inh=("A:/ATLAS_OF_SPACE/DEMs/Mars_HRSC_MOLA_BlendDEM_Global_200mp_v2.tif"
	 "A:/ATLAS_OF_SPACE/DEMs/Venus_Magellan_Topography_Global_4641m_v02.tif"
	 "A:/ATLAS_OF_SPACE/DEMs/Mercury_Messenger_USGS_DEM_Global_665m_v2.tif"
	 "A:/ATLAS_OF_SPACE/DEMs/Ceres_Dawn_FC_HAMO_DTM_DLR_Global_60ppd_Oct2016.tif"
	 "A:/ATLAS_OF_SPACE/DEMs/Pluto_NewHorizons_Global_DEM_300m_Jul2017_16bit.tif"
	 "A:/ATLAS_OF_SPACE/DEMs/Charon_NewHorizons_Global_DEM_300m_Jul2017_16bit.tif"
	 "A:/ATLAS_OF_SPACE/DEMs/Lunar_LRO_LOLA_Global_LDEM_118m_Mar2014.tif"
	 )
outh=("A:/ATLAS_OF_SPACE/image_outputs/ortho_DEMs/mars_"
	  "A:/ATLAS_OF_SPACE/image_outputs/ortho_DEMs/venus_"
	  "A:/ATLAS_OF_SPACE/image_outputs/ortho_DEMs/mercury_"
	  "A:/ATLAS_OF_SPACE/image_outputs/ortho_DEMs/ceres_"
	  "A:/ATLAS_OF_SPACE/image_outputs/ortho_DEMs/pluto_"
	  "A:/ATLAS_OF_SPACE/image_outputs/ortho_DEMs/charon_"
	  "A:/ATLAS_OF_SPACE/image_outputs/ortho_DEMs/moon_"
	  )
lons=(90 90 90 90 165 345 0)
split=180

for i in ${!inh[@]}; do
	lat=(0 90 -90 0)
	# Calculate longitude for opposing side of globe
	if [ ${lons[i]} -ge $split ]; then
		lon_opp=$((${lons[i]} - $split)) 
	else
		lon_opp=$((${lons[i]} + $split)) 
	fi
	lon=(${lons[i]} ${lons[i]} ${lons[i]} ${lon_opp})
	for j in ${!lat[@]}; do
		gdalwarp -t_srs "+proj=ortho +lat_0=${lat[j]} +lon_0=${lon[j]}" ${inh[i]} ${outh[i]}lat${lat[j]}_lon${lon[j]}.tif
		gdalwarp -tr 1500 1500 -r average ${outh[i]}lat${lat[j]}_lon${lon[j]}.tif ${outh[i]}lat${lat[j]}_lon${lon[j]}_downsampled.tif
		gdaldem hillshade -z 20 ${outh[i]}lat${lat[j]}_lon${lon[j]}_downsampled.tif ${outh[i]}lat${lat[j]}_lon${lon[j]}_downsampled_hillshade.tif
		gdaldem slope ${outh[i]}lat${lat[j]}_lon${lon[j]}_downsampled.tif ${outh[i]}lat${lat[j]}_lon${lon[j]}_downsampled_slope.tif
	done 
done 