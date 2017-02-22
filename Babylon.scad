use <sweep.scad>

module tower(){
  profile_l = 15;
  profile_h = 17;
  profile_slope_factor = 1.1;
  bottom_radius = 300;
  rounds_0 = 75;
  rounds_ab = 60;
  extra_rounds = 3;
  gap = 0.05;
  s = 13;
  outshoot = 45;
  spike_ang = s/5;
  inshoot = 8 + spike_ang;
  scalefac = 1.4;
  small_d = 2.6*profile_l;
  spikelim = 0.6;
  stairs_depth = 10;

  // Height = profile_h * profile_slope_factor
  // Width = profile_l
  stairs_profile = 
    [
     [         0, 0,  -(profile_slope_factor - 1)*profile_h],
     [         0, 0, -profile_h*profile_slope_factor + gap],
     [       -stairs_depth, 0, -profile_h*profile_slope_factor + gap], // Give profile depth
     [-profile_l-stairs_depth, 0, 0],
     [-profile_l, 0, 0]
    ];
  // show profile
//  path = [translation([0,0,0]),translation([0,10,0])];
//  !sweep(stairs_profile , path);

  function my_circle(r, z=0, step=s) = [for (v=[0:step:360-step])
    [r*cos(v),
     r*sin(v),
     z]];

  function move_inwards(v) = bottom_radius*pow((1-(exp(-v*0.0001))),0.5);
  function move_upwards(v) = 23*profile_h*profile_slope_factor*(sin(v/(4*(rounds_0)) - 90) - sin(-90));
  function h(v) = v*(profile_slope_factor*profile_h)/360 + move_upwards(v);
  function r(v) = bottom_radius - move_inwards(v);

  function retract_spikes(v) = abs(v) > spikelim ?
                               5*sqrt(3*abs(v)) :
                               5*sqrt(3*abs(spikelim)) + 15*(cos(v) - cos(spikelim));
 
  stairs_path = 
    [for (v_0=[360+spike_ang:s:rounds_0*360])
      for(extr = [-spike_ang:s/20:spike_ang])
        rotation([0,0,v_0+extr]) *
        translation([move_inwards(v_0+extr) < bottom_radius - small_d ?
                       r(v_0) - ((move_inwards(v_0)-move_inwards(v_0-360))/profile_l)*retract_spikes(extr):
                       max(r(v_0) - ((move_inwards(v_0)-move_inwards(v_0-360))/profile_l)*retract_spikes(extr),
                         small_d - ((move_inwards(v_0)-move_inwards(v_0-360))/profile_l)*retract_spikes(spike_ang)),
                     0,
                     h(v_0+extr)]) *
        scaling([(move_inwards(v_0)-move_inwards(v_0-360))/profile_l,
                     1,
                 1+(move_upwards(v_0+extr) - move_upwards(v_0+extr-360))/(profile_slope_factor*profile_h)]) *
        translation([profile_l,0,0])
      ];
  
  module stairs(){
    sweep(stairs_profile, stairs_path);
  }

  module trumpet(r){
    function scale_trumpet_helper(v) =
      move_inwards(v) < bottom_radius - (small_d-0.1) ?
        1+(r(v) - ((move_inwards(v)-move_inwards(v-360))/profile_l)*retract_spikes(spike_ang))/(move_inwards(v)-move_inwards(v-360)) :
        1+((small_d-0.1) - ((move_inwards(v)-move_inwards(v-360))/profile_l)*retract_spikes(spike_ang))/(move_inwards(v)-move_inwards(v-360));
    
    trumpet_path =
      [for (v_0=[360+spike_ang:s:rounds_0*360])     
        scaling([scale_trumpet_helper(v_0), scale_trumpet_helper(v_0), 1]) *
        scaling([(move_inwards(v_0)-move_inwards(v_0-360))/profile_l,
                 (move_inwards(v_0)-move_inwards(v_0-360))/profile_l,
                       1]) *    
        translation([0,0,h(v_0)])
      ];

    trumpet_profile_1 = my_circle(r, -profile_h*profile_slope_factor-gap);   
    sweep(trumpet_profile_1, trumpet_path);
  }
  //trumpet(profile_l);

  function helix(rounds, spiraling_factor = 1) =
    [for (v_1=[0:45:rounds*360])
    rotation([0,0,spiraling_factor*(h(v_1)/(r(v_1)+outshoot))*4*170/(PI)]) *
      translation([0,0,
          h(v_1)]) *
      scaling([move_inwards(v_1) < bottom_radius - small_d ?
          (r(v_1))/(bottom_radius-(1.0*profile_l)) :
          (small_d)/(bottom_radius-(1.0*profile_l)),
          move_inwards(v_1) < bottom_radius - small_d ?
          (r(v_1))/(bottom_radius-(1.0*profile_l)) :
          (small_d)/(bottom_radius-(1.0*profile_l)),
          1])];
  
  module door(){
    y = 15;
    x = 5;
    z = profile_h*profile_slope_factor-y/2;
    translate([-x/2,-y/2,-profile_h*profile_slope_factor+gap+0.5])
      cube([x,y,z]);
    translate([0,0,-y/2+1])
      scale([1,1,0.5])
      rotate([0,90,0])
      cylinder(d=y, h=x, center=true,$fn=80);
  }

