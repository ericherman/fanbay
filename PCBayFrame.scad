// ****************************************************************************
// Customizable PC Bay Frame
// Author: Peter Holzwarth
// ****************************************************************************
// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language

/* [General] */

menu= "FrontBay"; // [FrontBay,DiskBay35,DiskBay25]

frontThick= 3; // Thickness of the front side
sideThick= 2; // Thickness of the side walls
screwDia= 3; // Diameter of screws used, typically 3mm

/* [Front Bay] */
//  Use "short" for small front bays or plates only, else use "long"
bayLength= "long"; // [long,short]

/* [Disk Bay] */
// True to show a front, or false for an inner-only frame
withFront= "yes"; // [yes,no]
// Number of fans to install for disk bays
numberOfFans= 0; // [0:3]
fanWidth= 11;

openingPattern= "yes"; // [yes,no]
openingPatternDia= 3;
openingPatternXSpc= 2;
openingPatternYSpc= 2;
openingPatternShift= 2;
openingPatternAngle= 30;
openingPatternFn= 6;
openingPatternXSpaceFromFrame= 5;
openingPatternYSpaceFromFrame= 7;

/* [Other Parameters] */
spc= 0.5; // spacing around front opening
$fn=100; // rounding of larger curves

/* [Hidden] */

// 5.25" screw positions, see https://doc.xdevs.com/doc/Seagate/SFF-8551.PDF
F525_A2= 42.3; // front side height
F525_A3= 148; // front side width
F525_A5= 146.05; // inner part width
F525_A10= 47.4; // first side screw distance from front
F525_A11= 79.25; // second side screw distance from first
F525_A13= 10; // side screws height, mandatory lower one
F525_A14= 21.84;  // side screws height, optional upper one

// 3.5" screw positions, see https://doc.xdevs.com/doc/Seagate/SFF-8301.PDF
F35_A1_1= 17.8; // inner height - slim
F35_A1_2= 26.1; // inner height - regular
F35_A1_3= 42; // inner height - full height
F35_A2= 147; // length
F35_A2_panelOffset= 5; // additional length
F35_A3= 101.6; // width
F35_A4= 95.25; // screw distance side-to-side
F35_A6= 44.45; // bottom mid screw from rear screw
F35_A7= 41.28; // bottom rear screw from rear end
F35_A8= 28.5; // side rear screw from rear end
F35_A9= 41.6; // side mid screw from rear screw
F35_A9_2= 101.6; // side front screw from rear screw
F35_A13= 76.20; // bottom front screw from rear screw

// 2.5" screw positions, see https://doc.xdevs.com/doc/Seagate/SFF-8201.PDF
F25_A1_8= 7; // SSD height - typical SSD
F25_A4= 69.85; // SSD width
F25_A6= 100.45; // SSD length
F25_A6_shift= 3; // disk shift
F25_A23= 3; // screw height
F25_A52= 14; // rear screw from back end
F25_A53= 90.6; // front screw from back end

shiftForFans= (menu!="FrontBay" && numberOfFans>0) ? 20 : 0; // if fans are to be used, shift disks further inwards

F_x0= F525_A10+10 + (bayLength=="short"?0:F525_A11)+shiftForFans; // total length of inside
bsd= (F525_A5-F35_A3)/2; // space between 5.25" and 3.5" side walls

Menu();

module Menu() {
    difference() {
        union() {
            // Front side
            Front525();

            // 5.25 left and right sides
            difference() {
                Side525(menu=="DiskBay25");
                Side525ScrewMask();
            }
            translate([0,F525_A5-sideThick,0]) difference() {
                Side525(menu=="DiskBay25");
                Side525ScrewMask();
            }

            // Bottom stabilizers
            BottomStripe525();
            translate([0,F525_A5-bsd,0]) BottomStripe525();
            BottomStripe52LR(withFront);

            // special parts for the different models
            if (menu=="FrontBay") {
                FrontBay_add();
            } if (menu=="DiskBay35") {
                DiskBay35_add();
            } else if (menu=="DiskBay25") {
                DiskBay25_add();
            }
            if (menu!="FrontBay" && numberOfFans>0) {
                Fan_add();
            }
        }
        // special removals for the different models
        if (menu=="FrontBay") {
            FrontBay_rem();
        } if (menu=="DiskBay35") {
            DiskBay35_rem();
        } else if (menu=="DiskBay25") {
            DiskBay25_rem();
        }
        if (menu!="FrontBay" && numberOfFans>0) {
            Fan_rem();
        }
    }
}

