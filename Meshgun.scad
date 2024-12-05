// Meshgun - Handheld 3D scanner
//
// Thomas Kircher <tkircher@gnu.org>, 2021
//

// The parts we use for the scan head are:
//  - A fairly generic 1024x600 7" HDMI capacitive touch display, from Kuman
//       These all seem to be based on the RTD2660H
//       The PCBs all seem to be identical, including the mount points
//
//  - A Jetson Xavier NX, or Orin
//  - An Azure Kinect DK, RealSense D435+T265 cameras, or a Zed 2

hex_dia_M3 = 5.8 / (sqrt(3) / 2);
hex_dia_M2_5 = 5.2 / (sqrt(3) / 2);

// -------------------------------------------------------------------------

// Convenience functions
module rectangular_hole_pattern(width, length, diameter, offset, height) {
  for(i = [-1 : 2 : 1])
  for(j = [-1 : 2 : 1]) {
    translate([i * width / 2, j * length / 2, offset])
      cylinder(d = diameter, h = height, $fn = diameter * 12);
  }
}

module hex_nut_seats(width, length, dia = hex_dia_M3, height = 2, angle = 0, taper = 2.8) {
  for(i = [-1 : 2 : 1])
  for(j = [-1 : 2 : 1]) {
    translate([i * width / 2, j * length / 2, -0.1])
    rotate([0, 0, angle]) {
      cylinder(d = dia, h = height, $fn = 6);

      translate([0, 0, height - 0.001])
        cylinder(d1 = dia, d2 = taper, h = 2.2, $fn = 6);
    }
  }
}

module countersinks(width, length) {
  for(i = [-1 : 2 : 1])
  for(j = [-1 : 2 : 1]) {
    translate([i * width / 2, j * length / 2, -0.1]) {
      cylinder(d = 6.2, h = 2.0, $fn = 60);

      translate([0, 0, 2.0 - 0.001])
        cylinder(d1 = 6.2, d2 = 2.8, h = 2.2, $fn = 60);
    }
  }
}

// Cutout shape for corners
module corner_fillet(diameter, height) {
  difference() {
    translate([-diameter, -diameter, 0])
      cube([diameter, diameter, height]);

    translate([0, 0, -0.1])
      cylinder(d = diameter, h = height + 1, $fn = diameter * 20);
  }
}

// -------------------------------------------------------------------------

// The back of the display case, where the LCD is mounted
module display_base() {
  case_height = 2.6;
  wall_t = 5 * 0.4;

  difference() {
    union() {
      translate([-174 / 2, -132 / 2, 0])
        cube([174, 132, case_height]);

      // The display isn't centered to the mount points, so we
      // offset it to make sure it looks correct in the case
      translate([-2, 3, 0]) {
        // Display mount points
        for(i = [-1 : 2 : 1])
        for(j = [-1 : 2 : 1]) {
          translate([i * 157 / 2, j * 114.8 / 2, 0])
            cylinder(d = 10.5, h = case_height + 5, $fn = 120);
        }

        // Bezel mount points
        for(i = [-1 : 2 : 1])
        for(j = [-1 : 2 : 1]) {
          translate([i * 125 / 2, j * 115.5 / 2, 0])
            cylinder(d = 10.5, h = case_height + 5.2, $fn = 120);
        }
      }

      // Structural supports
      union() {
        // Bottom perimeter
        translate([-164 / 2, 132 / 2 - 5 * 0.4, 0])
          cube([164, wall_t, 3 + 4]);

        // Top perimeter
        translate([-164 / 2, -132 / 2, 0])
          cube([149, wall_t, 3 + 4]);

        translate([69, -132 / 2, 0])
          cube([13, wall_t, 3 + 4]);

        // Right perimeter
        translate([-85 - wall_t, 1, 0])
          cube([wall_t, 60, 3 + 4]);

        difference() {
          translate([-85 - wall_t, -132 / 2 + 5, 0])
            cube([wall_t, 10.7, 3 + 4]);

          translate([-85, -132 / 2 + 20.2, 8])
          rotate([45, 0, 0])
            translate([-10 / 2, -10 / 2, 0])
            cube([10, 10, 10]);
        }

        // Left perimeter
        translate([85, -132 / 2 + 20, 0])
          cube([wall_t, 107, 3 + 4]);

        translate([85, -132 / 2 + 5, 0])
          cube([wall_t, 13, 3 + 4]);

        // Corners
        for(i = [0 : 1])
        for(j = [0 : 1]) {
          mirror([i, 0, 0])
          mirror([0, j, 0])
          translate([-174 / 2 + 5, 132 / 2 - 5, 0])
          difference() {
            cylinder(d = 10, h = 3 + 4, $fn = 200);

            translate([0, 0, -0.1])
              cylinder(d = 10 - 2 * wall_t, h = 10, $fn = 120);

           translate([0, -10 / 2 - wall_t, -0.1])
              cube([20, 10, 10]);

           translate([-10 / 2 + wall_t, -20, -0.1])
              cube([10, 20, 10]);
          }
        }
      }
    }

    // Mount holes
    translate([-2, 3, 0]) {
      // Display mount holes and hex nut seats
      for(i = [-1 : 2 : 1])
      for(j = [-1 : 2 : 1]) {
        translate([i * 157 / 2, j * 114.8 / 2, -0.1]) {
          cylinder(d = 3.4, h = 15, $fn = 90);

          rotate([0, 0, 0]) {
            cylinder(d = hex_dia_M3, h = 2, $fn = 6);

            translate([0, 0, 2 - 0.001])
              cylinder(d1 = hex_dia_M3, d2 = 2.8, h = 2.2, $fn = 6);
          }
        }
      }

      // Bezel mount holes and countersinks
      for(i = [-1 : 2 : 1])
      for(j = [-1 : 2 : 1]) {
        translate([i * 125 / 2, j * 115.5 / 2, -0.1]) {
          cylinder(d = 3.4, h = 15, $fn = 90);

          cylinder(d = 6.2, h = 2.0, $fn = 60);

          translate([0, 0, 2.0 - 0.001])
            cylinder(d1 = 6.2, d2 = 2.8, h = 2.2, $fn = 60);
        }
      }
    }

    // Angle bracket mount holes and countersinks
    rotate([0, 0, 180])
    translate([0, -5, 0]) {
      for(i = [-1 : 2 : 1])
      for(j = [-1 : 2 : 1]) {
        translate([i * 118.0 / 2, j * 80.0 / 2, -0.1]) {
          cylinder(d = 3.4, h = 15, $fn = 80);

          translate([0, 0, (case_height - 1.2) + 0.1])
            cylinder(d = 6.2, h = case_height, $fn = 120);
        }
      }
    }

    // Jetson Xavier/Orin mount holes and countersinks (for standoffs)
    rotate([0, 0, 180])
    translate([3, 29 + 3, 0]) {
      translate([0, 0, 2.7 - 1.2])
        hex_nut_seats(86.0, 58.0, hex_dia_M2_5, 2, 0, -1);
        rectangular_hole_pattern(86.0, 58.0, 2.7, -0.1, 15);
    }

    // HDMI connector clearance
    translate([-157 / 2 - 3, -114.8 / 2 + 4, case_height - 2.6 + 0.8])
    translate([-7, 10.5 / 2 + 1, 0])
      cube([21.5, 17, 4]);

    // Cutout for backlight switch
    translate([-174 / 2 + 5.5, -132 / 2 + 67, -0.1]) {
      translate([5 / 2, 5 / 2, 0])
        cylinder(d = 5, h = case_height + 1, $fn = 80);

      translate([0, 5 / 2, 0])
        cube([5, 5, case_height + 1]);

      translate([5 / 2, 10 - 5 / 2, 0])
        cylinder(d = 5, h = case_height + 1, $fn = 80);
    }

    // Corner fillets
    for(i = [0 : 1]) {
      for(j = [0 : 1]) {
        mirror([0, i, 0]) mirror([j, 0, 0])
        translate([-174 / 2 + 5, -132 / 2 + 5, -0.1])
          corner_fillet(10, 5);
      }
    }

    // Perimeter chamfers
    union() {
      // Left side
      translate([85, -132 / 2 + 22.5, 8])
      rotate([45, 0, 0])
      translate([-10 / 2, -10 / 2, 0])
        cube([10, 10, 10]);

      // Right side
      translate([-85, -132 / 2 + 69.5, 8])
      rotate([45, 0, 0])
      translate([-10 / 2, -10 / 2, 0])
        cube([10, 10, 10]);

      // Top side
      translate([64.5, -132 / 2, 8])
      rotate([0, 45, 0])
      translate([-10 / 2, -10 / 2, 0])
        cube([10, 10, 10]);
    }

    // Cutout for display clearance
    translate([-140 / 2, -108 / 2 + 3, 7])
      cube([140, 108, 5]);

    // Cutouts for WiFi antenna cables
    translate([136 / 2, -132 / 2 + 0.5, -1]) {
      cylinder(d = 2, h = 5, $fn = 50);

      translate([-2 / 2, -2, 0])
        cube([2, 2, 5]);
    }

    translate([174 / 2 - 0.5, -(132 - (174 - 136)) / 2, -1]) {
      cylinder(d = 2, h = 5, $fn = 50);

      translate([0, -2 / 2, 0])
        cube([2, 2, 5]);
    }


    // Vent slots - left side
    for(i = [0 : 3]) {
      translate([174 / 2 - 10, -132 / 2 + 30 + i * 23, -1]) {
        cylinder(d = 6, h = 5, $fn = 80);

        translate([0, 7, 0])
          cylinder(d = 6, h = 5, $fn = 80);
                
        translate([-6 / 2, 0, 0])
          cube([6, 7, 5]);
      }
    }

    // Vent slots - right side
    for(i = [0 : 1]) {
      translate([-174 / 2 + 10, -132 / 2 + 46 + i * 44, -1]) {
        cylinder(d = 6, h = 5, $fn = 80);

        translate([0, 7, 0])
          cylinder(d = 6, h = 5, $fn = 80);
                
        translate([-6 / 2, 0, 0])
          cube([6, 7, 5]);
      }
    }

    // Vent slots - top
    for(i = [0 : 2]) {
      translate([-31.5 + 25 * i, -59, -1]) {
        cylinder(d = 6, h = 5, $fn = 80);

        translate([7, 0, 0])
          cylinder(d = 6, h = 5, $fn = 80);
                
        translate([0, -6 / 2, 0])
          cube([7, 6, 5]);
      }
    }

    // Vent slots - bottom
    for(i = [0 : 3]) {
      translate([-43.5 + 25 * i, 59, -1]) {
        cylinder(d = 6, h = 5, $fn = 80);

        translate([7, 0, 0])
          cylinder(d = 6, h = 5, $fn = 80);
                
        translate([0, -6 / 2, 0])
          cube([7, 6, 5]);
      }
    }

    // Cutouts to save filament and reduce distortion
    hole_dia = 32;
    x_spacing = 36;
    y_spacing = 36;
    x_offset = -18;
    y_offset = -73.5 + 10;

    for(j = [1 : 3]) {
    for(i = [0 : 1 + (j % 2)])
      translate([x_spacing * i + x_offset - (j % 2) * x_spacing / 2,
                             j * y_spacing * sqrt(3) / 2 + y_offset, 0.8])
      rotate([0, 0, 30])
        cylinder(d = hole_dia, h = 5, $fn = 6);
    }
  }
}

