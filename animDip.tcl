# VMD for WIN32, version 1.9.3 (November 30, 2016)
# Log file 'D:/reversible logic/pics/script.tcl', created by user Ian
proc vmd_draw_arrow {mol start end} {
    # an arrow is made of a cylinder and a cone
	#puts $start
	#puts $end
    set middle [vecadd $start [vecscale 0.75 [vecsub $end $start]]]
    graphics $mol cylinder $start $middle radius 0.11
    graphics $mol cone $middle $end radius 0.25
}

proc drawmol {FrameNo} {
	global dipoleLol
	# trajData is calculated in proc batch_rmsd
	set dipoleList [lindex $dipoleLol $FrameNo]
	draw delete all
	draw color yellow
	set lenMult 1.25
	
	#puts [lindex $dipoleList 0]
	foreach line $dipoleList {
		puts $line
		set listA {}
		set listB {}
		set lineArr [split $line " "]
		for {set i 0} {$i < 6} {incr i} {
			if {$i < 3} {
				lappend listA [lindex $lineArr $i]
			} else {
				lappend listB [lindex $lineArr $i]
			}
		}
		#puts $listA
		#puts $listB
		set vecEnd [vecsub $listB $listA] 
		set vecEnd [vecscale $vecEnd $lenMult]
		set listB [vecadd $listB $vecEnd]
		draw arrow $listA $listB
	}
}
	
proc readExtDip {extDipStr FrameNo} {
	global dipoleLol
	set dipoleList {}
	set searchStr "Frame $FrameNo"
	set FrameNo2 [expr $FrameNo + 1]
	set endSearch "Frame $FrameNo2"
	#puts $searchStr
	#puts $endSearch
	set infile [open $extDipStr r]
	set file_data [read $infile]
	set data [split $file_data "\n"]
	set result [lsearch $data $searchStr]
	set terminate [lsearch $data $endSearch]
	for {set i [expr $result + 1]} {$i < $terminate} {incr i} {
		set line [lindex $data $i]
		#puts $line
		set lineArr [split $line " "]
		lappend dipoleList $lineArr
	}
	close $infile
	lappend dipoleLol $dipoleList
}

proc readAllExtDip {extDipStr FrameMax} {
	global dipoleLol
	set dipoleLol {}
	for {set i 0} {$i < $FrameMax} {incr i} {
		readExtDip $extDipStr $i
	}
}
	
	
set curr [pwd]
cd $curr
set str [gets stdin]
set strBr ./${str}_bridge.mol2
set fexist [file exist $strBr]
puts "File exist : $fexist"
set strXyz ./${str}.xyz
set strRig ./${str}_rigid.mol2
set strTet ./${str}_tether.mol2
mol new ${strBr} type {mol2} first 0 last -1 step 1 waitfor 1
set bridge [molinfo top]
animate style Loop
mol addfile ${strXyz} type {xyz} first 0 last -1 step 1 waitfor 1 $bridge
animate style Loop
display resetview
mol new ${strRig} type {mol2} first 0 last -1 step 1 waitfor 1
set vdw [molinfo top]
mol addfile ${strXyz} type {xyz} first 0 last -1 step 1 waitfor 1 $vdw
set sel [atomselect top "type C"]
$sel set radius 1.4
set sel [atomselect top "type O"]
$sel set radius 1
set sel [atomselect top "type H"]
$sel set radius 0.7
mol new ${strRig} type {mol2} first 0 last -1 step 1 waitfor 1
set rigid [molinfo top]
mol new ${strTet} type {mol2} first 0 last -1 step 1 waitfor 1
set tether [molinfo top]
animate style Loop
mol modstyle 0 $rigid CPK 0.000000 0.300000 12.000000 12.000000
mol modcolor 0 $rigid ResName
mol modstyle 0 $vdw VDW 0.2500 12.000000
mol modcolor 0 $vdw ResName
mol modstyle 0 $bridge CPK 0.000000 0.200000 12.000000 12.000000
mol modcolor 0 $bridge ResName
mol modstyle 0 $tether CPK 0.000000 0.200000 12.000000 12.000000
mol modcolor 0 $tether ResName
color Resname ARG red
color Resname ASN green
color Resname ASP blue
color Resname GLY silver
color Resname GLU yellow
menu files off
mol addfile ${strXyz} type {xyz} first 0 last -1 step 1 waitfor 1 $rigid
mol addfile ${strXyz} type {xyz} first 0 last -1 step 1 waitfor 1 $tether
set extDipStr0 ./${str}Dipoles
set str [gets stdin]
readAllExtDip $extDipStr0 101
drawmol $str
display projection orthographic
color Display Background white
color Axes Labels black
color Axes Z silver
display cuedensity 0.220000
# VMD for WIN32, version 1.9.3 (November 30, 2016)
# end of log file.