// ********************************************************************************
// 5.25" modules
// ********************************************************************************

// 5.25" front side
module Front525() {
    translate([0,-(F525_A3-F525_A5)/2,0]) cube([frontThick, F525_A3, F525_A2]);
}

// For 5.25" front side w/o 3.5" space, the opening pattern
module FrontOpeningPattern() {
    for (x= [-F525_A5+openingPatternXSpaceFromFrame: openingPatternXSpc*2: F525_A5]) {
        for (y= [openingPatternYSpaceFromFrame: openingPatternYSpc*2: F525_A2]) {
            // position of next opening
            tx= x+y/(openingPatternYSpc*2)*openingPatternShift;
            ty= y;
            // is it visible? 
            if (tx >= openingPatternXSpaceFromFrame && tx <= F525_A5-openingPatternXSpaceFromFrame) {
                if (ty >= openingPatternYSpaceFromFrame && ty <= F525_A2-openingPatternYSpaceFromFrame) {
                    // then draw it
                    translate([tx,ty,0]) 
                        rotate([0,0,openingPatternAngle]) 
                            cylinder(r=openingPatternDia/2, h= frontThick+0.02, $fn= openingPatternFn);
                }
            }
        }
    }
}

// 5.25" side wall
module Side525(fullHeight= false) {
    h= fullHeight ? F525_A2-1 : 29;
    translate([-F_x0,0,0]) cube([F_x0,sideThick,h]);
}

// 5.25" bottom stripe from left to right
module BottomStripe52LR(withFront="yes") {
    add= (withFront=="yes")?0:15;
    translate([-bsd-add+frontThick,0,0]) cube([bsd+add-frontThick,F525_A5,sideThick]);
}

// 5.25" bottom stripe front to back
module BottomStripe525() {
    translate([-F_x0,0,0]) cube([F_x0,bsd,sideThick]);
}

// 5.25" side screw masks
module Side525ScrewMask() {
    for (x = [-F525_A10,-F525_A10-F525_A11]) {
        for (z = [F525_A13,F525_A14]) {
            translate([x, -0.01, z]) rotate([-90,0,0]) cylinder(r=screwDia/2-0.2, h= sideThick+0.02, $fn=20);
        }
    }
}

// ********************************************************************************
// 3.5" front/ disk bay and its support modules
// ********************************************************************************

// Front bay shapes
module FrontBay_add() {
    FD35_add();
}

// Front bay openings
module FrontBay_rem() {
    // opening for 3.5" front panel
    Front35();
    FD35_rem();
}

// Disk bay shapes
module DiskBay35_add() {
    FD35_add();
}

module FD35_add() {
    translate([0,bsd-sideThick,0]) Mount35Side();
    translate([0,F525_A5-bsd,0]) Mount35Side();
    
    y3= (F525_A5-F35_A4)/2;
    translate([0,y3-4,0]) BottomStripe35_add();
    translate([0,F525_A5-y3-4,0]) BottomStripe35_add();
}

// Disk bay openings
module DiskBay35_rem() {
    if (openingPattern=="yes") {
        // opening pattern
        translate([-0.01,0,0]) rotate([90,0,0]) rotate([0,90,0]) FrontOpeningPattern();
    }
    FD35_rem();
    if (withFront!="yes") {
        translate([-15,-(F525_A3-F525_A5)/2-0.01,-0.01]) cube([15.01+frontThick, F525_A3+0.02, F525_A2+0.02]);
    }
}