// Mount points to connect the bezel to the display base
module display_bezel_mount_points(bezel_height) {
  translate([-2, 3, 8]) {
    difference() {
      // Standoffs
      union() {
        for(i = [-1 : 2 : 1])
        for(j = [-1 : 2 : 1]) {
          translate([i * 125 / 2, j * 115.5 / 2, 0])
            cylinder(d = 10.5, h = bezel_height, $fn = 120);
        }

        for(i = [-1 : 2 : 1]) {
          for(j = [0 : 1]) {
            mirror([0, j, 0])
            translate([i * 125.0 / 2, -115.5 / 2, 0])
            translate([-12 / 2, -12 / 2, 3.5])
              cube([12, 12, 8]);
          }
        }
      }

      // Hex nut slots
      for(i = [-1 : 2 : 1]) {
        for(j = [0 : 1]) {
          mirror([0, j, 0])
          translate([i * 125.0 / 2, -115.5 / 2, 0]) {
            // Hex nut slot
            translate([-5.8 / 2, 0, 5.2 + 0.1])
              cube([5.8, 10, 2.6]);

            // Cutout for printability
            translate([-15 / 2, 3.8, -0.1])
              cube([15, 5, 20]);
          }
        }
      }

      // M3 mounting holes
      for(i = [-1 : 2 : 1])
      for(j = [-1 : 2 : 1]) {
        translate([i * 125 / 2, j * 115.5 / 2, -0.1])
          cylinder(d = 3.2, h = 15, $fn = 60);
      }

      for(i = [-1 : 2 : 1]) {
        translate([0, i * 115.5 / 2, -0.1])
          cylinder(d = 3.2, h = 15, $fn = 3.2 * 12);
      }

      // Hex nut cutouts
      mirror([0, 0, 1])
      translate([0, 0, -7.8])
      difference() {
        for(i = [-1 : 2 : 1])
        for(j = [-1 : 2 : 1]) {
          translate([i * 125 / 2, j * 115.5 / 2, -0.1])
          rotate([0, 0, 30]) {
            cylinder(d = hex_dia_M3, h = 2.6, $fn = 6);

            translate([0, 0, 2.6 - 0.001])
              cylinder(d1 = hex_dia_M3, d2 = 2.8, h = 2.2, $fn = 6);
          }
        }

        // Cutouts for better bridging
        for(i = [-1 : 2 : 1])
        for(j = [0 : 1]) {
          mirror([0, j, 0])
          translate([i * 125.0 / 2, -115.5 / 2, 0])
          translate([-15 / 2, 2, -0.1])
            cube([15, 3, 10]);
        }
      }
    }
  }
}