  module doors(){
    for (v_0=[360*2:s:360*2 + 30*360]){
      rotate([0,0,v_0])
        translate([r(v_0), 0, h(v_0)])  
        rotate([0,0,2])
        scale([1,
               0.5+0.5*(move_inwards(v_0)-move_inwards(v_0-360))/profile_l,
               1+(move_upwards(v_0)-move_upwards(v_0-360))/(profile_slope_factor*profile_h)])
        door();
    }
  }

  module bottom2(r){
    quicker = -1.3;
    function scale_helper(v) =
        1+(r(v) - ((move_inwards(v*quicker)-move_inwards(v*quicker-360*quicker))/profile_l)*retract_spikes(0))/(move_inwards(v*quicker)-move_inwards(v*quicker-360*quicker));
    
    bottom2_path =
      [for (v_0=[360:s:360+spike_ang+1.2*360])     
        scaling([scale_helper(v_0), scale_helper(v_0), 1]) *
        scaling([(move_inwards(v_0)-move_inwards(v_0-360))/profile_l,
                 (move_inwards(v_0)-move_inwards(v_0-360))/profile_l,
                       1]) *    
        translation([0,0,h(v_0)])
      ];

    trumpet_profile_1 = my_circle(r, -profile_h*profile_slope_factor-gap);   
    sweep(trumpet_profile_1, bottom2_path);
  }
  //bottom2(profile_l);

  module more_solid_bottom(){
    infillrounds = 1.2;
    rotate([0,0,-45])
      sweep(my_circle(bottom_radius-scalefac*profile_l), helix(infillrounds));
  }
  //more_solid_bottom();

  module stairs_w_doors(){
    difference(){
      stairs();
      doors();
    }
  }
//    stairs_w_doors();
  
  module helices(){
    helix_profile_0 = [for (v=[-10:s/4:10])
                    [(bottom_radius-scalefac*profile_l)*cos(v) + outshoot*sin((v+10)*180/20),
                     (bottom_radius-scalefac*profile_l)*sin(v),
                      0]];
    helix_profile_0_inshoot =
      concat([[(bottom_radius-scalefac*profile_l)*cos(-10) - inshoot,
        (bottom_radius-scalefac*profile_l)*sin(-10),
        0]],
        helix_profile_0,
        [[(bottom_radius-scalefac*profile_l)*cos(10) - inshoot,
        (bottom_radius-scalefac*profile_l)*sin(10),
        0]]);
    helix_profile_1 = [for (v=[170:s/4:190])
                    [(bottom_radius-scalefac*profile_l)*cos(v) - outshoot*sin((v-170)*180/20),
                     (bottom_radius-scalefac*profile_l)*sin(v),
                     0]];
    helix_profile_1_inshoot =
      concat([[(bottom_radius-scalefac*profile_l)*cos(190) + inshoot,
        (bottom_radius-scalefac*profile_l)*sin(170),
        0]],
        helix_profile_1,
        [[(bottom_radius-scalefac*profile_l)*cos(170) + inshoot,
        (bottom_radius-scalefac*profile_l)*sin(190),
        0]]);
    helix_path = helix(rounds_ab);
    helix_path_mirrored = helix(rounds_ab, -1);
    rotate([0,0,90]){
      sweep(helix_profile_0_inshoot, helix_path_mirrored);
      sweep(helix_profile_1_inshoot, helix_path_mirrored);
    }
    rotate([0,0,90+45]){
      sweep(helix_profile_0_inshoot, helix_path);
      sweep(helix_profile_1_inshoot, helix_path);
    }
  }
//  helices();

  module  solid_tower(){
    stairs_w_doors();
    helices();
//    bottom2(profile_l+2);
    more_solid_bottom();
    trumpet(profile_l);
  }
  solid_tower();
  
  module hollow_tower(){
    difference(){
      solid_tower();
      trumpet(profile_l - 1);
    }
  }
//  hollow_tower();

  module hollow_tower0(){    
    difference(){
//        %import("better_doors_and_swing/w_better_doors_and_swing.stl");
      union(){
          stairs_w_doors();
          helices();
          more_solid_bottom();
      }

      translate([0,0,-0.02])
      scale([0.923,0.923,1])
        sweep(trumpet_profile_1, helix(rounds_ab-40,0));
    }
  }
//  hollow_tower0();

  module stairs_except_top_layers(){
    profile_s = [
             [         1, 0,  -(profile_slope_factor - 1)*profile_h-2],
             [         1, 0, -profile_h*profile_slope_factor + gap],
             [       -11, 0, -profile_h*profile_slope_factor + gap], // Give profile depth
             [-profile_l-11, 0, -(profile_slope_factor - 1)*profile_h-2],
             [-profile_l, 0, -(profile_slope_factor - 1)*profile_h-2]
            ];
    // show profile
    //  path = [translation([0,0,0]),translation([0,10,0])];
    //  !sweep(profile_s , path);

    sweep(profile_s, stairs_path);
  }
//  stairs_except_top_layers();

}
scale([0.8,0.8,4])
tower();

module outermost_infill(){
  difference(){
    cylinder(r=350, h=10/4);
    translate([0,0,-1])
      cylinder(r=275, h=12/4);
  }
}
//[1,1,4])
//  outermost_infill();