module FD35_rem() {
    Mount35ScrewSupport();
    y3= (F525_A5-F35_A4)/2;
    translate([0,y3-4,0]) BottomStripe35_rem();
    translate([0,F525_A5-y3-4,0]) BottomStripe35_rem();
}

// 3.5" front side or mask for 5.25" front side
module Front35() {
    translate([-0.01,(F525_A5-F35_A3)/2-spc,(F525_A2-F35_A1_2)/2-spc]) 
        cube([frontThick+0.02, F35_A3+2*spc, F35_A1_2+2*spc]);
}

// screw side mount positions
S35_x1= F35_A2+F35_A2_panelOffset-F35_A8; // rear screw from front
S35_x2= S35_x1-F35_A9_2; // mid screw from front
S35_x3= S35_x1-F35_A9; // front screw from front

// Big holes for 5.25 side to let screw driver reach the 3.5" side mount positions
module Mount35ScrewSupport() {
    // skip holes that would invalidate a 5.25 screw mount
    xs= shiftForFans==0 ? [-S35_x3,-S35_x2] : [-S35_x3,-S35_x1];
    for (x= xs) {
        for (y= [-0.01, F525_A5-sideThick-0.01]) {
            translate([x-shiftForFans, y, 13]) rotate([-90,0,0]) cylinder(r=12/2,h=sideThick+0.02);
        }
    }
}

// 3.5" screw side mounts
module Mount35Side() {
    xmax= F525_A10+10 + (bayLength=="short"?0:F525_A11);
    for (x = [-S35_x3,-S35_x2,-S35_x1]) {
        if (x >= -xmax) {
            translate([x-shiftForFans, 0, 0]) Mount35Side1();
        }
    }
}

// one side piece to fix 3.5" screw
module Mount35Side1() {
    difference() {
        union() {
            translate([0,0,13]) rotate([-90,0,0]) cylinder(r=12/2,h=sideThick);
            translate([-12/2,0,0]) cube([12,sideThick,13]);
        }
        translate([-7/2,-0.01,13]) rotate([-90,0,0]) Longhole(7, 3.5, sideThick+0.02);
    }
}

// 3.5" bottom screws
// sh35= (F525_A2-F35_A1_2)/2-spc;
sh35= 7;

// the bottom stripes to mount 3.5" devices from the bottom
module BottomStripe35_add() {
    xx= F35_A2+F35_A2_panelOffset-F35_A7+5;
    xmax= F525_A10+10 + (bayLength=="short"?0:F525_A11);
    x= min(xx, xmax);
    translate([-x-shiftForFans,0,0]) cube([x+1,8,sh35]);
}

module BottomStripe35_rem() {
    translate([-shiftForFans,4,-0.01]) {
        // screw thread
        Mount35BottomScrewMasks();
        // screw head
        Mount35BottomScrewMasks(true);
    }
}

// three screw holes, used for threads and heads
module Mount35BottomScrewMasks(screwHeads= false) {
    x1= F35_A2+F35_A2_panelOffset-F35_A7; // rear screw from front
    x2= x1-F35_A6; // mid screw from front
    x3= x1-F35_A13; // front screw from front
    // for (x = [-32.5,-62.5,-102.5]) {
    for (x = [-x3,-x2,-x1]) {
        translate([x,0,0]) 
            cylinder(r=(screwHeads?screwDia+0.5:screwDia/2), h=sh35+(screwHeads?-2:0.02));
    }
}

// ********************************************************************************
// 2.5" disk bay and its support modules
// ********************************************************************************

// Disk bay shapes
module DiskBay25_add() {
    // middle part
    translate([0,(F525_A5-bsd)/2,0]) BottomStripe525();
    translate([0,(F525_A5-2)/2,0]) Side525(true); // has to be 2mm thick
    // back side stabilizer
    translate([-F_x0+bsd-frontThick,0,0]) BottomStripe52LR("yes");
    // cones to give SSDs their height position
    HalfCones25();
}