// Bezel interior cutout
module display_bezel_inner_cutout(bezel_height, wall_thickness, miter_angle) {
  difference() {
    difference() {
      translate([-174 / 2 - 1 / 2, -132 / 2 - 1 / 2, -0.1])
        cube([174 + 1, 132 + 1, bezel_height - 2]);

      // Top and bottom miters
      for(i = [0 : 1]) {
        mirror([0, i, 0])
        translate([-174 / 2 - 5, -132 / 2 - 2, 21 - wall_thickness * tan(miter_angle)])
        rotate([miter_angle, 0, 0])
        translate([0, -50 / 2, -10 / 2])
          cube([176 + 10, 50, 10]);
      }

      // Corner fillets
      for(i = [0 : 1]) {
        for(j = [0 : 1]) {
          mirror([0, i, 0])
          mirror([j, 0, 0]) 
          translate([-174 / 2 - 1 / 2 + 5, -132 / 2 - 1 / 2 + 5, -0.1])
            corner_fillet(10, bezel_height);
        }
      }
    }

    // Bezel mount points
    display_bezel_mount_points(bezel_height);

    // Top supports, including dovetail pushouts
    for(i = [-1 : 2 : 1]) {
      translate([-2.4 / 2 - 2 + i * 62.5, -132 / 2 - 5, 8])
        cube([2.4, 11.5, 10]);
    }

    // Center
    translate([-2.4 / 2 - 10, -132 / 2 - 5, 14]) {
      difference() {
        cube([2.4, 11.5 + 6, 9]);

        translate([0, 11.5 + 4.5, 0])
        rotate([45, 0, 0])
        translate([-4 / 2 + 2.4 / 2, -8 / 2, -4 / 2])
          cube([4, 8, 4]);
      }
    }

    // Bottom supports
    for(i = [-1 : 2 : 1]) {
      translate([-2.4 / 2 - 2 + i * 62.5, 132 / 2 - 1, 8])
        cube([2.4, 11.5, 10]);
    }

    // Center
    translate([-2.4 / 2, 132 / 2 - 10, 14]) {
      difference() {
        cube([2.4, 11.5, 9]);

        translate([0, 1.5, 0])
        rotate([-45, 0, 0])
        translate([-4 / 2 + 2.4 / 2, -8 / 2, -4 / 2])
          cube([4, 8, 4]);     
      }
    }
  }
}

// Display bezel
module display_bezel(logo = 1) {
  bezel_height = 20;
  wall_thickness = 0.4 * 4;
  bezel_orientation = 1;
  miter_angle = 50;

  difference() {
    union() {
      translate([-174 / 2 - wall_thickness - 1 / 2,
                 -132 / 2 - wall_thickness - 1 / 2, 0])
        cube([174 + 2 * wall_thickness + 1,
              132 + 2 * wall_thickness + 1, bezel_height]);
    }

    // Top and bottom miters
    for(i = [0 : 1]) {
      mirror([0, i, 0])
      translate([-174 / 2 - 5, -132 / 2 - 2, 21])
      rotate([miter_angle, 0, 0])
        translate([0, -50 / 2, -10 / 2])
          cube([176 + 10, 50, 10]);
    }

    // Outside corner fillets
    for(i = [0 : 1]) {
      for(j = [0 : 1]) {
        mirror([0, i, 0]) mirror([j, 0, 0]) 
        translate([-174 / 2 - wall_thickness - 1 / 2 + 6.5,
                   -132 / 2 - wall_thickness - 1 / 2 + 6.5, -0.1])
          corner_fillet(13, 25);
      }
    }

    // Display cutout
    translate([-(157 + 2) / 2 - 1, -(90 + 2) / 2 - 1, -0.1])
      cube([157 + 4, 90 + 5, bezel_height + 1]);

    // Interior cutouts        
    display_bezel_inner_cutout(bezel_height, wall_thickness, miter_angle);

    // HDMI and USB cutouts
    translate([-157 / 2 - 3, -114.8 / 2 + 3, -0.1])
    translate([-16, 10.5 / 2 - 1, 0])
    difference() {
      cube([15, 51, 12]);
            
      // Chamfers
      translate([0, 0, 12])
      rotate([45, 0, 0])
        translate([0, -5, -3 / 2])
          cube([20, 10, 4]);

        translate([0, 51, 12])
        rotate([-45, 0, 0])
          translate([0, -5, -3 / 2])
            cube([20, 10, 4]);
    }

    if(logo == 1) {
      rotate([0, 0, 180]) {
      translate([-158 / 2 + 10, 90 / 2 + 8.5, bezel_height])
      translate([-14, -2.2, -0.6])
        linear_extrude(height = 2) {
          text("RTAB-Map", font = "Liberation Sans:style=Bold Italic", size = 8.5);
        }
      }
    }
  }
}

// Mount plate that connects the handle, front scanner assembly, and display
module mount_plate() {
  difference() {
    union() {
      // Back plate section
      translate([-128 / 2, -68.5 / 2 + 2.5 + 10, 0])
        cube([128, 77.75, 3]);

      // Front plate section
      translate([-100 / 2, 36, 0])
        cube([100, 75 - 0.1, 3]);

      // Chamfer for step
      for(i = [-1 : 2 : 1]) {
        translate([i * 100 / 2, 56, 0])
        rotate([0, 0, 45])
          translate([-(14 * sqrt(2)) / 2, -(14 * sqrt(2)) / 2, 0])
          cube([14 * sqrt(2), 14 * sqrt(2), 3]);
      }

      // Reinforcement for handle
      translate([-54 / 2, -60 / 2 + 20 + 3, -2])
        cube([54, 60, 3]);

      // Plate stiffening
      for(i = [0 : 1]) {
        mirror([i, 0, 0]) {
          translate([100 / 2 - 2, -21.75, -4])
            cube([2, 124.75 + 8 - 0.1, 3 + 4]);

          translate([100 / 2 - 2.0 - 22, -21.75, -4])
            cube([2, 124.75 + 8 - 0.1, 3 + 4]);

          translate([-128 / 2, -21.75, -4])
            cube([2, 77.75, 3 + 4]);
        }
      }

      // Front corner
      for(i = [-1 : 2 : 1]) {
        translate([i * (100 / 2 - 2), 110 - 1, -0.1])
        rotate([0, 0, 45])
          translate([-2 / 2, -2 / 2, -4 + 0.1])
          cube([2, 2, 6]);
      }

      // Rear stiffener
      translate([-128 / 2, -21.75, -4])
        cube([128, 2, 3 + 4]);

      // Front stiffener
      translate([-100 / 2, 101 + 8 - 0.1, -4])
        cube([100, 2, 3 + 4]);

      // Angle stiffener (back)
      for(i = [0 : 1]) {
        mirror([i, 0, 0])
        translate([-100 / 2 + 2.0 + 22, -21.75 + 10 + 1.75, -4])
        rotate([0, 0, 180 - 45])
          cube([2, 16.5, 3 + 4]);
      }

      translate([-52 / 2 - 1, -10, -4])
        cube([54, 2, 3 + 4]);

      // Angle stiffener (front)
      for(i = [-1 : 2 : 1]) {
        translate([i * 100 / 2, 56, 0])
        mirror([(i - 1)/2, 0, 0])
        rotate([0, 0, 45])
          translate([(14 * sqrt(2)) / 2 - 2, -(14 * sqrt(2)) / 2, -4])
          cube([2, 14 * sqrt(2), 3 + 4]);
      }

      translate([-100 / 2, 58 + (14 * sqrt(2)) / 2, -4])
        cube([100, 2, 3 + 4]);
    }

    // 4mm hole for retention pin
    translate([0, 105 - 10 + 8, -4]) {
      cylinder(d = 4.8, h = 10, $fn = 60);

      // 1/4-20 mounting hole and clearance
      translate([0, -13.5, 0])
        cylinder(d = 6.4, h = 10, $fn = 100);
    }

    // Mount holes for Zed 2
    translate([0, 105 - 10 + 8 - 13.5 + 6.5, -4]) {
      for(i = [-1 : 2 : 1])
        translate([i * 18.4, 0, 0])
        cylinder(d = 3.4, h = 10, $fn = 60);
    }

    // Mount holes for Realsense camera block
    translate([0, 105 - 10 + 8 - 13.5 + 6.5, -4]) {
      for(i = [-1 : 2 : 1])
        translate([i * 35, 0, 0])
          cylinder(d = 3.4, h = 10, $fn = 60);
    }

    // Mount holes for angle brackets
    translate([0, 17.5 - 5, 0]) {
      rectangular_hole_pattern(117.0, 56.0, 3.4, -0.1, 15);
      rectangular_hole_pattern(117.0, 56.0, 6.2, -0.1, 1.6);
    }

    // Mount holes for handle
    translate([0, 22 + 3, 0]) {
      mirror([0, 0, 1])
      translate([0, -1.8, -3]) {
        rectangular_hole_pattern(35.0, 45.0, 3.4, -0.1, 15);
        hex_nut_seats(35.0, 45.0, hex_dia_M3, 2.6, 0, 1.6);

        // Trigger feedthrough from handle
        translate([0, 0, -0.1])
          cylinder(d = 10, h = 10, $fn = 100);
      }
    }

    // Chamfer front corners
    for(i = [-1 : 2 : 1]) {
      translate([i * (100 / 2 + 2.5), 110 + 3, -0.1])
      rotate([0, 0, 45])
        translate([-10 / 2, -10 / 2, -5])
        cube([10, 10, 10]);
    }

    // Slots for Kinect mount bracket
    for(i = [0 : 1]) {
      mirror([i, 0, 0])
      translate([-100 / 2 + 16, -21.75 + 22, -1]) {
        cube([3.2, 28, 10]);

        translate([3.2 / 2, 0, 0])
          cylinder(d = 3.2, h = 10, $fn = 50);

        translate([3.2 / 2, 28, 0])
          cylinder(d = 3.2, h = 10, $fn = 50);
      }
    }

    // Jetson connector clearance, for cables
    translate([-52 / 2, -40, -5])
      cube([52, 30, 10]);

    // Rear chamfers
    for(i = [0 : 1]) {
      mirror([i, 0, 0])
      translate([-52 / 2, -10 - 20 / sqrt(2), -5])
      rotate([0, 0, 45])
        translate([-20 / 2, -20 / 2, 0])
        cube([20, 20, 10]);
    }
  }
}

// Angle mounts between the display body and the mount plate
module angle_bracket(RH_side = true, LH_style = 0) {
  bracket_angle = 55;

  x0 = 0;                            // Outer edge 1
  x1 = 0;                            // Inner edge 1
  x2 = -2.4 - 13.6 - 4;              // Inner edge 2
  x3 = x2 - 78 * sin(bracket_angle); // Outer edge 2

  y0 =  120 / 2 - 12 / 2 - 1;        // Outer edge 1
  y1 = -120 / 2 + 24 - 2.4;          // Inner edge 1
  y2 = y1;                           // Inner edge 2
  y3 = y2 + 78 * cos(bracket_angle); // Outer edge 2

    side_bar_angle = -90 - atan((y3 - y0)/(x3 - x0));

  // Mount holes are 80mm apart
  difference() {
    union() {
      // Top bar
      translate([-12 / 2, -120 / 2, 0])
      difference() {
        cube([12, 120 - 8.8, 2.4]);

        // Miter the front edge
        translate([12, 120 - 4, -5])
        rotate([0, 0, 45])
          translate([-10 / 2 - 1.48, -12 / 2 - 3, 0])
          cube([10, 12, 10]);
      }

      // Front bar
      translate([-12 / 2, -120 / 2 + 15.5, -13.6 - 4])
        cube([12, 2.4, 16 + 4]);
            
      // Bottom bar
      translate([-12 / 2, -40.5 - 4.2, -12 - 5.5]) {
        rotate([-bracket_angle, 0, 0])
        difference() {
          cube([12, 82.55, 2.4]);

          // Miter the front edge to match mount plate
          translate([12, 85.25, -5])
          rotate([0, 0, 45])
            translate([-10 / 2, -12 / 2 - 2, 0])
            cube([10, 12, 10]);
                    
            // Mount holes and hex nut seats
            mirror([0, 0, 1])
            for(i = [-1 : 2 : 1]) {
              translate([12 / 2 + 0.5, 58 / sqrt(2) - 2 - 4.3 + i * 28, -2.4 - 0.4]) {
                cylinder(d = 3.2, h = 5, $fn = 50);
                cylinder(d = 5.8 / (sqrt(3) / 2), h = 1.6, $fn = 6);
              }
            }
          }
        }
      }

      // Top bar hex nut seats
      for(i = [-1 : 2 : 1]) {
        translate([1, i * 80 / 2 + 4, -0.4]) {
          cylinder(d = 3.2, h = 5, $fn = 50);
          cylinder(d = 5.8 / (sqrt(3) / 2), h = 1.6, $fn = 6);
        }
      }

      // Trim the edge
      translate([-15 / 2, -120 / 2 - 4.5, -30])
        cube([15, 20, 40]);
    }

    // Side bar
    difference() {
      translate([0, 120 / 2 - 12.5, 2.4])
      rotate([side_bar_angle, 0, 0]) {
        translate([-12 / 2, 1, -0.2])
          cube([2.4, 97 - 2, 4 + 0.2]);

        translate([-12 / 2, 0, 2])
          cube([7.63, 97, 2.4]);
      }

      // Trim the edges
      translate([-12 / 2 - 1, 120 / 2 - 8.8, 0])
        cube([14, 10, 10]);

      translate([-12 / 2 - 1, -40.5 - 4.2, -12 - 5.5])
      rotate([-bracket_angle, 0, 0])
        translate([0, 120 / 2 + 24 - 1.45, 0])
          cube([14, 10, 10]);
    }