// Disk bay openings
module DiskBay25_rem() {
    if (openingPattern=="yes") {
        // opening pattern
        translate([-0.01,0,0]) rotate([90,0,0]) rotate([0,90,0]) FrontOpeningPattern();
    }
    if (numberOfFans > 0) {
        fanStep= F525_A5/numberOfFans;
        for (n= [0:numberOfFans-1]) {
            translate([0,fanStep/2+n*fanStep-20-sideThick,0]) Fan1_rem();
        }
    }
    ScrewHoles25();
    if (withFront!="yes") {
        translate([-15,-(F525_A3-F525_A5)/2-0.01,-0.01]) cube([15.01+frontThick, F525_A3+0.02, F525_A2+0.02]);
    }
}


// 2.5 disk screw holes
module ScrewHoles25() {
    zStep= F525_A2/3;
    for (x= [-F_x0+F25_A52+F25_A6_shift,-F_x0+F25_A53+F25_A6_shift]) {
        for (z= [sideThick+F25_A23:zStep:F525_A2]) {
            translate([x, -0.01, z]) rotate([-90,0,0]) 
                cylinder(r2=screwDia/2+0.25,r1=screwDia/2+sideThick+0.25,h=sideThick+0.02);
            translate([x, F525_A5-sideThick-0.01, z]) rotate([-90,0,0]) 
                cylinder(r1=screwDia/2+0.25,r2=screwDia/2+sideThick+0.25,h=sideThick+0.02);
        }
    }
}

// 2.5 disk support cones
module HalfCones25(flip=false) {
    zStep= F525_A2/3;
    for (x= [-F_x0+16:36:-F_x0+F25_A6]) {
        for (y= [sideThick/2,F525_A5/2]) {
            for (zi= [1,2]) {
                translate([x, y, zi*zStep-3]) HalfCone25(true);
                translate([x, y+F525_A5/2-1, zi*zStep-F25_A23]) HalfCone25(false);
            }
        }
    }
}

// one support cone
module HalfCone25(flip=false) {
    r2= sideThick/2+5;
    difference() {
        cylinder(r1= sideThick/2, r2= r2, h= 5);
        translate([-r2,flip?-r2:0,0]) cube([2*r2,r2,5.01,]);
    }
}

// ********************************************************************************
// Fan support modules
// ********************************************************************************

// fan mount brackets outside
module Fan_add() {
    fanStep= F525_A5/numberOfFans;
    for (n= [0:numberOfFans-1]) {
        translate([0,fanStep/2+n*fanStep-20-sideThick,0]) Fan1_add();
    }
}

// fan mount brackets openings
module Fan_rem() {
    fanStep= F525_A5/numberOfFans;
    for (n= [0:numberOfFans-1]) {
        translate([0,fanStep/2+n*fanStep-20-sideThick,0]) Fan1_rem();
    }
}

// one fan bracket outer shape
module Fan1_add() {
    translate([-fanWidth-2-spc,0,1]) cube([fanWidth+2+spc, 40+2*sideThick,40]);
}

// one fan bracket openings
module Fan1_rem() {
    translate([-fanWidth,sideThick,1]) cube([fanWidth+spc, 40,40.02]);
    translate([-fanWidth-2.01-spc,2*sideThick,1]) cube([fanWidth++2.01+spc, 40-2*sideThick,42]);
}


// ********************************************************************************
// Other support modules
// ********************************************************************************

// ////////////////////////////////////////////////////////////////////////////////
// fast longhole
// Longhole(20, 3, 2);
module Longhole(w, d, th) {
    translate([d/2, 0, 0]) cylinder(r=d/2, h= th, $fn=40);
    translate([w-d/2, 0, 0]) cylinder(r=d/2, h= th, $fn=40);
    translate([d/2, -d/2, 0]) cube([w-d, d, th]);
}