    translate([-6 + 2.4, -4, 2.4])
    rotate([0, -90, 0]) {
      difference() {
        linear_extrude(height = 2.4) {
          polygon(points = [[x0, y0], [x1, y1], [x2, y2], [x3, y3]],
                  paths = [[0, 1, 2, 3]]);
        }

        // Cutouts to minimize distortion and save print time
        // Different versions for each side, just in case we want that
        if(RH_side == false) {
          if(LH_style == 0) {
            hull() {
              // Top circle
              translate([-14, 28, -1])
                cylinder(d = 10, h = 5, $fn = 140);

              // Bottom circle
              translate([-14, -26, -1])
                cylinder(d = 10, h = 5, $fn = 140);

              // Side circle
              translate([14 - 13.6 - 70 * sin(bracket_angle),
                     -120 / 2 + 24 + 70 * cos(bracket_angle), -1])
                cylinder(d = 10, h = 5, $fn = 140);
            }

            // Mount points for zipties
            translate([-60, 14, -1])
              cylinder(d = 3.2, h = 5, $fn = 40);

            translate([-9, 41, -1])
              cylinder(d = 3.2, h = 5, $fn = 40);

            translate([-27, -28, -1])
              cylinder(d = 3.2, h = 5, $fn = 40);

            translate([-53, -10, -1])
              cylinder(d = 3.2, h = 5, $fn = 40);
          }
        }
        else {
          difference() {
            hull() {
              // Top circle
              translate([-14, 28, -1])
                cylinder(d = 10, h = 5, $fn = 140);

              // Bottom circle
              translate([-14, -26, -1])
                cylinder(d = 10, h = 5, $fn = 140);

              // Side circle
              translate([14 - 13.6 - 70 * sin(bracket_angle),
                     -120 / 2 + 24 + 70 * cos(bracket_angle), -1])
                cylinder(d = 10, h = 5, $fn = 140);
            }

            // Pushouts for voltage regulator mount points
            translate([-8, -5, -1])
            rotate([0, 0, 90]) {
              cylinder(d = 3.2 + 12 * 0.4, h = 10, $fn = 80);

              translate([34.5, 18, 0])
                cylinder(d = 3.2 + 12 * 0.4, h = 10, $fn = 60);
            }
          }

          // Mount points for zipties
          translate([-60, 14, -1])
            cylinder(d = 3.2, h = 5, $fn = 40);

          translate([-27, -28, -1])
            cylinder(d = 3.2, h = 5, $fn = 40);

          translate([-53, -10, -1])
            cylinder(d = 3.2, h = 5, $fn = 40);

          // Mount holes for voltage regulator
          translate([-8, -5, -1])
          rotate([0, 0, 90]) {
            cylinder(d = 3.2, h = 10, $fn = 60);
        
            translate([34.5, 18, 0])
              cylinder(d = 3.2, h = 10, $fn = 60);
        }
      }
    }
  }
}


// -----------------------------------------------------------------------------------------
//

/*
Ergonomic handle
by Alex Matulich
Verson 5.1, May 2022

On Thingiverse: https://www.thingiverse.com/thing:5330170
On Printables: https://www.printables.com/model/154837
*/

metacarpal_expansion = 1.12;
fwd_flair = true;
groovedepth = 0.6;
bottomcapscale = 0.95;

// Handle curve coefficients

// coefficents for default handle based on all test subjects
ehandle_coeff_default = [
    // curve E (forward profile)
    [ 0.10820685778527288,
      7.8071566553000377e-002,
     -0.11713845806508627 ],
    // curve F (side profile)
    [ 8.9094997189434533e-002,
     -0.23994552971632244,
      1.0934064033888202,
     -1.5902142712055265,
      0.70892877695967604 ],
    // curve G (rear profile)
    [ 0.10820685778528655,
     -0.46856937731734472,
      1.9272376487779372,
     -2.9629722410641546,
      1.4995260044545953 ]
];

// coefficients for handle with forward profile flared at the ends
ehandle_coeff_fwdflair = [
    // curve E - assumes 12% metacarpal expansion
    [0.11246945332942532,
    -1.8795070341676573e-002,
     0.36187545606899507,
    -0.83803954628607691,
     0.46058029602811634, 0.01, 0.05 ],
     // curve F
     ehandle_coeff_default[1],
     // curve G
     ehandle_coeff_default[2]
];

// ---------- modules ----------

// render the handle
module ergonomic_handle(
  hand_length = default_hand_length(),
  hand_width = default_hand_width(),
  flair = fwd_flair,
  bottomcapext = 0,
  topext = 0,
  groovespc = 0,
  fingergroove = false,
  tiltangle = 110,
  fn = 64,
  halfrotate = false) {
    ehdcoeff = flair ? ehandle_coeff_fwdflair : ehandle_coeff_default;
    ecof = hand_length * ehdcoeff[0];   // scaled front profile coefficients
    fcof = hand_length * ehdcoeff[1];   // scaled side profile coefficients
    gcof = hand_length * ehdcoeff[2];   // scaled rear profile coefficients
    ehlen = ergonomic_handle_height(hand_width); // length of handle
    bcapext = bottomcapext / ehlen;   // unit-scaled end cap extension
    t_ext = topext / ehlen;           // unit-scaled top extension
    tfwx = fingergroove ? trochoid(0, ehlen) : 0;
    bfwx = fingergroove ? trochoid(ehlen, ehlen) : 0;
    vfn = fingergroove ? 128 : fn;

    // Stack of ellipse cross sections
    estack = [
      // top extension, if any
      if(topext > 0)
        for(z = [-t_ext : 0.16 / fn : -0.01 / ehlen])
          let(xmin = polynomial(gcof, z),
              xmax = polynomial(ecof, z),
              ymax = polynomial(fcof, z))
                elev_ellipse(xmin, xmax, ymax, z * ehlen, tiltangle, fn, tfwx, halfrotate),

      // main body of handle
      for(i = [0 : vfn])
        let(z = i / vfn,
            fwx = fingergroove ? trochoid(z * ehlen, ehlen) : 0,
            xmin = polynomial(gcof, z),
            xmax = polynomial(ecof, z),
            ymax = polynomial(fcof, z))
              elev_ellipse(xmin, xmax, ymax, z * ehlen, tiltangle, fn, fwx, halfrotate),

      // bottom cap, if any
      if(bottomcapext > 0)
        for(z = [1 + 0.5 / ehlen : 0.4 / ehlen : 1 + bcapext - 0.01 / ehlen])
          let(scl = bottomcapscale + (1 - bottomcapscale) * cos(90 * (z - 1) / bcapext),
              xmin = scl * polynomial(gcof, z),
              xmax = scl * polynomial(ecof, z),
              ymax = scl * polynomial(fcof, z))
                elev_ellipse(xmin, xmax, ymax, z * ehlen, tiltangle, fn, bfwx, halfrotate),

      // last ellipse of bottom cap
      if(bottomcapext > 0)
        let(z = 1 + bcapext,
            scl = bottomcapscale,
            xmin = scl * polynomial(gcof, z),
            xmax = scl * polynomial(ecof, z),
            ymax = scl * polynomial(fcof, z))
              elev_ellipse(xmin, xmax, ymax, z * ehlen, tiltangle, fn, bfwx, halfrotate)
    ];

    // render the object right-side-up
    rotate([0, 180, 0])
    difference() {
      polyhedron_stack(estack);

      if(groovespc > 0 && !fingergroove)
        for(h = [1.5 * groovespc : groovespc : ehlen-groovespc])
          groove_ellipse(h);
    }

    module groovecutter() {
      polygon(points = [ [-groovedepth, 0],
                         [4 - groovedepth, 4],
                         [4 - groovedepth, -4] ] );
    }

    module groove_ellipse(ht) {
      let(z = ht / ehlen,
          xmin = polynomial(gcof, z),
          xmax = polynomial(ecof, z),
          ymax = polynomial(fcof, z),
          semimajoraxis = 0.5 * (xmax + xmin))
          multmatrix(m = [
                [1, 0, cos(tiltangle), semimajoraxis - xmin + ht * cos(tiltangle) ],
                [0, ymax / semimajoraxis, 0, 0],
                [0, 0, 1, ht],
                [0, 0, 0, 1] ] )
      rotate([0, 0, 180])
      rotate_extrude(angle = 360, $fn = fn, convexity = 4)
      translate([semimajoraxis, 0, 0])
        groovecutter();
    }
}

// Build a polyhedron object from a stack of polygons. It is assumed that each polygon has
// [x,y,z] coordinates as its vertices, and the ordering of vertices follows the
// right-hand-rule with respect to the direction of propagation of each successive polygon.
module polyhedron_stack(stack) {
  nz = len(stack); // number of z layers
  np = len(stack[0]); // number of polygon vertices

  facets = [[ for(j = [0 : np - 1]) j ], // close first opening
            for(i = [0 : nz - 2])
            for(j = [0 : np - 1])
              let(k1 = i * np + j,
                  k4 = i * np + ((j + 1) % np),
                  k2 = k1 + np,
                  k3 = k4 + np)
                   [k1, k2, k3, k4],
                   [ for(j = [np * nz - 1 : -1 : np * nz - np]) j ],];
  polyhedron(flatten(stack), facets, convexity = 2);
}

// return polygon of top ellipse (including extension)

module ergonomic_handle_top_ellipse(
  hand_length = default_hand_length(),
  hand_width = default_hand_width(),
  flair = fwd_flair,
  fingergroove = true,
  topext = 0,
  tiltangle = 110,
  fn = 64,
  halfrotate = false) {
    coeff = hand_length * (flair ? ehandle_coeff_fwdflair : ehandle_coeff_default);
    top = -topext / ergonomic_handle_height(hand_width);
    tfwx = fingergroove ? trochoid(0, ergonomic_handle_height(hand_width)) : 0;
    p3d = elev_ellipse(polynomial(coeff[2], top),
                       polynomial(coeff[0], top),
                       polynomial(coeff[1], top), -topext, tiltangle, fn, tfwx, halfrotate);
    p2d = [ for(a = p3d) [ -a[0], a[1] ] ];
    polygon(points = p2d);
}

// return polygon of bottom ellipse (EXCLUDING bottom cap extension)

module ergonomic_handle_bottom_ellipse(
  hand_length = default_hand_length(),
  hand_width = default_hand_width(),
  flair = fwd_flair,
  fingergroove = true,
  tiltangle = 110,
  fn = 64,
  halfrotate = false) {
    coeff = hand_length * (flair ? ehandle_coeff_fwdflair : ehandle_coeff_default);
    ehlen = ergonomic_handle_height(hand_width);
    bfwx = fingergroove ? trochoid(ehlen, ehlen) : 0;
    p3d = elev_ellipse(polynomial(coeff[2], 1),
                       polynomial(coeff[0], 1),
                       polynomial(coeff[1], 1),
                       ergonomic_handle_height(hand_width), tiltangle, fn, bfwx, halfrotate);
    p2d = [ for(a = p3d) [ -a[0], a[1] ] ];
    polygon(points = p2d);
}

// ---------- functions ----------

// default gender-based hand dimensions

function default_hand_length(female = false) = female ? 171 : 186;
function default_hand_width(female = false) = female ? 76 : 85;

// height of handle without extensions

function ergonomic_handle_height(hand_width = default_hand_width()) =
  hand_width * metacarpal_expansion;

// polynomial evaluation at x, given any number of coefficents c[0]...c[degree]
// usage: y = polynomial(coefficients, x);

function polynomial(cof, x, sum = 0, indx = undef) =
  let(i = indx==undef ? len(cof) - 1 : indx)
      i == 0 ? cof[0] + sum : polynomial(cof, x, x * (sum + cof[i]), i - 1);

// elliptical cross section of handle at elevation z

function elev_ellipse(xmin, xmax, ymax, z, tiltangle, fn=64, fwd_ext=0, halfrotate=false) =
  let(
    semimajor = 0.5 * (xmax + xmin),
    fwd_semimajor = semimajor + fwd_ext,
    yscl = ymax / semimajor,
    hr = halfrotate ? 0 : 180 / fn,
    xoff = z * cos(tiltangle) + xmax - semimajor ) [
      for(a = [-90 + hr : 360 / fn : 89.9])
        [ fwd_semimajor * cos(a) + xoff, yscl * semimajor * sin(a), z ],
      for(a = [90 + hr : 360 / fn : 269.9])
        [ semimajor * cos(a) + xoff, yscl * semimajor * sin(a), z ]        
    ];

// flatten an array of arrays

function flatten(l) = [ for (a = l) for (b = a) b ] ;

// trochoid finger groove functions

// finger width porportions from anthropometric data
thumbfrac = 0.231959853553746;      // thumb fraction of hand width
forefingerfrac = 0.200542328752527; // forefinger fraction of hand width
fingwidfrac = [ // thumb plus four fingers
    0.5 * (thumbfrac + forefingerfrac),
    0.5 * (thumbfrac + forefingerfrac), // split total width of thumb+forefinger
    0.201238475943949,  // middle finger
    0.193454805146993,  // ring finger
    0.172804536602786,  // pinky
    0.172804536602786   // copy pinky to avoid array index overrun in trochoid()
];

trochoid_amp = 0.65 - 0.1; // trochoid amplitude, must be between 0.5 and 0.9

// finger grooves are four trochoids of different sizes blended together end-to-end
function trochoid(z_elev, handwid) = let(
    fdata = getfingindex(max(0, z_elev), handwid),
    fi = fdata[0],
    width = fingwidfrac[fi] * handwid,
    nextwid = fingwidfrac[fi + 1] * handwid,
    r = width / (2*PI),
    b = trochoid_amp * r,
    nextb = trochoid_amp * nextwid / (2*PI),
    accumwid = fdata[1] * handwid,
    z = z_elev - accumwid,
    zfrac = z/width,
    theta = findtrochtheta(z, r, b, 2*PI * zfrac),
    thetadeg = fi==0 && theta<PI ? 180 : theta * 180/PI, // 5.1: remove top knuckle
    interpb = zfrac * (nextb - b) + b,
    y = interpb + interpb * cos(thetadeg))
      (1.1 * y + 0.2);

// for a give z elevation, return the corresponding finger index 0-4
function getfingindex(z, handwid, i=0, accumwid=0) =
  let(widfrac = accumwid + fingwidfrac[i],
      wid = widfrac * handwid)
        z <= wid || i==3 ? [i, accumwid] : getfingindex(z, handwid, i+1, widfrac);

// for a given z elevation, find the corresponding trochoid rotation angle - no closed-form
// solution for this, so using Newton-Raphson iterative method
function findtrochtheta(z, r, b, theta = PI, n = 0) =
  let(tdeg = theta * 180 / PI,
      newtheta = theta - (r * theta - b * sin(tdeg) - z) / (r - b * cos(tdeg)))
    abs(newtheta-theta) < 0.001 || n >= 8 ?
      newtheta : findtrochtheta(z, r, b, newtheta, n+1);


// -----------------------------------------------------------------------------------------


// The handle assembly
module scanner_handle(type = 0) {
  union() {
    // The base
    difference() {
      translate([-50 / 2, -60 / 2, 0])
        cube([50, 60, 3]);

      rectangular_hole_pattern(35.0, 45.0, 3.4, -0.1, 15);
      rectangular_hole_pattern(35.0, 45.0, 6.2, -0.1, 1.6);

      for(i = [0 : 1])
      for(j = [0 : 1]) {
        mirror([i, 0, 0])
        mirror([0, j, 0])
        translate([-50 / 2 - 2, -60 / 2 - 2, -1.4])
        rotate([0, 0, -45])

        rotate([45, 0, 0])
        cube([10, 10, 10], center = true);
      }
    }

    if(type == 0) {
      rotate([0, 0, -90])
      union() {
        ergonomic_handle(hand_length = 186,
                         hand_width = 85,
                         bottomcapext = 7,
                         fingergroove = false,
                         groovespc = 0,
                         flair = true,
                         fn = 64, halfrotate = true);

        ergonomic_handle(hand_length = 186,
                         hand_width = 85,
                         bottomcapext = 7,
                         fingergroove = false,
                         groovespc = 0,
                         flair = true,
                         fn = 64, halfrotate = false);
      }
    }

    if(type == 1) {
      translate([0, 0, -7.5])
      rotate([0, 0, -90])
      difference() {
        union() {
          ergonomic_handle(hand_length = 186,
                           hand_width = 82,
                           bottomcapext = 7,
                           topext = 8,
                           groovespc = 0,
                           fingergroove = true,
                           fn = 30,
                           halfrotate = false);

          ergonomic_handle(hand_length = 186,
                           hand_width = 82,
                           bottomcapext = 7,
                           topext = 8,
                           groovespc = 0,
                           fingergroove = true,
                           fn = 30,
                           halfrotate = true);
        }

        translate([-8, 0, 4])
        difference() {
          translate([30, 0, -115 - 10])
            cylinder(d = 300, h = 24 + 10, $fn = 100);

          translate([32, 0, -105 + 4])
          scale([1.4, 0.82, 1])
            cylinder(d = 30, h = 14, $fn = 100);
        }
      }
    }
  }
}

// Rear bracket for mounting the Kinect to the mount plate
module kinect_rear_mount_bracket() {
  difference() {
    union() {
      // Mount point for base plate
      translate([-95 / 2, -10, 0])
        cube([95, 10 + 3, 3]);

      // Mount points for Kinect
      for(i = [0 : 1]) {
        mirror([i, 0, 0]) {
          translate([-95 / 2, 0, 0])
            cube([18, 3, 20]);

          translate([-95 / 2 + 18, 0, 3])
          rotate([0, 45, 0])
            translate([-4 / 2, 0, -4 / 2])
            cube([4, 3, 4]);

          translate([-95 / 2, 3, 2])
          rotate([0, 90, 0])
          rotate([0, 0, 180])
          linear_extrude(height = 2.4) {
            polygon(points = [[0, 0], [12, 0], [0, 12]],
                    paths = [[0, 1, 2]]);
          }
        }
      }
    }

    // Mount holes for plate
    for(i = [0 : 1]) {
      mirror([i, 0, 0])
      translate([-95 / 2 + 15.1, -10 / 2, -5]) {
        cylinder(d = 3.4, h = 10, $fn = 60);

        translate([0, 0, 6.5])
        rotate([0, 0, 30])
          cylinder(d = 6.5, h = 3, $fn = 6);
      }
    }

    for(i = [-1 : 2 : 1])
    translate([i * 77 / 2, 5, 10]) {
      // Mount slots for Kinect - 77mm apart
      rotate([90, 0, 0]) {
        cylinder(d = 2.8, h = 8, $fn = 50);

        translate([0, 5, 0])
          cylinder(d = 2.8, h = 8, $fn = 50);

        translate([-2.8 / 2, 0, 0])
          cube([2.8, 5, 8]);
      }

      for(j = [0 : 1]) {
        mirror([j, 0, 0])
        translate([-18 / 2 - 2, -3, 12])
        rotate([0, 45, 0])
          translate([-10 / 2, -10 / 2, -10 / 2])
          cube([10, 10, 10]);
      }
    }
  }
}

// 40.5mm polarizing filter cap accessory for Kinect
module kinect_lens_cap(filter = true) {
  inner_h = 39.2;
  inner_w = 103.2;
  inner_r = 26;
  outer_r = 26 + 4 * 2 * 0.4;
  tab_h = 30;
  filter_d = 40.5;

  difference() {
    // Outer shell
    union() {
      hull() {
        for(i = [-1 : 2 : 1]) {
          for(j = [-1 : 2 : 1]) {
            translate([i * (inner_h / 2 - inner_r / 2),
                       j * (inner_w / 2 - inner_r / 2), 0])
              cylinder(d = outer_r, h = 16, $fn = 220);
          }
        }
      }

      // Support for filter
      if(filter == true) {
        translate([0, -(103 / 2) + 19.5, 0]) {
          cylinder(d = filter_d + 7.4, h = 5, $fn = 300);

          translate([0, 0, 5 - 0.001])
            cylinder(d1 = filter_d + 7.4,
                     d2 = filter_d, h = 5, $fn = 300);        
        }
      }
    }

    // Inner cutout
    translate([0, 0, 2])
    hull() {
      for(i = [-1 : 2 : 1]) {
        for(j = [-1 : 2 : 1]) {
          translate([i * (inner_h / 2 - inner_r / 2),
                     j * (inner_w / 2 - inner_r / 2), 0])
            cylinder(d = inner_r, h = 20, $fn = 160);
        }
      }
    }

    // Front window cutout
    translate([0, 0, -1])
    hull() {
      for(i = [-1 : 2 : 1]) {
        for(j = [-1 : 2 : 1]) {
          translate([i * (inner_h / 2 - inner_r / 2),
                     j * (inner_w / 2 - inner_r / 2), 0])
            cylinder(d = inner_r * 2 / 3, h = 20, $fn = 160);
        }
      }
    }

    // Filter cutout
    if(filter == true) {
      translate([0, -(103 / 2) + 19.5, -1])
        cylinder(d = filter_d, h = 4, $fn = 400);
    }
  }

  // Attachment clips
  for(i = [0 : 1]) {
    mirror([i, 0, 0])
    translate([-inner_h / 2 - 4 * 0.4, -10, 0]) {
      cube([4 * 0.4, 20, tab_h - 2]);

      translate([0, 0, tab_h])
      rotate([-90, 0, 0]) {
        linear_extrude(height = 20) {
          polygon(points = [[0, 0], [3, 0], [0, 5]],
                  paths = [[0, 1, 2]]);
        }
      }

      translate([0, 0, 16 - 6 * sqrt(2) / 2])
      rotate([45, 0, 0])
        cube([4 * 0.4, 6, 6]);

      translate([0, 20, 16 - 6 * sqrt(2) / 2])
      rotate([45, 0, 0])
        cube([4 * 0.4, 6, 6]);
    }
  }
}

// Mount for the Realsense D435 + T265 combo supported in RTAB-Map
module realsense_camera_bracket() {
  difference() {
    union() {
      // Mount back plate
      translate([-64.4 / 2, -50 / 2, 0])
        cube([64.4, 50, 5]);

      // Mount base
      translate([-100.4 / 2, -50 / 2, 0])
        cube([100.4, 17, 17.5]);

      translate([-100.4 / 2 + 10 / 2, -50 / 2 + 17, 0])
        cube([100.4 - 10, 5, 17.5]);

      for(i = [0 : 1]) {
        mirror([i, 0, 0])
        translate([-100.4 / 2, -50 / 2 + 13, 0])
        translate([0, 4, 0])
          linear_extrude(height = 17.5) {
            polygon(points = [[0, 0], [5, 5], [5, 0]],
                    paths = [[0, 1, 2]]);
          }
      }

      // The T265 is 12.5mm thick, compared to the D435 at
      // 25mm thick. So, we need to raise up the T265 seat
      // by 12.5mm
      translate([-60 / 2, -50 / 2, 0])
        cube([60, 25, 5 + 12.5]);
    }

    // The mount holes for the T265 are M3 x 0.5, spaced 50mm apart
    translate([-50 / 2, -25 / 2, -0.1])
      cylinder(d = 3.4, h = 30, $fn = 60);

    translate([50 / 2, -25 / 2, -0.1])
      cylinder(d = 3.4, h = 30, $fn = 60);

    // Countersinks
    translate([-50 / 2, -25 / 2, -0.1]) {
      cylinder(d = 6.5, h = 10, $fn = 90);

      translate([0, 0, 10 - 0.01])
        cylinder(d1 = 6.5, d2 = 3.4, h = 2, $fn = 90);
    }

    translate([50 / 2, -25 / 2, -0.1]) {
      cylinder(d = 6.5, h = 10, $fn = 90);

      translate([0, 0, 10 - 0.01])
        cylinder(d1 = 6.5, d2 = 3.4, h = 2, $fn = 90);
    }

    // The mount holes for the D435 are M3 x 0.5, spaced 45mm apart
    translate([-45 / 2, 25 / 2, -0.1])
      cylinder(d = 3.4, h = 20, $fn = 60);

    translate([45 / 2, 25 / 2, -0.1])
      cylinder(d = 3.4, h = 20, $fn = 60);

    // Clearance for top camera
    translate([-110 / 2, -3, 5])
      cube([110, 10, 25]);

    // Mount holes for the mount plate
    rotate([90, 0, 0]) {
      for(i = [-1 : 2 : 1]) {
        translate([i * 35, 16.5 / 2 + 4, 22.4 - 4]) {
          // Longer hole to make sure we have enough thread engagement
          translate([0, 0, -3])
            cylinder(d = 3.4, h = 16, $fn = 50);

          // M3 hex nut slots
          rotate([0, 0, 30])
            cylinder(d = 5.8 / (sqrt(3) / 2), h = 2.6, $fn = 6);

          translate([-5.8 / 2, -15, 0])
            cube([5.8, 15, 2.6]);
        }
      }

      translate([0, 16.5 / 2 - 2.5, 22.4 - 8]) {
        cylinder(d = 6.4, h = 20, $fn = 100);
      
        // 1/4-20 hex nut slot
        rotate([0, 0, 30])
          cylinder(d = 11.5 / (sqrt(3) / 2), h = 5.8, $fn = 6);

        translate([-11.5 / 2, -15, 0])
          cube([11.5, 15, 5.8]);
      }
    }

    // Top chamfers
    for(i = [0 : 1]) {
      mirror([i, 0, 0])
      mirror([0, 1, 0])
      translate([-64.4 / 2, -50 / 2, -1])
      rotate([0, 0, 45])
        translate([-1, -4, 0])
          cube([4, 8, 20]);
    }
  }
}

// -------------------------------------------------------------------------

module assembly(camera_type = 0) {
  bracket_angle = 55;

  translate([0, -7.5 - 15.5 + 7 + 4.3, 6.2])
  rotate([bracket_angle, 0, 0])
  translate([0, 0, 2])
  union() {
    translate([0, 8.5, 0])
    rotate([0, 0, 180]) {
      display_base();

      // Offset 6mm from display base, from standoffs
      rotate([-180, 0, 0])
      translate([-100 / 2 + 4, (-78 + 62) / 2 + 11, 6])
      color("darkgrey")
        import("NVIDIA_dev_kit_board.stl");

      display_bezel();
    } 

    translate([118 / 2 - 1, -0.5, -2.5])
      angle_bracket(RH_side = true, LH_style = 0);


    mirror([1, 0, 0])
    translate([118 / 2 - 1, -0.5, -2.5])
      angle_bracket(RH_side = false, LH_style = 0);
  }

  translate([0, -0.7, -44 - 0.2]) {
    mount_plate();

    translate([0, 0.2 + 23, -3 - 0.2 - 2])
      scanner_handle(type = 1);
  }

  if(camera_type == 0) {
    translate([0, 22.3 - 14, -44 - 0.2 + 3]) {
      kinect_rear_mount_bracket();

      translate([0, 102.5, 5])
      rotate([90, 0, 180])
      color("grey")
        import("Kinect_Azure_DK_Camera.stl");

      translate([0, 130.5, 5])
      rotate([90, 0, 0])
      rotate([0, 0, 90])
        kinect_lens_cap();

    }
  }

  if(camera_type == 1) {
    translate([0, 83, -16])
    rotate([90, 0, 180])
      realsense_camera_bracket();
  }
}

// Present parts in suggested print orientation
module print_part(part = 0) {
  // The display base
  if(part == 0)
      display_base();

  // The display bezel
  // Print this with three perimeters
  if(part == 1)
    translate([0, 0, 20])
    rotate([0, 180, 0])
      display_bezel(logo = 0);

  // The angle brackets
  if(part == 2)
    rotate([0, -90, 0]) {
      translate([0, 0, -10])
        angle_bracket(RH_side = true, LH_style = 0);

      translate([0, 0, 10])
      mirror([0, 1, 0])
      rotate([180, 0, 0])
        angle_bracket(RH_side = false, LH_style = 0);
    }

    // The mount plate    
    if(part == 3)
        translate([0, 0, 3])
        mirror([0, 0, 1])
            mount_plate();

    // The scanner handle
    if(part == 4)
        translate([0, 0, 3])
        rotate([0, 180, 0])
            scanner_handle(type = 1);

    // The Kinect camera bracket
    if(part == 5)
        translate([0, 0, 3])
        rotate([-90, 0, 0])
            kinect_rear_mount_bracket();

    // Lens cap
    if(part == 6)
        kinect_lens_cap();

    if(part == 7)
        realsense_camera_bracket();
}

//print_part(0);
assembly(0);
